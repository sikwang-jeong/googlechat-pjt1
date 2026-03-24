# DB Monitor Card — Tasks

## Implementation Tasks

- [ ] Add `MONITORING_LOG_DIR` to `app/core/config.py`
- [ ] Implement `app/services/log_parser.py` — parse `log_T_*.log` into `ParsedLog`
- [ ] Add monitor card template to `app/services/card_builder.py`
- [ ] Implement `app/tasks/db_monitor_card.py` — `run_db_monitor_card`, `run_monitor_action`
- [ ] Register beat_schedule entries in `app/tasks/celery_app.py`
- [ ] Add `monitor_action` CARD_CLICKED handler in `app/services/event_handler.py`
- [ ] Implement `app/routers/monitor.py` — `GET /report/monitor/{log_id}`
- [ ] Create `app/templates/monitor_report.html`
- [ ] Add `monitor_actions` default config to `configurations` table seed/migration
