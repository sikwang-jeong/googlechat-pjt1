# Skills Registry

All agent skills for this project. Each skill defines a focused role, trigger, and responsibilities.

---

## dev-agent

### Role
Implement backend features following project conventions.

### Trigger
- New feature spec added under `.kiro/specs/`
- Bug fix required in `app/`

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/product.md` | Understand what we're building |
| `.kiro/steering/tech.md` | Confirm tech stack and drivers |
| `.kiro/steering/conventions.md` | Naming, structure, code rules |
| `.kiro/steering/api-standards.md` | Response format for all endpoints |
| `.kiro/specs/{feature}/requirements.md` | What to implement |
| `.kiro/specs/{feature}/design.md` | How to implement it |
| `.kiro/specs/{feature}/tasks.md` | Which tasks are pending |

### Responsibilities
- Implement routers, services, models per spec
- Only implement tasks marked `[ ]` in `tasks.md`
- Do not modify test files unless explicitly asked
- Do not hardcode secrets

### Output
- Working Python code under `app/`
- Updated `tasks.md` checkboxes (`[ ]` → `[x]`) for completed tasks

---

## qa-agent

### Role
Verify implemented features against spec requirements.

### Trigger
- `tasks.md` checkboxes marked complete
- PR opened for review

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/api-standards.md` | Expected response formats |
| `.kiro/steering/conventions.md` | Code and naming rules to enforce |
| `.kiro/specs/{feature}/requirements.md` | What should be implemented |
| `.kiro/specs/{feature}/design.md` | How it should be implemented |
| `.kiro/specs/{feature}/tasks.md` | What was marked complete |

### Responsibilities
- Check implementation matches `requirements.md` and `design.md`
- Verify API responses conform to `api-standards.md`
- Flag missing error handling or security issues

### Output
- Review comments on code
- Updated `tasks.md` with QA status

---

## deploy

### Role
Deploy the application to on-premise and Cloud Run environments.

### Trigger
- `main` branch push after QA pass
- Manual deploy request

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/tech.md` | Confirm stack and environment |
| `.kiro/specs/infra/design.md` | Docker Compose, Cloud Run, Caddy setup |
| `.kiro/specs/infra/tasks.md` | Which deploy tasks are pending |

### Responsibilities
- Run `docker compose up -d --build` on on-premise server
- Deploy Cloud Run relay via `gcloud run deploy`
- Run `alembic upgrade head` after deploy
- Verify `/health` endpoint responds `200`

### Output
- Deployment log
- Updated deploy checklist

---

## migration-agent

### Role
Manage Alembic database migrations.

### Trigger
- `models/db.py` added or modified
- Task `Create initial migration` marked pending in `data-layer/tasks.md`

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/tech.md` | Confirm DB driver and SQLAlchemy setup |
| `.kiro/specs/data-layer/design.md` | DDL and table schema |
| `.kiro/specs/data-layer/tasks.md` | Which migration tasks are pending |

### Responsibilities
- Initialize Alembic if not already done
- Configure `alembic/env.py` to use `settings.database_url` and `Base.metadata`
- Generate migration: `alembic revision --autogenerate -m "description"`
- Apply migration: `alembic upgrade head`
- Never modify existing migration files — create new ones

### Output
- `alembic/` directory with migration files
- Updated `data-layer/tasks.md` checkboxes

---

## db-seed-agent

### Role
Insert initial data into the database after migration.

### Trigger
- `alembic upgrade head` completed
- Task `Insert initial configurations data` marked pending in `data-layer/tasks.md`

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/specs/data-layer/design.md` | Table schema and seed data requirements |
| `.kiro/specs/data-layer/tasks.md` | Which seed tasks are pending |
| `.kiro/steering/conventions.md` | No hardcoded secrets |

### Responsibilities
- Insert initial `configurations` row with empty `allowed_queries`
- Use `INSERT ... ON CONFLICT DO NOTHING`
- Do not hardcode sensitive values

### Output
- Seed SQL or Python script under `scripts/`
- Updated `data-layer/tasks.md` checkboxes

---

## code-reviewer

### Role
Review code for conventions compliance, code quality, and potential issues.

### Trigger
- PR opened
- Manual review request on `app/` files

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/conventions.md` | Naming, code rules, line length, type hints |
| `.kiro/steering/api-standards.md` | Response format compliance |

### Responsibilities
- Check naming conventions (snake_case, PascalCase, UPPER_SNAKE_CASE)
- Verify type hints on all function parameters and return values
- Check line length ≤ 88 characters
- Flag bare `except:`, `== None`, hardcoded secrets
- Verify all routes have `verify_internal_token` or `verify_google_token`

### Output
- Review comments categorized as ✅ OK / ⚠️ Warning / 🔴 Must Fix

---

## security-audit

### Role
Audit codebase for security vulnerabilities and compliance issues. Read-only.

### Trigger
- Pre-release audit request
- New route or auth logic added

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/conventions.md` | Secrets via env vars only |
| `.kiro/specs/backend-api/design.md` | Auth flow and route protection |

### Responsibilities
- Search for hardcoded secrets (API keys, passwords, tokens)
- Check all routes are protected by auth dependency
- Verify no raw SQL outside `services/db_query.py`
- Check only pre-approved queries used for internal DBs
- Do not modify any files

### Output
- Security findings with severity (Critical / High / Medium / Low) and file:line reference

---

## api-doc-generator

### Role
Generate OpenAPI documentation from FastAPI routers.

### Trigger
- New router added or endpoint signature changed
- Manual doc generation request

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/api-standards.md` | Response format and status codes |
| `.kiro/specs/backend-api/design.md` | Endpoint list |

### Responsibilities
- Extract all routes from `app/routers/`
- Document request/response schemas with status codes
- Include auth requirements per endpoint
- Generate OpenAPI 3.0 spec or update `docs/API-SPEC.md`

### Output
- Updated `docs/API-SPEC.md`

---

## env-validator

### Role
Validate environment variable consistency between `.env.dev.example` and running config.

### Trigger
- New env var added to any design.md
- Before deploy

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/specs/infra/design.md` | Environment variable table |
| `.kiro/specs/monitoring/design.md` | `MONITORING_SPACE_NAME` |
| `app/core/config.py` | All required env vars |

### Responsibilities
- Compare `.env.dev.example` keys against `app/core/config.py` fields
- Flag missing or undocumented env vars
- Check `infra/design.md` env var table is up to date

### Output
- List of missing / undocumented / stale env vars

---

## rollback-agent

### Role
Roll back failed deployments — Alembic downgrade and Docker image revert.

### Trigger
- Deploy failure detected (`/health` returns non-200)
- Manual rollback request

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/specs/infra/design.md` | Docker Compose services |
| `.kiro/specs/data-layer/design.md` | Migration history |

### Responsibilities
- Run `alembic downgrade -1` to revert last migration
- Revert Docker image to previous tag via `docker compose`
- Verify `/health` returns `200` after rollback
- Write rollback log to `docs/runbooks/`

### Output
- Rollback log
- Updated `docs/runbooks/rollback.md`

---

## card-builder-agent

### Role
Implement card templates in `card_builder.py`.

### Trigger
- Task `Add build_template()` marked pending in `admin/tasks.md`

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/specs/admin/design.md` | Template catalog (A~L, 12 templates) and TEMPLATE_SAMPLES |
| `.kiro/specs/card-interaction/design.md` | Widget patterns, card structure |
| `.kiro/steering/api-standards.md` | cardsV2 wrapper, cardId kebab-case |

### Responsibilities
- Implement `build_template(name: str, data: dict) -> dict` in `card_builder.py`
- Define `TEMPLATE_SAMPLES` dict for all 12 templates
- Follow cardId kebab-case convention (e.g. `monitoring-card`, `error-card`)
- Do not modify existing `error_card()` function

### Output
- Updated `app/services/card_builder.py`
- Updated `admin/tasks.md` checkboxes

---

## celery-agent

### Role
Implement Celery tasks, Beat schedule, and retry configuration.

### Trigger
- Task marked pending in `integration/tasks.md` or `monitoring/tasks.md`

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/specs/integration/design.md` | Celery failure notification, retry (3x) |
| `.kiro/specs/monitoring/design.md` | Beat schedule (05:00, 17:00 KST) |
| `.kiro/steering/conventions.md` | Celery task naming: verb-first snake_case |

### Responsibilities
- Implement tasks in `app/tasks/`
- Register Beat schedule in `tasks/celery_app.py`
- Set max retries to 3, implement failure notification via Chat REST API
- Use `GOOGLE_APPLICATION_CREDENTIALS` for auth — never hardcode

### Output
- `app/tasks/monitoring.py`, updated `app/tasks/celery_app.py`
- Updated tasks.md checkboxes

---

## monitoring-agent

### Role
Implement DB health check and Chat monitoring card delivery.

### Trigger
- Tasks marked pending in `monitoring/tasks.md`

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/specs/monitoring/design.md` | Task flow, card structure, env vars |
| `.kiro/specs/data-layer/design.md` | Internal DB drivers (asyncpg, oracledb, aiomysql) |
| `.kiro/steering/conventions.md` | async/await, no raw SQL outside db_query.py |

### Responsibilities
- Implement `app/services/db_health.py` — connection check per driver (timeout 5s)
- Implement `app/tasks/monitoring.py` — aggregate results + send card
- Add `monitoring_detail` dialog handler to `routers/dialog.py`

### Output
- `app/services/db_health.py`, `app/tasks/monitoring.py`
- Updated `monitoring/tasks.md` checkboxes

---

## admin-agent

### Role
Implement in-Chat admin Dialog UI for query management.

### Trigger
- Tasks marked pending in `admin/tasks.md`

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/specs/admin/design.md` | Dialog flow, CRUD endpoints, auth check |
| `.kiro/specs/backend-api/design.md` | MESSAGE keyword routing, CARD_CLICKED routing |
| `.kiro/steering/conventions.md` | Naming, async/await |

### Responsibilities
- Implement `app/services/admin_service.py` — `is_admin(google_id)` check
- Add `관리` keyword to `event_handler.py`
- Add admin dialog handlers to `routers/dialog.py`
- Use `configurations.admin_users` for authorization — never hardcode user list

### Output
- `app/services/admin_service.py`
- Updated `app/services/event_handler.py`, `app/routers/dialog.py`
- Updated `admin/tasks.md` checkboxes

---

## lint-agent

### Role
Run and fix ruff lint and format issues across `app/`.

### Trigger
- Pre-commit or pre-push
- Manual lint request

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/conventions.md` | Line length 88, import order, f-string rules |

### Responsibilities
- Run `ruff check app/ --fix`
- Run `ruff format app/`
- Report unfixable issues with file:line reference
- Do not change logic — formatting and import order only

### Output
- Fixed files under `app/`
- List of remaining unfixable issues

---

## changelog-maintainer

### Role
Generate and maintain `CHANGELOG.md` from git log.

### Trigger
- Before release tag
- Manual changelog update request

### Responsibilities
- Parse `git log` since last tag
- Group commits by type: `feat`, `fix`, `docs`, `refactor`
- Append new section to `CHANGELOG.md` with date and version
- Follow [Keep a Changelog](https://keepachangelog.com) format

### Output
- Updated `CHANGELOG.md`
