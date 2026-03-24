# Skills Registry

---

## dev-agent

### Role
Implement all backend features: API, Celery tasks, card templates, admin dialog, monitoring.

### Trigger
- Task marked `[ ]` in any `tasks.md` under `.kiro/specs/`
- Bug fix required in `app/`

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/tech.md` | Tech stack and drivers |
| `.kiro/steering/conventions.md` | Naming, code rules |
| `.kiro/steering/api-standards.md` | Response format |
| `.kiro/specs/{feature}/requirements.md` | What to implement |
| `.kiro/specs/{feature}/design.md` | How to implement |
| `.kiro/specs/{feature}/tasks.md` | Which tasks are pending |

### Responsibilities
- Implement routers, services, models, Celery tasks per spec
- Only implement tasks marked `[ ]` in `tasks.md`
- Do not hardcode secrets — use env vars only
- Do not modify test files unless explicitly asked

### Output
- Working Python code under `app/`
- Updated `tasks.md` checkboxes (`[ ]` → `[x]`)

---

## qa-agent

### Role
Verify implementation against spec, review code quality, and audit security.

### Trigger
- `tasks.md` checkboxes marked complete
- PR opened for review
- New route or auth logic added

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/conventions.md` | Naming, type hints, line length, code rules |
| `.kiro/steering/api-standards.md` | Response format and status codes |
| `.kiro/specs/{feature}/requirements.md` | What should be implemented |
| `.kiro/specs/{feature}/design.md` | How it should be implemented |

### Responsibilities
- Verify implementation matches `requirements.md` and `design.md`
- Check naming conventions, type hints, line length ≤ 88
- Flag bare `except:`, `== None`, hardcoded secrets
- Verify all routes protected by `verify_internal_token` or `verify_google_token`
- Check no raw SQL outside `services/db_query.py`

### Output
- Review comments: ✅ OK / ⚠️ Warning / 🔴 Must Fix
- Updated `tasks.md` with QA status

---

## deploy-agent

### Role
Deploy, roll back, validate environment variables, and manage DB migrations.

### Trigger
- `main` branch push after QA pass
- Deploy failure detected (`/health` non-200)
- New env var added to any `design.md`
- `models/db.py` added or modified

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/tech.md` | Stack and environment |
| `.kiro/specs/infra/design.md` | Docker Compose, Cloud Run, Caddy |
| `.kiro/specs/data-layer/design.md` | DDL and migration schema |
| `app/core/config.py` | Required env vars |

### Responsibilities
- Run `docker compose up -d --build` on on-premise server
- Deploy Cloud Run relay via `gcloud run deploy`
- Run `alembic upgrade head` after deploy; `alembic downgrade -1` on rollback
- Compare `.env.dev.example` vs `app/core/config.py` — flag missing vars
- Verify `/health` returns `200` after deploy or rollback

### Output
- Deployment or rollback log
- Updated `docs/runbooks/rollback.md` on rollback
- List of missing / undocumented env vars

---

## docs-agent

### Role
Generate and maintain API documentation, CHANGELOG, and spec lint.

### Trigger
- New router added or endpoint signature changed
- Before release tag
- Manual doc update request

### Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/api-standards.md` | Response format and status codes |
| `.kiro/specs/backend-api/design.md` | Endpoint list |

### Responsibilities
- Extract all routes from `app/routers/` → update `docs/API-SPEC.md`
- Parse `git log` since last tag → append section to `CHANGELOG.md`
- Run `ruff check app/ --fix` and `ruff format app/` — formatting only, no logic changes
- Group changelog entries by type: `feat`, `fix`, `docs`, `refactor`

### Output
- Updated `docs/API-SPEC.md`
- Updated `CHANGELOG.md`
- Ruff-fixed files under `app/`
