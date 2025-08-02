# VitaFlow Playbook

VitaFlow is a delivery blueprint that walks an agent team from planning through implementation. Each phase bundles the prompts, guides, and scenarios required to keep the build synchronized.

## Phase Map
- `phases/planning/01-requirements-prompt.md` - capture the product ask and constraints
- `phases/planning/02-output-guide.md` - describe the expected planning deliverables
- `phases/skeleton/00-roadmap.md` - outline the skeleton milestones
- `phases/skeleton/01-project-structure-prompt.md` - generate the project layout prompt
- `phases/skeleton/02-domain-prompt.md` - drive domain layer scaffolding
- `phases/skeleton/03-repositories-prompt.md` - prepare persistence scaffolding
- `phases/skeleton/04-services-prompt.md` - define service interfaces
- `phases/skeleton/05-page-models-prompt.md` - create Razor Page models
- `phases/implementation/00-roadmap.md` - align on implementation milestones
- `phases/implementation/01-repository/*` - prompts, guides, and scenarios for repository logic
- `phases/implementation/02-services/*` - prompts and guides for service logic
- `phases/implementation/03-page-models/*` - prompts and guides for Razor Page models
- `phases/implementation/04-ui/*` - prompts and guides for UI composition
- `phases/implementation/05-testing/*` - prompts and guides for automated tests

## Supporting Docs
- `reference.md` - product brief and requirements background
- `naming-convention.md` - document naming scheme used across VitaFlow
- `milestones.md` - recommended milestone breakdown for phased releases

## Suggested Flow
1. Start with the planning prompts to capture scope and architectural direction.
2. Move into the skeleton prompts to build a compile-ready foundation.
3. Use the implementation folders to flesh out logic, UI, and tests, referencing the paired guides and scenarios.
4. Feed results back to the core agent prompts in `agents/core` to coordinate cross-agent collaboration.

## Tips for Agents
- Keep prompts and guides side-by-side in your workspace so reasoning and execution stay aligned.
- Update the roadmap documents with project-specific notes as you progress through milestones.
- Branch out to the operations helpers in `operations` when you need issue slicing or automation.
