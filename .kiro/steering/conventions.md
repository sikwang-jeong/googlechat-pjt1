# Conventions

## Naming
- Files: `snake_case.py`
- Classes: `PascalCase`
- Functions / variables: `snake_case`
- DB tables: `snake_case` (plural)
- Redis keys: `namespace:type:id` (e.g. `auth:jwt:{hash}`, `session:dialog:{user_id}`)
- Card IDs: `kebab-case` (e.g. `main-card`, `error-card`)

## Code Rules
- All async functions use `async/await`
- No raw SQL outside `services/db_query.py`
- Only pre-approved queries from `configurations` table allowed for internal DBs
- Secrets via environment variables only — never hardcoded
- All API routes protected by `verify_internal_token` or `verify_google_token` dependency

## Project Structure
```
app/
├── core/        # config, auth
├── routers/     # HTTP endpoints
├── services/    # business logic
├── models/      # Pydantic + SQLAlchemy
├── db/          # session, redis
└── tasks/       # Celery
```
