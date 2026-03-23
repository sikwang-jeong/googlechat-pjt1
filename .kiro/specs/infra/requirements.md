# Infra — Requirements

## Requirements
- R1: Docker Compose for on-premise (FastAPI, Celery, PostgreSQL, Redis, Caddy)
- R2: GCP Cloud Run as Google Chat event relay (min 1 instance)
- R3: Caddy as reverse proxy with rate limiting (60 req/min per IP)
- R4: GitLab CI/CD for automated deploy
- R5: Daily pg_dump backup, retain 30 days
- R6: HTTPS only; Cloud Run → on-premise via HTTPS + INTERNAL_API_TOKEN
