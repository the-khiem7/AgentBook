<!-- agent-ignore:start -->
id: commit-chrono
name: Commit Coach (Chronobreak, S/US/H)
category: commit
goal: Produce clean, logically split Conventional Commits and simulate a realistic commit timeline (chronobreak) using safe timestamp techniques
goal-vn: Tạo các commit tách logic theo Conventional Commits và mô phỏng dòng thời gian commit (chronobreak) bằng cách đặt timestamp an toàn
command_style: PowerShell
tags: [git, commit, conventional-commits, vscode-agent, powershell, chronobreak]
<!-- agent-ignore:end -->

<opx type="commit-chrono">
  diff_source:      porcelain     # changes | porcelain
  granularity:      S             # S | US | H
  cmd:              pwsh          # pwsh | bash
  msgs:             one           # one | three

  chrono_mode:      safe_env      # safe_env | admin_set_date
  chrono_timezone:  +0700         # e.g., +0700, +0000, -0500
  chrono_start:     2025-07-24    # YYYY-MM-DD (first day to use)
  chrono_days:      3             # spread commits across N days (>=1)
  chrono_per_day:   1..3          # random range, e.g., 1..2 or 2..4
  chrono_hours:     09..18        # working hour window (HH..HH, 24h)
</opx>

NOTE TO AGENT — HARD RULES:
!!! DO NOT PLAN OR EXECUTE. !!!
This is a SINGLE-SHOT OUTPUT prompt.
Do NOT create todos, tasks, steps, progress logs, checkpoints, or multi-phase reasoning.

TOOLS FORBIDDEN:
Do not call repository.change-list, get_changed_files, or any Git API tool.
Read text context only. All analysis is textual, not procedural.

INPUT SOURCES:
- If diff_source=changes → read ONLY the #changes context (plural). Do not attempt to list or fetch files.
- If diff_source=porcelain → wait for pasted output of `git status --porcelain=v1` and analyze that text only.

IF #changes IS EMPTY:
1) Print the echo line:
   `Granularity=<granularity>; Cmd=<cmd>; Msgs=<msgs>; DiffSource=<diff_source>; ChronoMode=<chrono_mode>.`
2) Print exactly: `No local changes`
3) Stop.

CHRONOBREAK POLICY:
- Generate a realistic timeline for the commits based on:
  `chrono_start`, `chrono_days`, `chrono_per_day`, `chrono_hours`, `chrono_timezone`.
- Randomize minutes (and hours within the window) without collisions within the same day.
- Maintain dependency order across commits (e.g., schema → code → tests).
- Do NOT alter global system time unless chrono_mode=admin_set_date (see warnings).
- Prefer safe_env mode: set `GIT_AUTHOR_DATE` and `GIT_COMMITTER_DATE` per commit.
- Always print a final “Reset environment” snippet to clear env variables after the last commit.

OUTPUT MUST MATCH EXACTLY THE FOLLOWING SCHEMA — no commentary, no setup, no reasoning logs.

---

# 🧩 Commit Chronobreak — Conventional Commit Agent (Single-Shot)

Interpret the provided diff content (from **#changes** or porcelain output) and produce:
- a clean commit breakdown (S/US/H granularity), and
- PowerShell commit commands that **simulate timestamps** per the chronobreak configuration.

---

## A) Echo
Print the directive line:
`Granularity=<granularity>; Cmd=<cmd>; Msgs=<msgs>; DiffSource=<diff_source>; ChronoMode=<chrono_mode>.`

---

## B) Summary
- Added / Modified / Deleted / Renamed counts
- Risk level (Low / Medium / High)
- Impacted scopes/modules

---

## C) Commit Breakdown (with Chrono Schedule)
List commits in order (`Commit 1`, `Commit 2`, …). For each commit include:
- **Scope** — affected domain or directory
- **Timestamp** — `YYYY-MM-DD HH:MM:SS <chrono_timezone>` (scheduled value)
- **Rationale** — why separated
- **Impact/Test** — what to verify
- If `granularity=H`: show per-hunk intent or file-line ranges

The scheduled timestamps must align with:
- start day = `chrono_start`
- number of days = `chrono_days`
- commits per day = random in `chrono_per_day` range
- working hours = inside `chrono_hours` window
- timezone suffix = `chrono_timezone`

---

## D) Commit Message Suggestions
For each commit group:
- If `msgs=one` → one message
- If `msgs=three` → three variants
- Use Conventional Commits: `type(scope): subject` (≤72 chars)
- Optional body bullets / footer (`Closes #123`) when relevant

---

## E) Commands (print only — do not execute)
Use PowerShell (`cmd=pwsh`). For each commit, **set the timestamp**, stage files, then commit.

**PowerShell pattern (safe_env, recommended)**
```powershell
# Commit <n>: <short description>
$files = @("path\\to\\file1","path\\to\\file2")
git add $files

# Set per-commit timestamp (safe_env mode)
$when = "<YYYY-MM-DD HH:MM:SS> <TZ>"   # e.g., 2025-07-24 09:17:00 +0700
$env:GIT_AUTHOR_DATE    = $when
$env:GIT_COMMITTER_DATE = $when

$subject = "<type(scope): subject>"
$body = @("- detail 1","- detail 2")
git commit -m $subject `
           -m $body[0] `
           -m $body[1]
````

**Rename**

```powershell
git mv "old\\path\\file.cs" "new\\path\\file.cs"
git commit -m "refactor(core): rename file to match type name"
```

**Hunk Mode**

```powershell
git add -p "src\\module\\BigFile.cs"
```

**(Optional) Admin mode warning**
If `chrono_mode=admin_set_date`, print commands like:

```powershell
# WARNING: Admin-only; affects system time. Reset immediately after.
# Set-Date -Date "2025-07-24 11:05:00"
# ... do the commit ...
# Set-Date -Date (Get-Date)  # restore actual system time
```

(Prefer `safe_env` unless you explicitly require system-time changes.)

**Reset environment (always print once at the end)**

```powershell
# Reset env timestamps
Remove-Item Env:GIT_AUTHOR_DATE    -ErrorAction SilentlyContinue
Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
```

---

## F) Hygiene

* Warn if `.env`, secrets, or credentials are detected
* Recommend tests/lint/build for affected modules
* Confirm dependency/lockfile integrity before push

---

## 🚫 If No Changes

Print only:

> “No local changes”