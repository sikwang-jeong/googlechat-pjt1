# Tech Stack

| Layer | Choice |
|---|---|
| Backend | Python 3.12 + FastAPI |
| DB (main) | PostgreSQL 16 + asyncpg + SQLAlchemy async |
| DB (internal) | PostgreSQL (asyncpg), Oracle (python-oracledb), MySQL (aiomysql) |
| Cache / Broker | Redis 7 |
| Task Queue | Celery |
| Migration | Alembic |
| Reverse Proxy | Caddy 2 |
| Container | Docker Compose |
| Cloud | GCP Cloud Run (relay only) |
| On-premise | VM + Docker Compose |
| CI/CD | GitLab CI/CD |
