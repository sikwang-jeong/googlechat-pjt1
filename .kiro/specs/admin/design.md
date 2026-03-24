# Admin — Design

## Trigger Flow
```
User sends "관리"
  → MESSAGE handler (event_handler.py)
  → Check user.google_id in configurations.admin_users
  → Unauthorized → { "text": "권한이 없습니다." }
  → Authorized   → open admin main dialog
```

## Admin User List
Stored in `configurations` table:
```json
{ "key": "admin_users", "value": ["google_id_1", "google_id_2"] }
```

## MESSAGE Keyword Addition
| Keyword | Response |
|---|---|
| `조회` | Query selection card |
| `도움말` | Help card |
| `관리` | Admin dialog (authorized users only) |
| other | Help card (fallback) |

## Dialog Flow

### 1. Admin Main Dialog (`admin_main`)
```
[쿼리 목록 보기]
[쿼리 추가]
[쿼리 삭제]
```

### 2. Query List Dialog (`admin_query_list`)
`decoratedText` list — one row per query:
- `topLabel`: query_key
- `text`: db type
- `bottomLabel`: allowed_params

### 3. Query Add Dialog (`admin_query_add`)
Form fields:
```
query_key     [TextInput]
db            [SelectionInput DROPDOWN: postgres / oracle / mysql]
sql           [TextInput MULTIPLE_LINE]
allowed_params [TextInput — comma-separated]
[저장] [취소]
```
On submit → insert into `configurations.allowed_queries` → close dialog with `actionStatus: OK` (private, visible to requester only)

### 4. Query Delete Dialog (`admin_query_delete`)
```
query_key  [SelectionInput DROPDOWN — populated from allowed_queries]
[삭제] [취소]
```
On [삭제] → confirm dialog (`admin_query_delete_confirm`) → delete → close dialog with `actionStatus: OK` (private, visible to requester only)

## CARD_CLICKED Routing Addition
| function | parameters.type | Action |
|---|---|---|
| `open_dialog` | `admin_main` | Open admin main dialog |
| `open_dialog` | `admin_query_list` | Open query list dialog |
| `open_dialog` | `admin_query_add` | Open query add form |
| `open_dialog` | `admin_query_delete` | Open query delete form |
| `open_dialog` | `admin_query_delete_confirm` | Open delete confirmation |

## Card Template Preview
Card templates (A~L) are defined in `card_builder.py` as `build_template(name, data)`.
Preview is available via `admin_template_gallery` dialog — lists all 12 templates.
Each template renders with `TEMPLATE_SAMPLES[name]` sample data.

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

## Files to Add
```
app/services/admin_service.py   ← admin_users check, query CRUD logic
```

## Files to Modify
```
app/services/event_handler.py   ← Add "관리" keyword routing
app/routers/dialog.py           ← Add admin_* dialog handlers
app/services/card_builder.py    ← Add build_template() + TEMPLATE_SAMPLES
```
