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

## Endpoints
- `POST /webhook/chat` — receive and route all Chat events
- `POST /webhook/chat/dialog` — handle dialog form submissions
- `GET /health` — health check

## Auth Flow
```
Google Chat → JWT → Cloud Run → INTERNAL_API_TOKEN → FastAPI
```

### Route Protection
- `/webhook/chat`, `/webhook/chat/dialog` — protected by `verify_internal_token` dependency
- Cloud Run endpoints — protected by `verify_google_token` (JWT) dependency

## Event Routing
```python
match event.type:
    case "ADDED_TO_SPACE": ...
    case "MESSAGE": ...
    case "CARD_CLICKED": match event.action.function ...
```

## Event Response Spec

### ADDED_TO_SPACE
- Response: welcome card (header + usage guide TextParagraph)

### REMOVED_FROM_SPACE
- Action: write audit log only → return `{}`

### MESSAGE
| Keyword | Response |
|---|---|
| `query` | Query selection card (SelectionInput + submit button) |
| `help` | Usage guide card (TextParagraph) |
| `settings` | User settings dialog (locale change — all users) |
| `admin` | Admin main dialog (admin users only) |
| other | Usage guide card (fallback) |

### CARD_CLICKED — action.function routing
| function | Action |
|---|---|
| `open_dialog` | Open dialog (`DIALOG` actionResponse) |
| `run_query` | Execute query → Celery async → result card |
| `refresh_card` | Refresh current card (sync update) |
| other | Return `error-card` (cardId: `error-card`) |

### Celery Task Payload (run_query)
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

## Duplicate Execution Prevention (Shared Space)

In shared spaces, multiple users can see and click the same card message.
To prevent duplicate execution:

### Detection
- Key: `executed:{message_name}:{function}` in Redis
- Value: `{ "display_name": "...", "google_id": "..." }` (first executor)
- TTL: 1 hour

### Flow
1. On `CARD_CLICKED`, check Redis key existence
2. If key exists → return text response: "Already processed. (@{display_name} executed this.)"
3. If key not exists → set Redis key → proceed with execution

### Response for duplicate click (visible to clicker only)
```json
{ "text": "Already processed. (@홍길동 executed this.)" }
```

## Internal DB Routing

`configurations.allowed_queries` JSONB structure:
```json
{
  "allowed_queries": {
    "sales_summary": {
      "db": "postgres",
      "sql": "SELECT ... WHERE date >= :start_date",
      "allowed_params": ["start_date"]
    },
    "inventory": {
      "db": "oracle",
      "sql": "SELECT ... WHERE item_id = :item_id",
      "allowed_params": ["item_id"]
    }
  }
}
```

### Execution Flow
1. Look up `query_key` in `allowed_queries` → 400 if not found
2. Validate request params against `allowed_params` → 400 if invalid
3. Select target DB from `db` field (postgres / oracle / mysql)
4. Execute SQL with bound params

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

## i18n Card Rendering

All card text is rendered in the user's locale at build time.

### Flow
```
event received
  → resolve user.google_id
  → fetch users.locale from DB (default: "en")
  → pass locale to build_template(name, data, locale)
  → card_builder.py calls i18n(key, locale) for all text strings
  → return localized card JSON
```

### Special Cases
| Scenario | Locale Used |
|---|---|
| Webhook event (user known) | `users.locale` |
| Celery task (user_id in payload) | `users.locale` |
| Celery Beat (no specific user) | `"en"` (default) |
| Error before user lookup | `"en"` (default) |

### Scope
- Applies to: card header, widget labels, button text, error messages
- Does NOT apply to: raw DB query results, system identifiers (query_key, db name)
