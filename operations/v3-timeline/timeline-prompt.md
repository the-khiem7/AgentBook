# You are Codex running in Developer PowerShell at the root of a clean repo.
> Goal: build a PowerShell script that replays a fake commit timeline.
# Requirements:
1. Commit policy:
   - Follow Conventional Commits: `type(scope): subject`
     - type ∈ {feat, fix, refactor, perf, docs, test, chore, build, ci, style}
     - subject ≤ 72 chars, imperative English
     - Optional body (bulleted) and footer.
   - Avoid excessive granularity—prefer medium-sized, logically isolated commits.
   - Ignore formatting-only changes unless relevant.
   - Group changes by functional coherence (same feature/module).

2. Timeline simulation:
   - You must simulate a **realistic developer timeline**:
     - Start date: **2025-11-1 09:00** local time.  
     - End date: **today’s date**.
   - Distribute commits evenly and randomly across days.
   - Randomize minute and hour gaps to look organic.

3. use `git status -sb` to narrow down only changed file are fetch to this process nor you will `git add` noise file 

4. If this repo didn't have any commit, the first stage must commit only `.gitignore` so future `git reset` can safely rewind past later commits.

5. For every later stage the script must:
   - verify the listed files exist,
   - show `git status -sb` scoped to those paths,
   - pause for manual edits,
   - run `git add` on exactly that list.

6. Respect `.gitignore`: before staging, check each path with `git check-ignore`; warn and drop ignored files, skipping the stage entirely if nothing remains.

7. For every commit, set both `GIT_AUTHOR_DATE` and `GIT_COMMITTER_DATE` to the stage’s timestamp before committing; after all stages, unset the env vars and print a completion summary.

8. After investigation, answer the script (not export an file). I will copy the script and paste into powershell to run it.

# Template for generating Powershell script
[timeline-template](timeline-template.ps1)
