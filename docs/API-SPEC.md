# API Specification

## Endpoints

### POST /webhook/chat
Receives all Google Chat events from Cloud Run relay.

**Auth:** `Authorization: Bearer {INTERNAL_API_TOKEN}`

**Request body:** Google Chat event JSON
```json
{
  "type": "CARD_CLICKED",
  "user": { "name": "users/123", "displayName": "John", "email": "john@example.com" },
  "action": { "function": "handle_confirm", "parameters": [] },
  "common": { "formInputs": {} },
  "space": { "name": "spaces/ABC" }
}
```

**Response:** Card JSON or text
```json
{ "text": "Processing..." }
```

---

### POST /webhook/chat/dialog
Receives dialog form submissions.

**Auth:** `Authorization: Bearer {INTERNAL_API_TOKEN}`

**Response (close dialog):**
```json
{
  "actionResponse": {
    "type": "DIALOG",
    "dialogAction": { "actionStatus": "OK" }
  }
}
```

---

### GET /health
Health check.

**Response:**
```json
{ "status": "ok", "db": "ok", "redis": "ok" }
```
Degraded: `"status": "degraded"` with failing component set to `"error"`.

---

## Event Types

| type | Trigger |
|---|---|
| `ADDED_TO_SPACE` | App added to space |
| `REMOVED_FROM_SPACE` | App removed |
| `MESSAGE` | User sends message |
| `CARD_CLICKED` | Button click or form submit |

## Card Action Functions

| function | Description |
|---|---|
| `handle_confirm` | Confirm button → dispatch Celery task |
| `open_dialog` | Open dialog (`interaction: OPEN_DIALOG`) |
| `submit_dialog` | Dialog form submit |
| `cancel_dialog` | Dialog cancel → close dialog |
