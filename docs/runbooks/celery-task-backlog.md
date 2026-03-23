# Runbook: Celery Task Backlog

## Symptoms
- Tasks stuck in `pending` state in `tasks` table
- No response card sent after long wait

## Steps
1. Check Celery worker is running: `docker compose ps celery`
2. Check worker logs: `docker compose logs celery`
3. Check Redis broker is healthy: `docker compose exec redis redis-cli ping`
4. If worker is down: `docker compose up -d celery`
5. If tasks are stuck after max retries, check `tasks` table for `failed` status and notify user manually
