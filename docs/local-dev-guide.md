# Local Development Guide

## Architecture (dev)
```
Google Chat → ngrok (public URL) → localhost:8000 (FastAPI)
```
No Cloud Run, no Caddy, no on-premise in dev.

## Setup

### 1. Start services
```bash
docker compose -f docker-compose.dev.yml up -d
```

### 2. Run DB migration
```bash
docker compose -f docker-compose.dev.yml exec fastapi alembic upgrade head
```

### 3. Start ngrok tunnel
```bash
ngrok http 8000
```
Copy the `https://xxxx.ngrok-free.app` URL.

### 4. Register webhook in Google Chat API
Google Cloud Console → Chat API → Configuration → HTTP endpoint URL:
```
https://xxxx.ngrok-free.app/webhook/chat
```
Update this URL every time ngrok restarts.

## Auth in Dev
`core/auth.py` checks `INTERNAL_API_TOKEN`.
In dev, Google Chat events come directly (no Cloud Run relay), so skip token check for local testing:

```python
# Temporarily bypass for local dev
async def verify_internal_token(request: Request):
    if os.getenv("ENV") == "dev":
        return
    ...
```

Set in `.env.dev`:
```
ENV=dev
```

## On-Premise Internal DBs
Leave `INTERNAL_PG_URL`, `ORACLE_DSN`, `MYSQL_URL` empty until VPN is connected.
Services that depend on internal DBs will return an error card gracefully.

## Switching to Production
Replace `docker-compose.dev.yml` → `docker-compose.yml`
Replace `.env.dev` → `.env`
Add Cloud Run relay in front.
