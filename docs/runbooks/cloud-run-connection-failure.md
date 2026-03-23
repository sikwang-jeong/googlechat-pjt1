# Runbook: Cloud Run → On-Premise Connection Failure

## Symptoms
- Google Chat shows no response after button click
- Cloud Run logs: `502 Upstream error`

## Steps
1. Check on-premise server is running: `docker compose ps`
2. Check FastAPI is healthy: `curl https://your-domain.com/health`
3. Check Caddy is running: `docker compose logs caddy`
4. If FastAPI is down: `docker compose up -d fastapi`
5. Verify `ONPREM_URL` env var in Cloud Run is correct
