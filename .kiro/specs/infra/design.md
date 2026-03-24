# Infra — Design

## Architecture
```
[Google Chat]
     │ HTTPS POST
     ▼
[Cloud Run]  ← min 1 instance, event type routing
     │ HTTPS + INTERNAL_API_TOKEN
     ▼
[Caddy]  ← TLS termination, rate limiting
     │
     ▼
[FastAPI]  ← JWT verification, event handling
  │    └── sync response → Card JSON
  └── async → [Celery Worker] → [PostgreSQL / Internal DBs]
                                [Redis]
```

## Cloud Run Relay Design

### Stack
FastAPI (Python 3.12) — consistent with on-premise stack.

### Flow
```
Google Chat → Cloud Run (JWT verify) → on-premise (HTTPS + INTERNAL_API_TOKEN)
```

### JWT Verification
- Cloud Run verifies Google Chat JWT before forwarding
- Invalid JWT → 401, no forwarding

### On-premise Connection Failure
- Timeout or connection error → return error_card JSON with HTTP 200
- Ensures Google Chat does not retry

### cloudrun/main.py structure
```
POST /webhook/chat        → verify JWT → forward to on-premise /webhook/chat
POST /webhook/chat/dialog → verify JWT → forward to on-premise /webhook/chat/dialog
GET  /health              → return {"status": "ok"}
```

### Environment Variables
| Var | Purpose |
|---|---|
| `ONPREM_BASE_URL` | on-premise FastAPI base URL |
| `INTERNAL_API_TOKEN` | Bearer token for on-premise auth |
| `GOOGLE_CHAT_AUDIENCE` | Expected JWT audience (Cloud Run URL) |

## Docker Compose Services

| Service | Image | Role |
|---|---|---|
| fastapi | custom | API server |
| celery | custom | Background worker |
| postgres | postgres:16-alpine | Main DB |
| redis | redis:7-alpine | Cache + broker |
| caddy | caddy:2-alpine | Reverse proxy |

## Cloud Run
- Region: asia-northeast3
- Min instances: 1
- Role: relay only (forward to on-premise)
- Estimated cost: $5–10/month

## Caddy Rate Limiting

Plugin: `caddy-ratelimit` (github.com/mholt/caddy-ratelimit) — built via `xcaddy`.

```caddyfile
{
    order rate_limit before basicauth
}

:443 {
    tls /etc/caddy/certs/cert.pem /etc/caddy/certs/key.pem

    rate_limit {
        zone dynamic {
            key {remote_host}
            events 60
            window 1m
        }
    }

    reverse_proxy fastapi:8000
}
```

Rate limit exceeded → HTTP 429 (Too Many Requests).

## CI/CD (GitLab)
```
push to main
  → test stage: pytest
  → deploy-onprem: ssh + docker compose up -d --build
  → deploy-cloudrun: gcloud run deploy
```
