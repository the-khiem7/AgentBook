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
  → "changes" = analyze #changes context (AI agent internal)
  → "porcelain" = analyze pasted output from `git status --porcelain=v1`

granularity: Defines how small each commit should be.
  → S = small (feature or business-level)
  → US = ultra-small (atomic, line-level)
  → H = hunk-based (commit by diff chunk)

cmd: Target shell syntax for commit examples.
  → "pwsh" = PowerShell, "bash" = Linux/macOS shell.

msgs: Number of commit message suggestions per commit group.
  → "one" = single best message, "three" = 3 alternative options.
-->

<opx type="commit">

  # === Core ===
  diff_source:      porcelain       # changes | porcelain
  granularity:      S               # S | US | H
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
- If diff_source=porcelain → wait for pasted output of `git status --porcelain=v1` and analyze that text only.

IF #changes IS EMPTY:
1) Print the echo line:  
   `Granularity=<granularity>; Cmd=<cmd>; Msgs=<msgs>; DiffSource=<diff_source>.`
2) Print exactly: `No local changes`
3) Stop.

---

# 🧩 Commit Coach — Multi-Granularity Conventional Commit Agent

Interpret the provided diff content (from **#changes** or porcelain output).
Generate a **single, clean commit analysis** according to this schema.

---

## A) Echo
Print the directive line:
`Granularity=<granularity>; Cmd=<cmd>; Msgs=<msgs>; DiffSource=<diff_source>.`

---

## B) Summary
- Added / Modified / Deleted / Renamed counts  
- Risk level (Low / Medium / High)  
- Impacted scopes or modules  

---

## C) Commit Breakdown
List commits in order (`Commit 1`, `Commit 2`, …):  
Each includes:
- **Scope** — affected domain or directory  
- **Rationale** — why separated  
- **Impact/Test** — what to verify  
- If `granularity=H`: show per-hunk intent or file-line ranges  

---

## D) Commit Message Suggestions
For each commit group:
- If `msgs=one` → one message  
- If `msgs=three` → three variants  
- Follow Conventional Commits: `type(scope): subject` (≤72 chars)  
- Include optional body bullets / footer (`Closes #123`)  

---

## E) Commands (print only — do not execute)
Use syntax per `cmd`.

### **PowerShell example**
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
````

### **Rename**

```powershell
git mv "old/path/file.cs" "new/path/file.cs"
git commit -m "refactor(core): rename file to match type name"
```

### **Hunk Mode**

```powershell
git add -p "src/services/UserService.cs"
```

---

## F) Hygiene

* Warn if `.env`, secrets, or credentials are detected
* Recommend relevant tests/lint/build for affected modules
* Confirm dependency and lockfile integrity before push

---

## 🚫 If No Changes

> “No local changes”