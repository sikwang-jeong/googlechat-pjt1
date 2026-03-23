# Backend API — Requirements

## Requirements
- R1: `POST /webhook/chat` — receive and route all Chat events
- R2: `POST /webhook/chat/dialog` — handle dialog form submissions
- R3: `GET /health` — health check endpoint
- R4: Verify internal token (Cloud Run → on-premise)
- R5: Route events by type: `ADDED_TO_SPACE`, `MESSAGE`, `CARD_CLICKED`
- R6: Dispatch heavy tasks to Celery asynchronously
