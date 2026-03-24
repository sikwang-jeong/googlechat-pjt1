# Admin — Design

## Architecture

```
Browser (localhost) → FastAPI /admin/* → Jinja2 HTML
                                       → /admin/api/* (JSON CRUD)
```

- Served by existing FastAPI app — no separate process.
- Router: `app/routers/admin.py`
- Templates: `app/templates/admin/` (Jinja2)
- Only mounted when `ENVIRONMENT=local` (env var guard).

## Endpoints

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/admin` | Dashboard — query list |
| `GET` | `/admin/queries/new` | New query form |
| `POST` | `/admin/queries` | Create query |
| `GET` | `/admin/queries/{key}/edit` | Edit query form |
| `PUT` | `/admin/queries/{key}` | Update query |
| `DELETE` | `/admin/queries/{key}` | Delete query |
| `GET` | `/admin/templates` | Card template preview gallery |
| `GET` | `/admin/templates/{name}` | Preview single template with sample data |

## Query Management UI

### Dashboard (`/admin`)
- Table: query_key / db / allowed_params / actions (Edit, Delete)
- Button: [+ 새 쿼리 추가]

### Query Form (`/admin/queries/new`, `/admin/queries/{key}/edit`)
```
query_key    [text input]
db           [dropdown: postgres / oracle / mysql]  ← 추천
sql          [textarea]
allowed_params [text input, comma-separated]
              [저장] [취소]
```

## Card Template Preview Gallery (`/admin/templates`)

12 templates displayed as a grid. Each card shows:
- Template name
- Description
- [미리보기] button → renders sample card JSON in a modal

### Template Catalog

| ID | Name | Description |
|---|---|---|
| A | welcome | ADDED_TO_SPACE welcome card |
| B | query_select | Query selection card (SelectionInput) |
| C | query_result | Query result card (decoratedText / textParagraph) |
| D | error | Error card with warning icon |
| E | monitoring | DB monitoring summary card |
| F | help | Usage guide card |
| G | alert | Single-event notification card |
| H | confirm | Confirmation request card ([확인] [취소]) |
| I | progress | Step progress status card |
| J | input_form | Parameter input form card |
| K | list_select | List selection card (RADIO/DROPDOWN) |
| L | success | Task completion summary card |

### Sample Data per Template
Each template is rendered with hardcoded sample data in `card_builder.py`:
```python
TEMPLATE_SAMPLES = {
    "welcome": { "display_name": "홍길동" },
    "query_result": { "columns": ["날짜", "매출"], "rows": [["2026-01-01", "1,200,000"]] },
    "monitoring": { "ok": 10, "error": 2, "errors": [{"key": "sales_db", "msg": "timeout"}] },
    "alert": { "title": "배치 완료", "body": "일일 집계가 완료됐습니다." },
    "confirm": { "title": "삭제 확인", "body": "정말 삭제하시겠습니까?" },
    "progress": { "current": 2, "total": 3, "label": "데이터 집계 중..." },
    "error": { "message": "DB 연결 실패" },
    "success": { "message": "쿼리 실행 완료", "elapsed": "1.2s" },
    # ... etc
}
```

## Files to Add
```
app/routers/admin.py          ← CRUD + template preview endpoints
app/templates/admin/          ← Jinja2 HTML templates
app/services/card_builder.py  ← Add build_template(name, data) + TEMPLATE_SAMPLES
```

## Files to Modify
```
app/main.py   ← Mount admin router only when ENVIRONMENT=local
```
