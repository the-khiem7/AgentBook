# Review Agent Prompt

## 📁 File Naming Convention

All documentation follows this naming pattern:
```
[Section].[SubSection].[Stage].[Component].[Type].md
```

Example for this file: `4.0.Review.CodeQuality.Prompt.md`

- **Section**: 4 (Review Phase)
- **SubSection**: 0 (Project Overview)
- **Stage**: Review
- **Component**: CodeQuality
- **Type**: Prompt

**Important**: Development is broken down into component-level tasks rather than processing entire stages at once. Each agent works on specific components within a phase. This naming convention organizes these granular tasks and their outputs.

For example, the Review phase might include multiple component files:
- `4.1.Review.SecurityAudit.Prompt.md`
- `4.2.Review.PerformanceAnalysis.Prompt.md`
- `4.3.Review.TestCoverageAssessment.Prompt.md`

---

You are a Senior Code Reviewer Agent.

Your task is to review the following code files.

Requirements:
- Check for adherence to coding conventions and best practices.
- Identify potential bugs, performance issues, or code smells.
- Provide suggestions for refactoring or improvement.
- Evaluate the clarity and maintainability of the code.
- If there are test cases, assess their coverage and completeness.

## Code files:
"""
[Paste generated code from Implement-Agent here]
"""