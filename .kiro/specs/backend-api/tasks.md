# Backend API — Tasks

## Implementation Checklist
- [x] Define project structure
- [x] Define `core/config.py` settings
- [x] Define `core/auth.py` (internal token verification)
- [x] Define `models/chat_event.py`
- [x] Define routers: `health.py`, `webhook.py`, `dialog.py`
- [x] Define `services/event_handler.py` routing logic
- [ ] Implement `core/config.py`
- [ ] Implement `core/auth.py`
- [ ] Implement `models/chat_event.py`
- [ ] Implement `models/db.py` (SQLAlchemy models, including `users.locale`)
- [ ] Implement `routers/health.py`, `webhook.py`, `dialog.py`
- [ ] Implement `services/event_handler.py`
  - [ ] `settings` keyword → open `user_settings` dialog
  - [ ] `admin` keyword → check admin → open `admin_main` dialog or "Unauthorized."
- [ ] Implement `services/card_builder.py`
  - [ ] `build_template(name, data, locale="en")`
  - [ ] `i18n(key, locale)` helper
- [ ] Implement `services/db_query.py`
- [ ] Implement `routers/alert.py` (POST /webhook/alert, GET /report/{alert_id})
- [ ] Write `templates/alert.html` (Jinja2 report template)
- [ ] Write unit tests for event routing
- [ ] Integration test with Cloud Run relay
