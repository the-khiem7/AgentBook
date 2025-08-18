<!-- agent-ignore:start -->
id: commit-hunk-auto
name: Commit Coach (Hunk, Auto Diff & Patch)
category: commit
goal: Read real git diff, split into precise per-hunk commits, and emit non-interactive staging/commit commands
goal-vn: Đọc diff thực tế, tách commit theo từng hunk chính xác và xuất lệnh stage/commit không tương tác
command_style: PowerShell
tags: [git, commit, hunk, patch, auto-diff, conventional-commits, powershell, vscode-agent]
<!-- agent-ignore:end -->

<!-- 📘 OPX CONFIG GUIDE

diff_source: How to obtain changes.
  → "git"        = agent runs whitelisted git commands below
  → "porcelain"  = user pastes `git status --porcelain=v1`
  → "changes"    = use #changes context (if provided by host)

cmd: Shell syntax for output commands.
  → "pwsh" = PowerShell, "bash" = Linux/macOS

msgs: Number of commit message suggestions per group.
  → "one" = single best, "three" = 3 options

hunk_mode: Staging mode.
  → "patch"       = emit minimal patches, apply with `git apply --cached`
  → "interactive" = (fallback) guide `git add -p` for manual pick

hunk_max: Max hunks per commit group (avoid oversized commits).
hunk_min_lines: Ignore cosmetic hunks shorter than N lines.

exec_allow: Allow running only the **two** whitelisted commands below.
exec_git_porcelain: Exact porcelain command.
exec_git_diff:      Exact diff command (unified context lines recommended).
-->

<opx type="commit-hunk-auto">

  # === Core ===
  diff_source:         git                     # git | porcelain | changes
  cmd:                 pwsh                    # pwsh | bash
  msgs:                one                     # one | three

  # === Hunk Controls ===
  hunk_mode:           patch                   # patch | interactive
  hunk_max:            6                       # max hunks per commit group
  hunk_min_lines:      2                       # ignore tiny/whitespace-only hunks

  # === Execution (whitelist) ===
  exec_allow:          on                      # on = allow only commands below
  exec_git_porcelain:  'git status --porcelain=v1'
  exec_git_diff:       'git diff -U3'

</opx>

# ============================================================================ #
# 🧩 (Optional) PORCELAIN INPUT — only used when diff_source=porcelain
# >>> BEGIN PORCELAIN
<<PASTE_GIT_STATUS_PORCELAIN_V1_HERE>>
# <<< END PORCELAIN
# ============================================================================ #

# ============================================================================ #
# 🧾 (Optional) CHANGES — only used when diff_source=changes
# >>> BEGIN CHANGES
<<PASTE_UNIFIED_DIFFS_OPTIONAL_HERE>>
# <<< END CHANGES
# ============================================================================ #

NOTE TO AGENT — HARD RULES:
!!! SINGLE-SHOT OUTPUT — DO NOT PLAN OR EXECUTE IN STEPS. !!!
- Output text only; do NOT create todos/tasks/progress logs.
- Use **PowerShell** syntax in all command examples (no backslash line-continuations).
- Enumerate exact files; never use `git add .` or directory-wide staging in hunk mode.

EXECUTION POLICY (STRICT):
- You MAY run **only**:
  1) {exec_git_porcelain}
  2) {exec_git_diff}
- Immediately paste the raw outputs **verbatim** into your own response under headings:
  - “Porcelain (captured)”
  - “Diff (captured)”
- You MUST NOT run any other command. No writes, no network, no shell tricks.
- If either command fails, fall back to asking the user to paste outputs, or switch `diff_source` to `porcelain`.

INTERPRETATION POLICY:
- Treat porcelain as the **source of truth** for file states (??, A, M, D, R##, C##, U).
- If rename (R##) exists, commit `git mv old new` **before** applying hunks to the new path.
- Build a **Hunk Map** from the real `git diff` (group by scope/module).
- Respect limits: ≤ `hunk_max` hunks per commit group; ignore hunks < `hunk_min_lines` lines unless semantically important.

OUTPUT SCHEMA (MATCH EXACTLY):

---

# 🧩 Commit Coach — Hunk Auto (Git Diff Reader)

The agent runs the allowed git commands, parses the real diff, and outputs precise per-hunk commits.

---

## A) Echo
`Mode=HUNK-AUTO; Cmd=<cmd>; Msgs=<msgs>; HunkMode=<hunk_mode>.`

---

## A2) Captured Inputs
### Porcelain (captured)
```

<raw output of {exec_git_porcelain}>

```

### Diff (captured)
```

<raw output of {exec_git_diff}>

````

---

## B) Summary
- Added / Modified / Deleted / Renamed (from porcelain)
- Risk level (Low / Medium / High)
- Impacted scopes/modules

---

## B2) Hunk Map
List selected hunks per file with line ranges + short intent.
Example:
- src/services/UserService.cs
  • H1: L120–L138 — extract helper method
  • H2: L201–L210 — fix null-check

(Do not exceed `hunk_max`. Skip hunks shorter than `hunk_min_lines` unless critical.)

---

## C) Commit Breakdown (Per-Hunk Groups)
For each group:
- **Scope** — module/folder
- **Files/Hunks** — explicit list (file + H#)
- **Rationale** — why staged together
- **Impact/Test** — what to verify

---

## D) Commit Message Suggestions
For each group:
- If `msgs=one` → 1 message
- If `msgs=three` → 3 variants
- Format: `type(scope): subject` (≤72 chars)
- Optional short body bullets

---

## E) Commands (print only — do not execute)
Use PowerShell. For each group, emit **non-interactive** staging with minimal patches.

### Rename (if present)
```powershell
git mv "old\path\UserService.cs" "new\path\UserService.cs"
git commit -m "refactor(core): rename UserService for clarity"
````

### H-patch (per-hunk minimal patch)

```powershell
# Group <n>: <short description>
$patch = @'
*** Begin Patch
--- a/src/services/UserService.cs
+++ b/src/services/UserService.cs
@@ -120,7 +120,8 @@
-    if (user != null) return user.Name;
+    if (user is null) return "Anonymous";
+    return user.Name;
*** End Patch
'@

$pf = "hunk_001_UserService_fixnull.patch"
$patch | Out-File -FilePath $pf -Encoding UTF8 -NoNewline
git apply --cached --unidiff-zero $pf

$subject = "fix(service): null-safe user name in UserService"
git commit -m $subject
```

(Repeat for each hunk/group. Never use `git add -p` in auto mode.)

---

## 🚫 If No Changes

> “No local changes”