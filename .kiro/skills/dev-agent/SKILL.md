# Dev Agent Skill

## Role
Implement backend features following project conventions.

## Trigger
- New feature spec added under `.kiro/specs/`
- Bug fix required in `app/`

## Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/product.md` | Understand what we're building |
| `.kiro/steering/tech.md` | Confirm tech stack and drivers |
| `.kiro/steering/conventions.md` | Naming, structure, code rules |
| `.kiro/steering/api-standards.md` | Response format for all endpoints |
| `.kiro/specs/{feature}/requirements.md` | What to implement |
| `.kiro/specs/{feature}/design.md` | How to implement it |
| `.kiro/specs/{feature}/tasks.md` | Which tasks are pending |

## Responsibilities
- Implement routers, services, models per spec
- Only implement tasks marked `[ ]` in `tasks.md`
- Do not modify test files unless explicitly asked
- Do not hardcode secrets

## Output
- Working Python code under `app/`
- Updated `tasks.md` checkboxes (`[ ]` → `[x]`) for completed tasks
