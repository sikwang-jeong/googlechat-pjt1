# DB Monitor Card — Design

## Trigger
Celery Beat schedule (reuse existing beat_schedule in `tasks/celery_app.py`):
```python
"db-monitor-card-morning": {
    "task": "tasks.db_monitor_card.run_db_monitor_card",
    "schedule": crontab(hour=5, minute=30),
},
"db-monitor-card-evening": {
    "task": "tasks.db_monitor_card.run_db_monitor_card",
    "schedule": crontab(hour=17, minute=30),
},
```

## Log File
- Directory: `MONITORING_LOG_DIR` (env var)
- Pattern: `log_T_YYYYMMDDHHMMSS.log`
- Selection: latest file by filename (lexicographic sort)

## Log Parsing (`services/log_parser.py`)

### DB Block Detection
Each DB block starts with `################# {DB_NAME} #################`
and ends at the next `#################` or EOF.

### Per-Category Parse Rules

| Category | Detection | Data Extracted |
|---|---|---|
| `tablespace` | Lines after `== 1. CHECK TABLESPACE` before next `==` contain data rows | DB name, row count |
| `alert_log` | Lines after `== 2. CHECK ALERT LOG` before next `==` contain `RECORD_ID` rows | DB name, messages |
| `long_session` | Lines after `== 3. CHECK LONG SESSION` before next `==` contain session rows | DB name, `alter system kill session '...' immediate;` commands |
| `unstable_sql` | Lines after `== 4. Unstable SQL` before next `==` contain SQL rows | DB name, row count |
| `recyclebin` | `Total` row after `== 5. Recyclebin` — CNT > 0 | DB name, count |

### ParsedLog Structure
```python
@dataclass
class DbCheckResult:
    db: str
    category: str        # tablespace | alert_log | long_session | unstable_sql | recyclebin
    count: int
    detail: list[str]    # kill commands for long_session, messages for alert_log

@dataclass
class ParsedLog:
    log_id: str          # filename stem: log_T_YYYYMMDDHHMMSS
    timestamp: datetime
    results: list[DbCheckResult]   # only items with count > 0
```

## Card Structure

### Header
```
🔴 DB Monitor — {HH:MM} ({issue_count} issues)   ← if issues exist
🟢 DB Monitor — {HH:MM} (All Clear)              ← if no issues
```

### Section per Category (only if issues exist)
```
Section header: {category_icon} {category_label}
Widget per DB: decoratedText
  topLabel: {db_name}
  text: {count} item(s)
  button: [action_label] (if actionable) | static text (if not actionable)
```

### Category Icons & Labels
| Category | Icon | Label |
|---|---|---|
| `recyclebin` | 🗑️ | Recyclebin |
| `long_session` | ⏱️ | Long Session |
| `tablespace` | 💾 | Tablespace |
| `alert_log` | 🚨 | Alert Log |
| `unstable_sql` | 📊 | Unstable SQL |

### Footer Section
```
buttonList: [View Full Report →]  ← openLink to GET /report/monitor/{log_id}
```

### Action Button JSON (actionable item)
```json
{
  "text": "{action_label}",
  "disabled": false,
  "onClick": {
    "action": {
      "function": "monitor_action",
      "parameters": [
        { "key": "log_id",   "value": "{log_id}" },
        { "key": "db",       "value": "{db_name}" },
        { "key": "category", "value": "{category}" }
      ]
    }
  }
}
```

### Non-actionable Item (static text)
```json
{ "decoratedText": { "topLabel": "{db_name}", "text": "{count} item(s) — Manual action required" } }
```

## Action Flow (`monitor_action` CARD_CLICKED)

```
CARD_CLICKED: function=monitor_action
  → event_handler.py routes to monitor_action_handler()
  → check Redis monitor:retry:{log_id}:{db}:{category} (default 0)
  → if retry >= 3: return error (should not happen — button disabled)
  → update card: button text = "⏳ Running..." disabled=true
  → dispatch Celery task: run_monitor_action(log_id, db, category, space_name, message_name)
```

### Celery Task (`tasks/db_monitor_card.py`)
```
run_monitor_action(log_id, db, category, space_name, message_name)
  → load action config from configurations.monitor_actions[category]
  → execute query via db_query.py (query_key from config)
  → on success:
      delete Redis retry key
      update card: button text = "✅ Done ({elapsed}s)" disabled=true
  → on failure:
      increment Redis monitor:retry:{log_id}:{db}:{category} (TTL 24h)
      retry_count = new value
      if retry_count < 3:
          update card: button text = "Retry ({retry_count}/3)" disabled=false
      else:
          update card: button text = "❌ Failed" disabled=true
```

## Card Update Method
- Use Chat REST API `spaces.messages.patch` with `updateMask=cardsV2`
- `message_name` stored in Redis: `monitor:message:{log_id}` (set when card first sent)

## Redis Keys
| Key | Value | TTL |
|---|---|---|
| `monitor:message:{log_id}` | Chat message name (`spaces/.../messages/...`) | 24h |
| `monitor:retry:{log_id}:{db}:{category}` | retry count (int) | 24h |

## HTML Report (`GET /report/monitor/{log_id}`)
- Router: `app/routers/monitor.py`
- Template: `app/templates/monitor_report.html`
- Re-parses log file by `log_id` → renders full table of all DBs × all categories
- Protected by `verify_internal_token`

## Environment Variables
| Var | Purpose |
|---|---|
| `MONITORING_LOG_DIR` | Directory containing `log_T_*.log` files |
| `MONITORING_SPACE_NAME` | Target Chat space (shared with monitoring) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Shared service account |

## Files to Add
```
app/services/log_parser.py          ← log file parsing
app/tasks/db_monitor_card.py        ← Celery tasks: run_db_monitor_card, run_monitor_action
app/routers/monitor.py              ← GET /report/monitor/{log_id}
app/templates/monitor_report.html   ← full report HTML
```

## Files to Modify
```
app/tasks/celery_app.py             ← add beat_schedule entries
app/services/card_builder.py        ← add monitor card template
app/services/event_handler.py       ← add monitor_action CARD_CLICKED handler
app/core/config.py                  ← add MONITORING_LOG_DIR
```
