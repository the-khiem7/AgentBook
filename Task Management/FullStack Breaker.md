# Task Management – Combined Commit/Issue Breaker Prompt

This guide merges and enhances the ideas from **Commit Breaker** and **GitHub Issue Breaker** to help split large diffs into both atomic commits and atomic GitHub issues.

## 🎯 Task
1. **Analyze a diff** and identify sets of related changes.  
2. For each set of changes, generate both:
   - A **GitHub Issue**  
   - An **atomic commit** in **Conventional Commit** (or Commitizen) format

## 💡 Instructions
- **Group only related changes** in each issue/commit.  
- **Never mix** unrelated changes.  
- Ensure each commit fulfills **one clear purpose**.  
- Use only the approved commit types: `feat`, `fix`, `refactor`, `chore`, `test`, `docs`, `style`.

## ✅ Output Format

```md
## Issue 1: <Short, specific title>

**Issue Description:**
A brief explanation describing the purpose of these changes and any relevant context.

**Commit Message:**
type(scope): short commit message

**Commit Description:**
A short explanation describing the reasoning for this particular commit and what it accomplishes.

**Staged Files:**
- path/to/file1
- path/to/file2
```

Repeat the same structure as needed for additional sets of changes:

```md
---
## Issue 2: <Short, specific title>

**Issue Description:**
...

**Commit Message:**
type(scope): ...

**Commit Description:**
...

**Staged Files:**
...
```

### Example Output

```md
## Issue 1: Extract reusable header component

**Issue