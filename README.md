# googlechat-pjt1

Google Chat Card v2 interaction system — internal business data query via Chat UI.

## Stack
Python 3.12 / FastAPI / PostgreSQL / Redis / Celery / Docker Compose / GCP Cloud Run

## Quick Start (Local Dev)

```bash
# 1. Copy env file
cp .env.dev.example .env.dev

# 2. Start services
docker compose -f docker-compose.dev.yml up -d

# 3. Run DB migration
docker compose -f docker-compose.dev.yml exec fastapi alembic upgrade head

# 4. Start ngrok tunnel
ngrok http 8000
```

Register the ngrok URL in Google Chat API console → Configuration → HTTP endpoint URL.

## Docs
- [Local Dev Guide](docs/local-dev-guide.md)
- [API Spec](docs/API-SPEC.md)
- [PRD](docs/PRD.md)

## Project Structure
```
.kiro/          ← Kiro specs, steering, skills, hooks
app/            ← FastAPI source (implemented by Codex)
cloudrun/       ← Cloud Run relay
scripts/        ← Backup and retention scripts
docs/           ← PRD, API spec, runbooks
```
