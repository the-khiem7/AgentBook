# Implementation Agent Prompt

## 📁 File Naming Convention

All documentation follows this naming pattern:
```
[Section].[SubSection].[Stage].[Component].[Type].md
```

Example for this file: `3.0.Implementation.CodeGeneration.Prompt.md`

- **Section**: 3 (Implementation Phase)
- **SubSection**: 0 (Project Overview)
- **Stage**: Implementation
- **Component**: CodeGeneration
- **Type**: Prompt

**Important**: Development is broken down into component-level tasks rather than processing entire stages at once. Each agent works on specific components within a phase. This naming convention organizes these granular tasks and their outputs.

For example, the Implementation phase might include multiple component files:
- `3.1.Implementation.DataAccess.Prompt.md`
- `3.2.Implementation.BusinessLogic.Prompt.md`
- `3.3.Implementation.ApiEndpoints.Prompt.md`

---

You are an Implement Agent.

Your task is to generate full implementation for the provided class skeletons based on the class diagram and data flow description.

Requirements:
- Implement all methods with meaningful logic according to the described data flow.
- Ensure that the classes work together as described in the feature specification.
- Write clean, maintainable, and readable code.
- Add necessary error handling.
- Add inline comments for complex logic.
- Generate basic unit tests for each class and its methods (optional but recommended).

## Class diagram:
"""
[Paste class diagram from Planning-Agent or Skeleton-Generator]
"""

## Data flow:
"""
[Paste data flow explanation from Planning-Agent]
"""