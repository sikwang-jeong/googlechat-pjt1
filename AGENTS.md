# AGENTS.md — Codex Agent Instructions

## Project Overview
Google Chat Card v2 interaction system.
Internal users query and process business data via Chat Card UI.

## Stack
Python 3.12 / FastAPI / PostgreSQL / Redis / Celery / Docker Compose / GCP Cloud Run

## Key References (read before coding)
- `.kiro/steering/conventions.md` — naming rules, code style, project structure
- `.kiro/steering/api-standards.md` — response formats (card, dialog, text)
- `.kiro/steering/tech.md` — tech stack details
- `.kiro/specs/backend-api/design.md` — endpoints, event routing, i18n flow
- `.kiro/specs/admin/design.md` — admin dialogs, i18n strings, alert actions, user permissions
- `.kiro/specs/card-interaction/design.md` — card JSON structure, widget patterns, alert card
- `.kiro/specs/data-layer/design.md` — DB schema (DDL), Redis key patterns
- `.kiro/specs/integration/design.md` — error handling, Celery failure, health check
- `.kiro/specs/monitoring/design.md` — Celery Beat schedule, DB health check
- `.kiro/specs/infra/design.md` — Docker Compose, Cloud Run relay, Caddy

## Project Structure
```
app/
├── main.py
├── core/config.py, auth.py
├── routers/webhook.py, dialog.py, health.py, alert.py
├── services/card_builder.py, event_handler.py, db_query.py, admin_service.py
├── models/chat_event.py, db.py
├── db/session.py, redis.py
├── tasks/celery_app.py, monitoring.py
└── templates/alert.html
```

## Implementation Rules

### General
- All async functions use `async/await`
- Type hints required on all function parameters and return values
- One-line docstring on all public functions
- No raw SQL outside `services/db_query.py`
- Secrets via environment variables only — never hardcoded
- All API routes protected by `verify_internal_token` or `verify_google_token` dependency

### Card Builder
- All card text must go through `i18n(key, locale)` helper
- Default locale: `"en"`
- Locale resolved from `users.locale` per request
- `build_template(name, data, locale="en")` is the single entry point for all card JSON

### Event Handler
- MESSAGE keywords: `query`, `help`, `settings`, `admin` (see backend-api/design.md)
- `settings` → open `user_settings` dialog (all users)
- `admin` → check `is_admin()` → open `admin_main` dialog or return "Unauthorized."
- Before executing `run_query`: check `can_run_query(google_id)`
- Before executing any CARD_CLICKED: check Redis `executed:{message_name}:{function}` for duplicate

### run_query Flow
1. Return progress card immediately (sync)
2. Dispatch Celery task with full payload (query_key, params, space_name, thread_name, user_google_id, message_name)
3. Celery task stores `query_start:{task_id}` in Redis
4. On completion: send result card via Chat REST API with `Completed in {elapsed}s`

### Admin Service (`admin_service.py`)
- `is_admin(google_id)` — check `configurations.admin_users`
- `can_run_query(google_id)` — check `configurations.user_permissions[google_id].can_run_query` (default: True)
- Admin users always bypass `can_run_query` check

### Alert Flow
- `POST /webhook/alert` → save to `alerts` table → lookup `alert_actions[alert_code]` → send card
- Alert card: always has `[상세 보기 →]` openLink button; add `[{action_label}]` if action exists
- `GET /report/{alert_id}` → render `templates/alert.html` with Jinja2

### Celery Failure
- After max retries (3x): send failure card via Chat REST API using `GOOGLE_APPLICATION_CREDENTIALS`
- Target: `space_name` + `thread_name` from task payload

### i18n Strings
- All locale strings defined in `STRINGS` dict in `card_builder.py` (or `services/i18n.py`)
- Keys and values: see `.kiro/specs/admin/design.md` → Locale String Structure

## Do NOT
- Write raw SQL outside `db_query.py`
- Hardcode secrets or tokens
- Add tests unless explicitly requested
- Modify existing tests unless explicitly requested
- Use `%` format or `.format()` — use f-strings only
- Use bare `except:` — always specify exception type
- Compare with `== None` — use `is None`
