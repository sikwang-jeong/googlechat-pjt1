# Monitoring — Design

## Trigger
Celery Beat schedule (registered in `tasks/celery_app.py`):
```python
beat_schedule = {
    "db-monitor-morning": {
        "task": "tasks.monitoring.run_db_monitor",
        "schedule": crontab(hour=5, minute=0),
    },
    "db-monitor-evening": {
        "task": "tasks.monitoring.run_db_monitor",
        "schedule": crontab(hour=17, minute=0),
    },
}
```

## Task Flow
```
Celery Beat → run_db_monitor()
  ├── Load DB list from configurations.allowed_queries (reuse db_query.py)
  ├── Call db_health.check(db, driver) per DB — timeout 5s
  ├── Aggregate: { ok: [...], error: [...] }
  └── Send monitoring card to MONITORING_SPACE_NAME via Chat REST API
```

## Integration with Existing Features

### Shared: db_query.py
`db_health.py` reuses the DB connection logic from `services/db_query.py`.
- `configurations.allowed_queries` is the single source of DB list.
- No separate DB registry needed.

### Shared: card_builder.py
Monitoring cards are built via `card_builder.py`, same as webhook response cards.

### Shared: GOOGLE_APPLICATION_CREDENTIALS
Same service account used by Celery failure notifier (`integration/design.md`).
- Method: `spaces.messages.create`
- No `thread_name` — always creates a new top-level message.

### Shared: routers/dialog.py
`monitoring_detail` dialog handler is added to the existing `dialog.py` router.
- Triggered by `open_dialog` with `parameters: { "type": "monitoring_detail" }`
- Reuses the existing `open_dialog` CARD_CLICKED routing in `backend-api/design.md`

## Card Structure

### Error exists
```
cardId: monitoring-card
Header: 🔴 DB 모니터링 — {HH:MM} 결과
decoratedText: 에러 발생: N건 / 정상: M건
Button: [상세 보기] → open_dialog (parameters: { "type": "monitoring_detail" })
```

### All healthy
```
cardId: monitoring-card
Header: 🟢 DB 모니터링 — {HH:MM} 결과
decoratedText: 전체 정상 (N건)
```

## Dialog Content (monitoring_detail)
`decoratedText` list — one row per DB:
- `topLabel`: DB name (`query_key`)
- `text`: ✅ OK or ❌ {error message}

## Environment Variables
| Var | Purpose |
|---|---|
| `MONITORING_SPACE_NAME` | Target Chat space (e.g. `spaces/xxx`) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Shared with Celery failure notifier |

## Files to Add
```
app/services/db_health.py   ← DB connection check per driver
app/tasks/monitoring.py     ← Celery Beat task
```

## Files to Modify
```
app/tasks/celery_app.py     ← Register beat_schedule
app/routers/dialog.py       ← Add monitoring_detail dialog handler
```
