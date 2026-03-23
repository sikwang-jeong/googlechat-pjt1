# Runbook: Internal DB Connection Failure

## Symptoms
- Chat returns error card: "⚠️ ..."
- Logs show DB connection error

## Steps
1. Check internal DB is reachable from on-premise server
2. Verify connection string in `.env` (`INTERNAL_PG_URL`, `ORACLE_DSN`, `MYSQL_URL`)
3. Check DB credentials have not expired
4. Restart FastAPI to reset connection pool: `docker compose restart fastapi`
