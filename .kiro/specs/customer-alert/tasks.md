# Customer DB Error Alert — Tasks

## Implementation Tasks

- [ ] Add env vars to `app/core/config.py`: `ALERT_SPACE_NAME`, `GMAIL_POLL_INTERVAL_MINUTES`, `GMAIL_ALERT_SENDER`, `PUBSUB_AUDIENCE`
- [ ] Extend `alerts` table in `app/models/db.py` — add `source`, `error_type`, `host_name`, `ip`, `severity`, `event_name`, `raw_message` columns + Alembic migration
- [ ] Implement `app/services/alert_parser.py` — `parse_zenius_alert()`, `classify_error()`
- [ ] Add alert card template to `app/services/card_builder.py`
- [ ] Add `POST /webhook/alert/zenius` to `app/routers/alert.py`
- [ ] Add `GET /report/alert/{alert_id}/ai` stub (501) to `app/routers/alert.py`
- [ ] Implement `app/routers/pubsub.py` — `POST /webhook/pubsub/gmail` with OIDC verification
- [ ] Implement `app/tasks/alert_action.py` — `run_alert_action`, `send_alert_card` Celery tasks
- [ ] Implement `app/tasks/gmail_poller.py` — `poll_gmail_alerts` Celery task
- [ ] Register gmail poll beat_schedule in `app/tasks/celery_app.py`
- [ ] Add `alert_action` CARD_CLICKED handler in `app/services/event_handler.py`
- [ ] Add `alert_detail` CARD_CLICKED handler in `app/services/event_handler.py` (open dialog with full message)
- [ ] Add `alert_actions` default config to `configurations` table seed/migration
