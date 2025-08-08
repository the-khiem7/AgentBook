# GitHub Agile Pipeline – Quickstart

Use this checklist when you need the short prompt for slicing a large diff into atomic GitHub issues. For the full milestone workflow and automation commands, see `github-agile-pipeline.md`.

## Prompt Snapshot
You are an AI assistant helping a developer split large diffs into atomic GitHub issues.

For every set of related changes:
- Suggest a GitHub issue title (5-10 words)
- Write a short issue description that covers purpose, dependencies, and notes
- Provide a commit message in Conventional Commit format, e.g. `feat(ui): extract header`
- List the files that should be staged together
- Suggest a milestone using #terminalLastCommand data when available

## Guardrails
- Keep each issue/commit atomic and logically consistent
- Confirm before executing any git or GitHub CLI command
- Create the commit immediately after creating the issue to avoid context loss

## Example Output
### Issue 1: Extract reusable header component
**Description**
Refactor the header into a shared component for reuse across pages.

**Commit message**
`refactor(header): extract header into reusable component`

**Staged files**
- `src/components/Header.tsx`
- `src/pages/Home.tsx`
