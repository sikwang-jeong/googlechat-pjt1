# Admin — Tasks

## Keyword & Auth
- [ ] Add `관리` keyword routing in `app/services/event_handler.py`
- [ ] Implement `admin_service.py` — `is_admin(google_id)` check via `configurations.admin_users`

## Dialog Handlers (app/routers/dialog.py)
- [ ] `admin_main` — main menu dialog
- [ ] `admin_query_list` — query list dialog
- [ ] `admin_query_add` — query add form + submit handler
- [ ] `admin_query_delete` — query delete form
- [ ] `admin_query_delete_confirm` — delete confirmation + execute
- [ ] `admin_template_gallery` — card template preview list

## Card Templates (app/services/card_builder.py)
- [ ] Add `build_template(name, data)` function
- [ ] Add `TEMPLATE_SAMPLES` dict for all 12 templates (A~L)

## Integration Test
- [ ] Verify unauthorized user gets "권한이 없습니다." response
- [ ] Verify query add → appears in `configurations.allowed_queries`
- [ ] Verify query delete → removed from `configurations.allowed_queries`
- [ ] Verify all 12 templates render without error in preview dialog
