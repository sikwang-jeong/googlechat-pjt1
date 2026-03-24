# Admin — Tasks

## Keyword & Auth
- [ ] Add `settings` keyword routing in `app/services/event_handler.py`
- [ ] Add `admin` keyword routing in `app/services/event_handler.py`
- [ ] Implement `admin_service.py` — `is_admin(google_id)` check via `configurations.admin_users`

## i18n
- [ ] Add `locale` column to `users` table via Alembic migration
- [ ] Implement `i18n(key, locale)` helper in `app/services/card_builder.py`
- [ ] Add locale string files / dict for `en` and `ko`
- [ ] Pass `locale` to all `build_template()` calls in event_handler and tasks

## Dialog Handlers (app/routers/dialog.py)
- [ ] `user_settings` — locale change form + save handler (all users)
- [ ] `admin_main` — main menu dialog
- [ ] `admin_query_list` — query list dialog
- [ ] `admin_query_add` — query add form + submit handler
- [ ] `admin_query_delete` — query delete form
- [ ] `admin_query_delete_confirm` — delete confirmation + execute
- [ ] `admin_template_gallery` — card template preview list

## Card Templates (app/services/card_builder.py)
- [ ] Add `build_template(name, data, locale="en")` function
- [ ] Add `TEMPLATE_SAMPLES` dict for all 12 templates (A~L)

## Integration Test
- [ ] Verify `settings` keyword opens user settings dialog for all users
- [ ] Verify locale change updates `users.locale` and subsequent cards use new locale
- [ ] Verify unauthorized user gets "Unauthorized." response for `admin` keyword
- [ ] Verify query add → appears in `configurations.allowed_queries`
- [ ] Verify query delete → removed from `configurations.allowed_queries`
- [ ] Verify all 12 templates render without error in preview dialog
