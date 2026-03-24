# Admin — Tasks

## Query Management
- [ ] Implement `app/routers/admin.py` — CRUD endpoints for allowed_queries
- [ ] Create `app/templates/admin/dashboard.html` — query list table
- [ ] Create `app/templates/admin/query_form.html` — new/edit form
- [ ] Mount admin router in `app/main.py` (ENVIRONMENT=local guard)

## Card Template Preview
- [ ] Add `build_template(name, data)` and `TEMPLATE_SAMPLES` to `card_builder.py`
- [ ] Create `app/templates/admin/templates.html` — template gallery grid
- [ ] Create `app/templates/admin/template_preview.html` — single template modal preview

## Integration
- [ ] Verify `/admin` is not accessible when `ENVIRONMENT != local`
- [ ] Manual test: add query via UI → verify in `configurations` table
- [ ] Manual test: preview all 12 templates render without error
