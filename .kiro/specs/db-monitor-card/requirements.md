# DB Monitor Card — Requirements

## Overview
Parse Oracle DB monitoring log files and send a Google Chat Card v2 message
summarizing items that require action, grouped by check category.

## Functional Requirements

### FR-1: Log Parsing
- Read the latest log file matching `log_T_YYYYMMDDHHMMSS.log` from a configurable directory (`MONITORING_LOG_DIR`)
- Parse per-DB results for 5 check categories:
  - `tablespace`: TABLESPACE usage > 96%
  - `alert_log`: ALERT LOG entries present
  - `long_session`: LONG SESSION > 3600s (includes kill command)
  - `unstable_sql`: Unstable SQL STDDEV > 10
  - `recyclebin`: Recyclebin object count > 0

### FR-2: Card Message
- Send a Card v2 message to `MONITORING_SPACE_NAME` via Chat REST API
- Show only DBs/categories with issues (skip clean results)
- Group by check category (B-plan: category → DB list)
- Each entry shows: DB name, count, and action button or static text

### FR-3: Actionable Items
- Action availability controlled by `configurations.monitor_actions` (JSON)
- `actionable: true` → show action button
- `actionable: false` → show static label text only
- Initially actionable: `recyclebin` (PURGE DBA_RECYCLEBIN), `long_session` (ALTER SYSTEM KILL SESSION)

### FR-4: Action Button State Machine
- Initial: `[{label}]` (active)
- After click: `[⏳ Running...]` (disabled) — card updated immediately
- Success: `[✅ Done ({elapsed}s)]` (disabled)
- Failure (< 3 retries): `[Retry ({n}/3)]` (active)
- Failure (3rd retry): `[❌ Failed]` (disabled)
- Retry count stored in Redis: `monitor:retry:{log_id}:{db}:{category}`

### FR-5: Card Update
- Action result updates the card in-place via Chat REST API (UPDATE_MESSAGE)
- No new message created on action completion

### FR-6: Full Report
- `[View Full Report →]` button at card bottom → opens `GET /report/monitor/{log_id}`
- HTML report rendered via Jinja2 showing all DBs and all check results

### FR-7: Action Configuration
- `configurations.monitor_actions` JSON controls per-category behavior:
  ```json
  {
    "recyclebin":   { "label": "Purge",      "actionable": true,  "query_key": "purge_recyclebin" },
    "long_session": { "label": "Kill Session","actionable": true,  "query_key": "kill_session" },
    "tablespace":   { "label": "Manual",     "actionable": false },
    "alert_log":    { "label": "Manual",     "actionable": false },
    "unstable_sql": { "label": "Manual",     "actionable": false }
  }
  ```
- Changing `actionable` to `true` and adding `query_key` enables button for that category without code change

## Non-Functional Requirements
- Log parsing must complete within 3 seconds
- Card send must not block Celery Beat scheduler
- Retry count must expire from Redis after 24 hours
