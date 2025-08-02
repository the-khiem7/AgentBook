# VitaFlow Naming Convention

VitaFlow documents keep a numeric-textual pattern so agents can reason about phase, step, and purpose at a glance.

```
[Section].[SubSection].[Stage].[Component].[Type].md
```

## Phase Level
- **Section** – numeric phase identifier (1, 2, 3, 4)
  - 1: Planning
  - 2: Skeleton
  - 3: Implementation
  - 4: Review
- **Stage** – text label that matches the phase name (Planning, Skeleton, Implementation, Review)

## Step Level
- **SubSection** – numeric step within the phase
  - 0: Project overview and roadmap
  - 1: Foundation layer
  - 2: Core layer
  - 3: Feature layer
  - 4: Interface layer
  - 5: Quality layer
- **Component** – descriptive name tuned to the project (Domain, Services, Pages, etc.)

Example mappings:

| Section | Stage          | SubSection | Component    |
|---------|----------------|------------|--------------|
| 1       | Planning       | 0          | Roadmap      |
| 2       | Skeleton       | 1          | Domain       |
| 3       | Implementation | 2          | Data         |
|         |                | 3          | Business     |
|         |                | 4          | Presentation |
|         |                | 5          | Quality      |

## Purpose Level
- **Type** captures the document role:
  - `Prompt.md` – input for an AI agent
  - `Guide.md` – reference for manual or AI execution
  - `Scenarios.md` – example flows and usage notes

## Exceptions
- Roadmaps follow `[Section].0.[Stage].Roadmap.md`, e.g. `3.0.Implementation.Roadmap.md`
- Component names adapt to the domain but should stay consistent within a project

Adhering to this naming scheme keeps prompts, guides, and reference material aligned as you move between phases.

