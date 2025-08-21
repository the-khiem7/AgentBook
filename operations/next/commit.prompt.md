<!-- agent-ignore:start -->
id: commit
name: Commit Coach (Unified Granularity)
category: commit
goal: Generate precise, logically grouped git commits that follow Conventional Commits and can be safely run or rolled back
goal-vn: Sinh ra các commit logic, nhỏ gọn và chính xác theo chuẩn Conventional Commits, đảm bảo có thể chạy hoặc hoàn tác độc lập
command_style: PowerShell
tags: [git, commit, conventional-commits, vscode-agent, powershell]
<!-- agent-ignore:end -->

<!-- 📘 OPX CONFIG GUIDE

diff_source: Source of diff content.
  → "changes"   = analyze #changes context (AI agent internal)
  → "porcelain" = analyze pasted output from `git status --porcelain=v1`

granularity: Defines how small each commit should be.
  → S  = small (feature or business-level)
  → US = ultra-small (atomic, micro-group)

cmd: Target shell syntax for commit examples.
  → "pwsh" = PowerShell, "bash" = Linux/macOS shell.

msgs: Number of commit message suggestions per commit group.
  → "one" = single best message, "three" = 3 alternative options.
-->

#=======================================================================
# PORCELAIN INPUT (REQUIRED when diff_source=porcelain)
# Run exactly:  git status --porcelain=v1
# Paste RAW output below (no edits). Max ~500 lines to avoid truncation.
#
# Parser rules for the agent:
# - Trust ONLY lines that start with valid 2-char XY codes (??, A , M , D , R##, C##, U ).
# - Handle rename lines in v1 format:  R100 old/path -> new/path
# - Treat spaces in paths literally; do NOT split on spaces inside filenames.
# - Ignore any line that doesn’t match porcelain v1 patterns.
#
# >>> BEGIN PORCELAIN
<<PASTE_GIT_STATUS_PORCELAIN_V1_HERE>>
# <<< END PORCELAIN
#=======================================================================

#=======================================================================
# CHANGES (OPTIONAL — for crafting better messages, NOT for file existence)
# You may paste unified diffs from:  git diff
# Optionally include staged diffs:    git diff --cached
# Keep it concise (only relevant sections) to reduce token bloat.
#
# >>> BEGIN CHANGES
<<PASTE_UNIFIED_DIFFS_OPTIONAL_HERE>>
# <<< END CHANGES
#=======================================================================

#=======================================================================
# ⚠️ ALERT — PORCELAIN MODE REQUIRES INPUT
#
# If diff_source=porcelain but the PORCELAIN block above is empty,
# the agent MUST print an instructional fallback like:
#
#   COMMAND NOT RUN: I could not execute git locally.
#   Please run the command below in PowerShell and paste the raw output here.
#
#   PowerShell:
#   git status --porcelain=v1
#
# And, if message quality needs diffs, also instruct:
#
#   PowerShell:
#   git diff -U3
#
# Then STOP until the user provides the outputs.
#=======================================================================

<opx type="commit">

  # === Core ===
  diff_source:      changes         # changes | porcelain
  granularity:      S               # S | US
  cmd:              pwsh            # pwsh | bash
  msgs:             one             # one | three

</opx>

NOTE TO AGENT — HARD RULES:
!!! DO NOT PLAN OR EXECUTE. !!!
This is a SINGLE-SHOT OUTPUT prompt.
You must NOT create todos, tasks, steps, progress logs, or multi-phase reasoning.
⚠️ FORBIDDEN:
Do NOT call any tool or command automatically — output only text.

TOOLS FORBIDDEN:
Do not call repository.change-list, get_changed_files, or any Git API tool.
Read text context only. All analysis is textual, not procedural.

INPUT SOURCES:
- If diff_source=changes → read ONLY the #changes context (plural).
- If diff_source=porcelain → rely ONLY on the pasted `git status --porcelain=v1`.

IF #changes IS EMPTY:
1) Print the echo block (see section A below)
2) Then print exactly:  
   `No local changes`
3) Stop.

---

# 🧩 Commit Coach — Multi-Granularity Conventional Commit Agent

Interpret the provided diff content (from **#changes** or porcelain output).
Generate a **single, clean commit analysis** according to this schema.

---

## A) Echo
Print the directive block showing current configuration.  
Each element must appear on its **own line**, with an **emoji icon** and aligned formatting:

```text
🧩 Granularity = <granularity>
💻 Cmd          = <cmd>
💬 Msgs         = <msgs>
🗂️ DiffSource   = <diff_source>
````

**Formatting Rules:**

* Maintain the order exactly as shown above.
* Align the equal signs visually for readability.
* Use monospaced formatting for clean alignment.

**Icons meaning:**

| Element     | Icon | Description                             |
| ----------- | ---- | --------------------------------------- |
| Granularity | 🧩   | Commit grouping level (S / US)          |
| Cmd         | 💻   | Target shell syntax                     |
| Msgs        | 💬   | Number of commit messages per group     |
| DiffSource  | 🗂️  | Input source type (changes / porcelain) |

**Example (no changes case):**

```text
🧩 Granularity = S
💻 Cmd          = pwsh
💬 Msgs         = one
🗂️ DiffSource   = porcelain

No local changes
```

---

## B) Summary

* Added / Modified / Deleted / Renamed counts
* Impacted scopes or modules

---

## C) Commit Breakdown

List commits in order (`Commit 1`, `Commit 2`, …):
Each includes:

* **Scope** — affected domain or directory
* **Rationale** — why separated
* **Impact/Test** — what to verify

---

## D) Commit Message Suggestions

For each commit group:

* If `msgs=one` → one message
* If `msgs=three` → three variants
* Follow Conventional Commits: `type(scope): subject` (≤72 chars)
* Include optional body bullets / footer (`Closes #123`)

---

## E) Commands (print only — do not execute)

Use syntax per `cmd`.

### **PowerShell Example**

```powershell
# Commit <n>: <short description>
$files = @("path/to/file1","path/to/file2")
git add $files
$subject = "feat(auth): add password reset API"
$body = @(
  "- Implement POST /reset-password endpoint",
  "- Add token verification and expiration handling"
)
git commit -m $subject `
           -m $body[0] `
           -m $body[1]
```

### **Rename Example**

```powershell
git mv "old/path/file.cs" "new/path/file.cs"
git commit -m "refactor(core): rename file to match type name"
```

---

## F) Hygiene

* Warn if `.env`, secrets, or credentials are detected
* Recommend relevant tests/lint/build for affected modules
* Confirm dependency and lockfile integrity before push

---

## 🚫 If No Changes

> “No local changes”