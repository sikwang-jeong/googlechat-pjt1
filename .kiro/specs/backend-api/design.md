# Backend API — Design

## Project Structure
```
app/
├── main.py
├── core/config.py, auth.py
├── routers/webhook.py, dialog.py, health.py
├── services/card_builder.py, event_handler.py, db_query.py
├── models/chat_event.py, db.py
├── db/session.py, redis.py
└── tasks/celery_app.py
```

## Auth Flow
```
Google Chat → JWT → Cloud Run → INTERNAL_API_TOKEN → FastAPI
```

## Event Routing
```python
match event.type:
    case "ADDED_TO_SPACE": ...
    case "MESSAGE": ...
    case "CARD_CLICKED": match event.action.function ...
```

## Key Models
```python
class ChatEvent(BaseModel):
    type: str
    user: User | None = None
    action: Action | None = None
    common: dict[str, Any] = {}   # formInputs
    space: dict[str, Any] = {}
    message: dict[str, Any] = {}
```
