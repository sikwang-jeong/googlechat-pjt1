# Product Requirements Document

## Product
Google Chat Card Interaction System

## Background
Internal tool for querying and processing business data through Google Chat Card v2 UI.

## Scope
- Card v2 interactive messages (buttons, forms, dialogs)
- Integration with internal DBs (PostgreSQL, Oracle, MySQL)
- Async task processing via Celery
- On-premise deployment + GCP Cloud Run relay

## System Flow
```
[Google Chat] → [Cloud Run relay] → [Caddy] → [FastAPI] → sync response
                                                         → [Celery] → [Internal DBs]
```

## Stage Summary

| Stage | Scope | Status |
|---|---|---|
| 1 | Card v2 design + webhook setup | ✅ Done |
| 2 | FastAPI backend | ✅ Done |
| 3 | Data layer (DB, Redis, Celery) | ✅ Done |
| 4 | Infra (Docker, Cloud Run, CI/CD) | 🔲 In progress |
| 5 | Integration + error handling + logging | 🔲 Pending |

## Deploy Checklist
1. Set `.env` (DB URL, Redis URL, tokens)
2. Activate Google Chat API, create service account, deploy Cloud Run
3. Run `docker compose up -d --build` on on-premise
4. Run `alembic upgrade head`, insert initial `configurations` data
5. Register webhook URL in Google Chat API config
6. Verify `GET /health` returns 200
7. Test JWT verification with real Chat event
8. Verify Celery task execution and retry logs
9. Register `backup.sh` in crontab
10. Verify GitLab CI/CD pipeline on `main` push
