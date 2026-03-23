# DB Seed Agent Skill

## Role
Insert initial data into the database after migration.

## Trigger
- `alembic upgrade head` completed
- Task `Insert initial configurations data` marked pending in `data-layer/tasks.md`

## Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/specs/data-layer/design.md` | Table schema and seed data requirements |
| `.kiro/specs/data-layer/tasks.md` | Which seed tasks are pending |
| `.kiro/steering/conventions.md` | No hardcoded secrets |

## Responsibilities
- Insert initial `configurations` row with empty `allowed_queries`
- Do not overwrite existing rows — use `INSERT ... ON CONFLICT DO NOTHING`
- Do not hardcode sensitive values

## Output
- Seed SQL script or Python script under `scripts/`
- Updated `data-layer/tasks.md` checkboxes
