# Monitoring — Design

## Trigger
Celery Beat schedule:
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
  ├── Load DB list from configurations.allowed_queries
  ├── Attempt connection to each DB (timeout: 5s)
  ├── Aggregate results: { ok: [...], error: [...] }
  └── Send card to MONITORING_SPACE_NAME via Chat REST API
```

## Card Structure

### Error exists
```
Header: 🔴 DB 모니터링 — {HH:MM} 결과
Body:   에러 발생: N건 / 정상: M건
Button: [상세 보기] → open_dialog (monitoring_detail)
```

### All healthy
```
Header: 🟢 DB 모니터링 — {HH:MM} 결과
Body:   전체 정상 (N건)
```

## Dialog Content (monitoring_detail)
`decoratedText` list — one row per DB:
- `topLabel`: DB name
- `text`: ✅ OK or ❌ {error message}

## Chat REST API Call
- Method: `spaces.messages.create`
- Target: `MONITORING_SPACE_NAME`
- Auth: `GOOGLE_APPLICATION_CREDENTIALS`

## Environment Variables
| Var | Purpose |
|---|---|
| `MONITORING_SPACE_NAME` | Target Chat space (e.g. `spaces/xxx`) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Service account key (shared with Celery failure notifier) |

## Files to Add
```
app/tasks/monitoring.py   ← Celery task
app/services/db_health.py ← DB connection check per driver
```

## Integration Note
This feature is designed to be merged with the main card interaction flow later.
`card_builder.py` and `GOOGLE_APPLICATION_CREDENTIALS` are shared with existing features.
