# Customer DB Error Alert — Design

## Alert Ingestion Pipeline

```
POST /webhook/alert/zenius          ← Zenius direct webhook
POST /webhook/pubsub/gmail          ← Gmail Push via Pub/Sub
Celery Beat: poll_gmail_alerts()    ← Gmail API polling

All → parse_zenius_alert(raw) → AlertPayload → Celery: send_alert_card.delay(payload)
```

## Email Structure (Zenius)

### Subject Pattern
```
[{Severity}] {hostname}({ip}) {EventName}
```
Severity values: `Critical`, `Urgent`, `Normal`

### Body
- `Content-Type: text/html; charset="euc-kr"`
- `Content-Transfer-Encoding: base64`
- Key fields extracted via HTML parsing:

| Field | HTML label |
|---|---|
| occurred_at | `Occurred Time` |
| infra_name | `Infra Name` |
| host_name | `Host Name` |
| status | `Status` |
| severity | `Severity` |
| event_name | `Event Name` |
| message | `Message` |

## Error Type Classification (`services/alert_parser.py`)

```python
def classify_error(event_name: str, message: str) -> str:
    if "LongSESS" in message or "LOCK" in message:
        return "longsess_lock"
    if "TS Warn" in message:
        return "tablespace"
    if "ORA-00600" in message:
        return "ora_00600"
    if "ORA-" in message:
        return "ora_other"
    if "CPU Used" in event_name:
        return "cpu"
    return "unknown"
```

## AlertPayload Dataclass
```python
@dataclass
class AlertPayload:
    alert_id: str           # UUID generated on ingestion
    message_id: str         # email Message-ID or webhook id (dedup key)
    occurred_at: datetime
    host_name: str
    ip: str
    severity: str           # Critical | Urgent | Normal
    event_name: str
    error_type: str         # classified type
    message: str            # raw message text
    source: str             # webhook | gmail_push | gmail_poll
```

## Card Structure

### Header
```
{severity_icon} {event_name} — {host_name}
{severity} | {occurred_at}
```
Severity icons: `🔴` Critical, `🟠` Urgent, `🟡` Normal

### Body Section
```
decoratedText:
  topLabel: {error_type_label}
  text: {message_summary}  (first 100 chars)
  button: [{action_label}] if actionable | static text if not
```

### Footer Section
```
buttonList:
  [Error Detail]   ← CARD_CLICKED: function=alert_detail, parameters.alert_id={alert_id}
  [AI Analysis →]  ← openLink: GET /report/alert/{alert_id}/ai
```

### Severity Icon Map
| Severity | Icon |
|---|---|
| Critical | 🔴 |
| Urgent | 🟠 |
| Normal | 🟡 |

## Action Flow

### CARD_CLICKED: `alert_action`
```
event_handler.py → alert_action_handler(alert_id, error_type)
  → check Redis alert:retry:{alert_id}:{error_type} (default 0)
  → update card: button = "⏳ Running..." disabled=true
  → Celery: run_alert_action.delay(alert_id, error_type, space_name, message_name)
```

### Celery Task: `run_alert_action`
```
→ load config from configurations.alert_actions[error_type]
→ load alert from alerts table (host_name, message for session id extraction)
→ execute via db_query.py (query_key from config)
→ success:
    delete Redis retry key
    update card: button = "✅ Done ({elapsed}s)" disabled=true
→ failure:
    increment Redis alert:retry:{alert_id}:{error_type} (TTL 24h)
    if retry < 3: button = "Retry ({n}/3)" active
    if retry == 3: button = "❌ Failed" disabled=true
```

### CARD_CLICKED: `alert_detail`
```
event_handler.py → open dialog
  → load alert from alerts table by alert_id
  → dialog body: textParagraph with full message text
```

## Gmail Integration

### A. Webhook (`POST /webhook/alert/zenius`)
- Zenius posts raw email fields as JSON
- Protected by `verify_internal_token`
- Immediately parse → Celery task

### B. Gmail Push (Pub/Sub)
- Gmail API watch → Pub/Sub topic → `POST /webhook/pubsub/gmail`
- Payload: base64-encoded email notification
- Fetch full email via Gmail API → parse → Celery task
- Protected by Google OIDC token verification

### C. Gmail Polling (Celery Beat)
```python
"gmail-alert-poll": {
    "task": "tasks.gmail_poller.poll_gmail_alerts",
    "schedule": crontab(minute=f"*/{GMAIL_POLL_INTERVAL_MINUTES}"),
}
```
- Query: `from:zenius@cyberlogitec.com is:unread`
- Fetch unread emails → parse → mark as read → Celery task per email

## Deduplication
- On ingestion: check Redis `alert:seen:{message_id}` → skip if exists
- On process: set `alert:seen:{message_id}` TTL 1h

## Redis Keys
| Key | Value | TTL |
|---|---|---|
| `alert:seen:{message_id}` | `1` | 1h |
| `alert:message:{alert_id}` | Chat message name | 24h |
| `alert:retry:{alert_id}:{error_type}` | retry count | 24h |

## DB: `alerts` Table (extend existing)
Add columns:
- `source` VARCHAR — `webhook` / `gmail_push` / `gmail_poll`
- `error_type` VARCHAR — classified type
- `host_name` VARCHAR
- `ip` VARCHAR
- `severity` VARCHAR
- `event_name` VARCHAR
- `raw_message` TEXT

## AI Analysis Endpoint (Stub)
```
GET /report/alert/{alert_id}/ai
→ return HTTP 501 Not Implemented
→ response: {"detail": "AI analysis not yet implemented"}
```

## Environment Variables
| Var | Purpose |
|---|---|
| `ALERT_SPACE_NAME` | Target Chat space for alert cards |
| `GMAIL_POLL_INTERVAL_MINUTES` | Polling interval (default: 5) |
| `GMAIL_ALERT_SENDER` | Sender filter (default: zenius@cyberlogitec.com) |
| `PUBSUB_AUDIENCE` | Google Pub/Sub OIDC audience for token verification |
| `GOOGLE_APPLICATION_CREDENTIALS` | Shared service account |

## Files to Add
```
app/services/alert_parser.py        ← parse_zenius_alert(), classify_error()
app/tasks/alert_action.py           ← run_alert_action Celery task
app/tasks/gmail_poller.py           ← poll_gmail_alerts Celery task
app/routers/pubsub.py               ← POST /webhook/pubsub/gmail
```

## Files to Modify
```
app/routers/alert.py                ← add POST /webhook/alert/zenius, GET /report/alert/{id}/ai
app/services/event_handler.py       ← add alert_action, alert_detail CARD_CLICKED handlers
app/services/card_builder.py        ← add alert card template
app/tasks/celery_app.py             ← add gmail poll beat_schedule
app/models/db.py                    ← extend alerts table
app/core/config.py                  ← add new env vars
```
