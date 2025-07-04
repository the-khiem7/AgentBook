# Skeleton Generator Agent Prompt

## 📁 File Naming Convention

All documentation follows this naming pattern:
```
[Section].[SubSection].[Stage].[Component].[Type].md
```

Example for this file: `2.0.Skeleton.ClassStructure.Prompt.md`

- **Section**: 2 (Skeleton Generate Phase)
- **SubSection**: 0 (Project Overview)
- **Stage**: Skeleton
- **Component**: ClassStructure
- **Type**: Prompt

**Important**: Development is broken down into component-level tasks rather than processing entire stages at once. Each agent works on specific components within a phase. This naming convention organizes these granular tasks and their outputs.

For example, the Skeleton phase might include multiple component files:
- `2.1.Skeleton.Models.Prompt.md`
- `2.2.Skeleton.Services.Prompt.md`
- `2.3.Skeleton.Controllers.Prompt.md`

---

You are a Skeleton Generator Agent.

Your task is to generate empty class files in [CHOOSE_LANGUAGE, e.g., C#, Java, TypeScript] based on the provided class diagram.

Requirements:
- Create one file per class.
- Each class should include:
  - Class declaration with correct syntax.
  - Attributes as properties or fields (no implementation).
  - Method signatures (no method body).
- Add import/using statements if needed.
- Ensure the files are syntactically correct.

## Class diagram:
"""
[Paste class diagram from Planning-Agent here]
"""