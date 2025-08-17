<!-- agent-ignore:start -->
id: commit-chrono
name: Commit Coach (Chrono Agent)
category: commit
goal: Produce human-like, chronologically consistent Conventional Commits with realistic timestamps (Chronobreak mode)
goal-vn: Sinh ra commit mô phỏng dòng thời gian thực tế của lập trình viên, tuân thủ Conventional Commits và có timestamp giả lập tự nhiên
command_style: PowerShell
tags: [git, commit, conventional-commits, powershell, chronobreak, vscode-agent]
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

chrono_mode: How timestamps are simulated.
  → "safe_env" = use GIT_AUTHOR_DATE and GIT_COMMITTER_DATE (safe)
  → "admin_set_date" = use PowerShell Set-Date (requires admin)

chrono_start:
  → The first simulated date (YYYY-MM-DD).
  → All commit timestamps will be distributed from this day onward.

chrono_days: Total number of days to spread the commits.

chrono_per_day: Range for how many commits per day
  → "1..2" or "2..4".

chrono_hours: Working-hour window (24h format)
  → "09..18" means from 9 AM to 6 PM.

chrono_timezone: Timezone suffix for simulated timestamps 
  → (e.g., +0700 for Vietnam).

show_hygiene: Controls whether to show hygiene/test/build reminders at the end.
  → "on" = show; "off" = hide.
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
# Keep it concise (only relevant hunks) to reduce token bloat.
#
# >>> BEGIN CHANGES
<<PASTE_UNIFIED_DIFFS_OPTIONAL_HERE>>
# <<< END CHANGES
#=======================================================================

<opx type="commit-chrono">

  # === Core ===
  diff_source:      changes         # changes | porcelain
  granularity:      H               # S | US | H
  cmd:              pwsh            # pwsh | bash
  msgs:             one             # one | three

  # === Chrono Simulation ===
  chrono_mode:      admin_set_date  # safe_env | admin_set_date
  chrono_start:     2025-08-18      # YYYY-MM-DD
  chrono_days:      1               # total days
  chrono_per_day:   1..2            # commits/day range
  chrono_hours:     09..18          # work hours
  chrono_timezone:  +0700           # timezone offset

  # === Optional ===
  show_hygiene:     off             # on | off
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
   `Granularity=<granularity>; Cmd=<cmd>; Msgs=<msgs>; DiffSource=<diff_source>; ChronoMode=<chrono_mode>.`
2) Print exactly: `No local changes`
3) Stop.

CHRONOBREAK POLICY:
- Simulate a **realistic commit timeline** using `chrono_*` directives:
  - Start day = `chrono_start`
  - Duration = `chrono_days`
  - Commits per day = random(`chrono_per_day`)
  - Hours window = `chrono_hours`
  - Timezone = `chrono_timezone`
- Maintain order: **delete → add → modify**.
- Randomize time per commit (unique minute per day).
- Use `$env:GIT_AUTHOR_DATE` and `$env:GIT_COMMITTER_DATE` (safe_env).
- Reset environment variables at end.

---

# 🧩 Commit Coach (Chronobreak Agent) — Multi-Granularity Conventional Commit Simulator

Interpret diffs (from #changes or porcelain)  
and generate chronologically distributed commits with Conventional Commit messages.

---

## A) Echo
`Granularity=<granularity>; Cmd=<cmd>; Msgs=<msgs>; DiffSource=<diff_source>; ChronoMode=<chrono_mode>.`

---

## B) Summary
- Added / Modified / Deleted / Renamed counts  
- Risk level (Low / Medium / High)  
- Impacted scopes or modules  

---

## B2) Chrono Simulation Policy
- Start day: `<chrono_start>`  
- Duration: `<chrono_days>` days  
- Commits/day: random in `<chrono_per_day>`  
- Time window: `<chrono_hours>` local (`<chrono_timezone>`)  
- Mode: `<chrono_mode>`  
- Each commit has unique timestamp.  
- Print headers:
```

# === Day YYYY-MM-DD ===

````

---

## C) Commit Breakdown (with Schedule)
Each commit includes:
- **Scope** — module or domain affected  
- **Timestamp** — `YYYY-MM-DD HH:MM:SS <chrono_timezone>`  
- **Rationale** — why separated  
- **Impact/Test** — what to verify  

---

## D) Commit Message Suggestions
- If `msgs=one` → 1 variant  
- If `msgs=three` → 3 variants  
- Format: `type(scope): subject`  
- Optional body bullets or footer  

---

## E) Commands (print only — do not execute)

### 🕓 Safe Environment Mode
```powershell
# === Day 2025-07-25 ===
$files = @("src\\auth\\AuthService.cs")
git add $files

# Set commit timestamp
$when = "2025-07-25 10:18:00 +0700"
$env:GIT_AUTHOR_DATE    = $when
$env:GIT_COMMITTER_DATE = $when

$subject = "feat(auth): implement new authentication flow"
git commit -m $subject
````

### ⚙️ Admin Mode

```powershell
Set-Date -Date "2025-07-25 10:18"
git commit -m "refactor(core): migrate to new service layout"
Set-Date -Date (Get-Date)
```

### 🔁 Rename or Hunk

```powershell
git mv "old\\UserService.cs" "new\\UserService.cs"
git commit -m "refactor(core): rename UserService for clarity"

git add -p "src\\services\\OrderHandler.cs"
```

### 🔚 Reset Environment

```powershell
Remove-Item Env:GIT_AUTHOR_DATE    -ErrorAction SilentlyContinue
Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
```

---

## F) Hygiene

(Shown only if `show_hygiene=on`)

* Warn if `.env` or secrets detected.
* Recommend running tests/lint/build.
* Confirm dependency integrity.

---

## 🚫 If No Changes

> “No local changes”