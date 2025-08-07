# AgentBook

AgentBook is an AI-first handbook for running a four-phase delivery loop with dedicated agents. All prompts, playbooks, and operations guides now sit at the repository root so each agent can jump straight into the material they need.

## Multi-Agent Pipeline
- Planning Agent - turn feature requests into class diagrams and data flow
- Skeleton Agent - generate compilable project scaffolding
- Implement Agent - fill in logic, persistence, and integration layers
- Review Agent - audit quality, conventions, and test coverage

Follow the phases in order for greenfield work, or drop into a single phase if you only need targeted help.

## Documentation Map
- `agents/core` - canonical prompts for the four core agents
- `agents/razor-pages` - ASP.NET Razor Pages variants of the same prompts
- `playbooks/vitaflow` - VitaFlow delivery playbook with phase roadmaps, prompts, guides, and scenarios
- `operations` - task breakers, GitHub automation, and agile pipeline helpers
- `platform/github` - Copilot instructions and platform guardrails

Each folder is summarized in `HANDBOOK.md`.

## Getting Started
1. Read the relevant prompt in `agents/core` (or the Razor Pages variant).
2. Use the matching VitaFlow phase material for detailed steps, dataset assumptions, and scaffolding.
3. Run operational helpers in `operations` when you need to slice work, automate issues, or organize releases.
4. Cross-check the GitHub platform notes before triggering automation or Copilot sidekicks.

## Model Pairing
| Phase         | Preferred model            | Alternatives |
|---------------|---------------------------|--------------|
| Planning      | Claude Sonnet 3.7 Thinking | Claude Sonnet 4 |
| Skeleton      | GPT-4o                     | o3-mini |
| Implementation| GPT-4.1                    | GPT-4o |
| Review        | Gemini 2.5 Pro             | Claude Sonnet 4 |

Select the primary model whenever possible. The alternatives keep the prompts usable if capacity or access changes.

## Naming Convention Reference
Numbered naming such as `2.1.Skeleton.ProjectStructure.Prompt.md` still appears inside the VitaFlow playbook. The full scheme - sections, subsections, stages, and document types - is documented in `playbooks/vitaflow/naming-convention.md`.

## VitaFlow Overview
The VitaFlow playbook contains:
- `index.md` - quick orientation for new contributors
- `reference.md` - product brief and requirements background
- `milestones.md` - suggested milestone roadmap for phased delivery
- `phases/` - planning, skeleton, and implementation folders with prompts, guides, and scenarios packaged together

Use VitaFlow when you need an end-to-end delivery template. For lighter engagements you can reference only the agent prompts and operations helpers.

## Next Steps
Clone the repository, open `HANDBOOK.md`, and feed the chosen prompt directly into your agent. Keep commits small by leaning on the task breakers and GitHub automation guides.
