# Monitoring — Tasks

## Tasks

- [ ] Add `MONITORING_SPACE_NAME` to `.env.dev.example`
- [ ] Implement `app/services/db_health.py` — connection check per driver (postgres/oracle/mysql)
- [ ] Implement `app/tasks/monitoring.py` — Celery task + card send logic
- [ ] Register Celery Beat schedule in `tasks/celery_app.py`
- [ ] Add `monitoring_detail` dialog handler to `routers/dialog.py`
- [ ] Manual test: trigger task via `celery call tasks.monitoring.run_db_monitor`
