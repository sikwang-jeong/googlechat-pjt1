# Integration — Tasks

## Implementation Checklist
- [x] Define end-to-end message flow
- [x] Define error handling strategy per segment
- [x] Define health check design
- [x] Define logging format
- [ ] Implement `services/card_builder.py` error_card
- [ ] Implement extended `/health` with DB + Redis checks
- [ ] Implement `core/logging.py` JSON formatter
- [ ] End-to-end test: Chat → Cloud Run → FastAPI → response
- [ ] Verify Celery retry behavior (3x max)
- [ ] Verify failure card sent after max retries
