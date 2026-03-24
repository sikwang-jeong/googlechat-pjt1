# Conventions

## Naming

<!-- PEP 8: https://pep8.org -->
- Files: `snake_case.py`
- Classes: `PascalCase`
- Functions / variables: `snake_case`
- Constants: `UPPER_SNAKE_CASE` (e.g. `MAX_RETRY_COUNT`)
- DB tables: `snake_case` (plural)
- Redis keys: `namespace:type:id` (e.g. `auth:jwt:{hash}`, `session:dialog:{user_id}`)
- Card IDs: `kebab-case` (e.g. `main-card`, `error-card`)

<!-- PEP 8: Exception naming -->
- Exception classes: `PascalCase` + `Error` suffix (e.g. `QueryNotFoundError`)

<!-- PEP 8: Private members -->
- Private functions / variables: `_single_underscore` prefix (e.g. `_build_payload`)

<!-- FastAPI convention: https://cursorrules.org/article/python-fastapi-scalable-api-cursorrules-prompt-fil -->
- Boolean variables: `is_`, `has_`, `can_` prefix (e.g. `is_admin`, `has_permission`)
- Pydantic models: `PascalCase` + `Request` / `Response` suffix (e.g. `QueryRunRequest`)

<!-- Celery convention -->
- Celery task functions: `snake_case`, verb-first (e.g. `run_query`, `send_notification`)

## Code Rules

<!-- PEP 8 / ruff default: https://docs.astral.sh/ruff -->
- Line length: max 88 characters (ruff default)

<!-- PEP 8: Import order (isort) -->
- Import order: stdlib → third-party → local, one import per line

<!-- FastAPI: type hints required for dependency injection -->
- Type hints: required on all function parameters and return values

<!-- PEP 257: https://peps.python.org/pep-0257 -->
- Docstrings: one-line docstring on all public functions

<!-- PEP 8: Exception handling -->
- Exception handling: bare `except:` forbidden — always specify exception type
- `None` comparison: use `is None` / `is not None`, never `== None`

<!-- Python 3.12 convention -->
- String formatting: use f-strings — avoid `%` format and `.format()`

<!-- Project-specific rules -->
- All async functions use `async/await`
- No raw SQL outside `services/db_query.py`
- Only pre-approved queries from `configurations` table allowed for internal DBs
- Secrets via environment variables only — never hardcoded
- All API routes protected by `verify_internal_token` or `verify_google_token` dependency

## Project Structure

<!-- FastAPI best practices: https://sourcetrail.com/python/fastapi-project-structure-and-best-practice-guides/ -->
```
app/
├── core/        # config, auth
├── routers/     # HTTP endpoints
├── services/    # business logic
├── models/      # Pydantic + SQLAlchemy
├── db/          # session, redis
└── tasks/       # Celery
```
