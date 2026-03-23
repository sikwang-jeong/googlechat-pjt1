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

## CI/CD (GitLab)
```
push to main
  → test stage: pytest
  → deploy-onprem: ssh + docker compose up -d --build
  → deploy-cloudrun: gcloud run deploy
```
