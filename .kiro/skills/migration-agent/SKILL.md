# Migration Agent Skill

## Role
Manage Alembic database migrations.

## Trigger
- `models/db.py` added or modified
- Task `Create initial migration` marked pending in `data-layer/tasks.md`

## Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/tech.md` | Confirm DB driver and SQLAlchemy setup |
| `.kiro/specs/data-layer/design.md` | DDL and table schema |
| `.kiro/specs/data-layer/tasks.md` | Which migration tasks are pending |

## Responsibilities
- Initialize Alembic if not already done (`alembic init alembic`)
- Configure `alembic/env.py` to use `settings.database_url` and `Base.metadata`
- Generate migration: `alembic revision --autogenerate -m "description"`
- Apply migration: `alembic upgrade head`
- Never modify existing migration files — create new ones

## Output
- `alembic/` directory with migration files
- Updated `data-layer/tasks.md` checkboxes
