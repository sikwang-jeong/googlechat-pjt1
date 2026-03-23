# Data Layer — Tasks

## Implementation Checklist
- [x] Define table schema
- [x] Define Redis key patterns and TTLs
- [x] Define internal DB connection strategy
- [ ] Implement `db/session.py` (main + internal DB engines)
- [ ] Implement `db/redis.py`
- [ ] Implement `tasks/celery_app.py`
- [ ] Implement `models/db.py` (SQLAlchemy ORM models)
- [ ] Configure Alembic (`alembic init`, `env.py`)
- [ ] Create initial migration (`alembic revision --autogenerate`)
- [ ] Apply migration (`alembic upgrade head`)
- [ ] Insert initial `configurations` data (allowed queries)
- [ ] Set up data retention cron job
