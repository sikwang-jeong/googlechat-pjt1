# Customer DB Error Alert — Requirements

## Overview
Receive Oracle DB error alerts from Zenius monitoring system via multiple channels,
parse the alert content, and send a Google Chat Card v2 message with actionable buttons.

## Functional Requirements

### FR-1: Alert Ingestion (3 channels)
- **Webhook**: `POST /webhook/alert/zenius` — Zenius pushes alert directly
- **Gmail Push**: Gmail → Google Pub/Sub → `POST /webhook/pubsub/gmail` — real-time push
- **Gmail Polling**: Celery Beat polls Gmail API periodically for unread alert emails
- All 3 channels converge to a single `parse_zenius_alert()` → `send_alert_card()` pipeline

### FR-2: Email Parsing
- Source: `zenius@cyberlogitec.com`
- Subject pattern: `[{Severity}] {hostname}({ip}) {EventName}`
- Body: HTML (base64, charset euc-kr) containing structured fields:
  - `Occurred Time`, `Infra Name`, `Host Name`, `Status`, `Severity`, `Event Name`, `Message`
- Severity levels: `Critical`, `Urgent`, `Normal`

### FR-3: Error Type Classification
Classify by `Message` field content:

| Type | Detection Pattern | Actionable |
|---|---|---|
| `longsess_lock` | `ORA-20998:LongSESS` or `LOCK` in message | Yes — Kill Session |
| `tablespace` | `ORA-20998:TS Warn` in message | Yes — (configurable) |
| `ora_00600` | `ORA-00600` in message | No |
| `ora_other` | other `ORA-` patterns | No |
| `cpu` | `CPU Used` event name | No |
| `unknown` | none of the above | No |

### FR-4: Card Message
- Send Card v2 to `ALERT_SPACE_NAME` via Chat REST API
- Card shows: severity icon, hostname, event name, occurred time, message summary
- Actionable items show action button; non-actionable show static text
- Footer buttons: `[Error Detail]` (dialog) and `[AI Analysis →]` (openLink, placeholder URL)

### FR-5: Action Button State Machine
- Same as db-monitor-card spec:
  - Initial: `[{label}]` active
  - Running: `[⏳ Running...]` disabled
  - Success: `[✅ Done ({elapsed}s)]` disabled
  - Failure < 3: `[Retry ({n}/3)]` active
  - Failure = 3: `[❌ Failed]` disabled
- Retry count: Redis `alert:retry:{alert_id}:{type}`

### FR-6: Error Detail Dialog
- `[Error Detail]` button → CARD_CLICKED → open dialog
- Dialog shows full `Message` field content as `textParagraph`

### FR-7: AI Analysis (Design Only — No Implementation)
- `[AI Analysis →]` button → openLink to `GET /report/alert/{alert_id}/ai`
- Endpoint reserved but returns 501 Not Implemented
- Future: LLM-based root cause analysis report

### FR-8: Action Configuration
- `configurations.alert_actions` JSON controls per-type behavior:
  ```json
  {
    "longsess_lock": { "label": "Kill Session", "actionable": true,  "query_key": "kill_session" },
    "tablespace":    { "label": "Extend TS",    "actionable": false },
    "ora_00600":     { "label": "Manual",       "actionable": false },
    "ora_other":     { "label": "Manual",       "actionable": false },
    "cpu":           { "label": "Manual",       "actionable": false }
  }
  ```

### FR-9: Deduplication
- Skip duplicate alerts: Redis `alert:seen:{message_id}` (TTL 1h)
- `message_id` from email `Message-ID` header or webhook payload id

## Non-Functional Requirements
- Webhook response must return 200 within 1s (async processing via Celery)
- Gmail polling interval: configurable via `GMAIL_POLL_INTERVAL_MINUTES` (default: 5)
- Alert cards stored in `alerts` table for audit
