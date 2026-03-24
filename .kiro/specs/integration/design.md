# Integration — Design

## Error Handling by Segment

| Segment | Error | Response |
|---|---|---|
| Cloud Run → on-premise | Connection failure | Return error card from Cloud Run |
| JWT verification | Invalid token | 401, no card |
| Internal DB | Connection failure | `error_card()` + audit log |
| Celery task | Exception | Retry up to 3x → send failure card |
| Disallowed query | Not in configurations | 400 + error card |

## Celery Failure Notification

After max retries (3x), the Celery worker sends a failure card directly via Google Chat REST API.

- Auth: `GOOGLE_APPLICATION_CREDENTIALS` env var (service account key file)
- Target: original `space_name` + `thread_name` stored in task payload
- Method: `spaces.messages.create` with `messageReplyOption=REPLY_MESSAGE_FALLBACK_TO_NEW_THREAD`

Task payload must include:
```json
{
  "query_key": "sales_summary",
  "params": { "start_date": "2026-01-01" },
  "space_name": "spaces/xxx",
  "thread_name": "spaces/xxx/threads/yyy",
  "user_google_id": "xxx",
  "message_name": "spaces/xxx/messages/yyy"
}
```

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
