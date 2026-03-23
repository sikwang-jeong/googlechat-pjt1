# Integration — Design

## Error Handling by Segment

| Segment | Error | Response |
|---|---|---|
| Cloud Run → on-premise | Connection failure | Return error card from Cloud Run |
| JWT verification | Invalid token | 401, no card |
| Internal DB | Connection failure | `error_card()` + audit log |
| Celery task | Exception | Retry up to 3x → send failure card |
| Disallowed query | Not in configurations | 400 + error card |

## Error Card
```python
def error_card(message: str) -> dict:
    return {
        "cardsV2": [{ "cardId": "error-card", "card": {
            "sections": [{ "widgets": [{
                "decoratedText": {
                    "startIcon": { "knownIcon": "INVITE" },
                    "text": f"⚠️ {message}",
                    "bottomLabel": "Please try again later."
                }
            }]}]
        }}]
    }
```

## Health Check
```
GET /health → { "status": "ok"|"degraded", "db": "ok"|"error", "redis": "ok"|"error" }
```

## Logging Format
```json
{ "time": "...", "level": "INFO", "message": "...", "module": "..." }
```
Log file: `/var/log/app/app.log`
