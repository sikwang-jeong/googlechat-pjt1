# Integration — Requirements

## Requirements
- R1: End-to-end message flow: Google Chat → Cloud Run → FastAPI → response
- R2: Per-segment error handling with user-facing error cards
- R3: Celery task retry: max 3 times, 60s delay
- R4: Structured JSON logging to file
- R5: `/health` endpoint checks DB and Redis connectivity
- R6: Uptime monitoring via health check endpoint
