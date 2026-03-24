# Admin — Design

## Default Language
All card messages and Dialog texts are in **English by default**.
Language changes based on `users.locale` field (`en` default, `ko` for Korean).

## Trigger Flow
```
User sends "settings"
  → MESSAGE handler (event_handler.py)
  → Open user settings dialog (locale change only) — all users

User sends "admin"
  → MESSAGE handler (event_handler.py)
  → Check user.google_id in configurations.admin_users
  → Admin user  → open admin main dialog (full menu)
  → Normal user → { "text": "Unauthorized." }
```

## Admin User List
Stored in `configurations` table:
```json
{ "key": "admin_users", "value": ["google_id_1", "google_id_2"] }
```

## MESSAGE Keyword Addition
| Keyword | Response |
|---|---|
| `query` | Query selection card |
| `help` | Help card |
| `settings` | User settings dialog (all users) |
| `admin` | Admin main dialog (admin users only) |
| other | Help card (fallback) |

> Korean aliases (`조회`, `도움말`, `관리`) may be supported as fallback if `users.locale = "ko"`.

## Dialog Flow

### 1. User Settings Dialog (`user_settings`)
Available to all users via `settings` keyword:
```
Language  [SelectionInput DROPDOWN: English / 한국어]
[Save]
```
On save → update `users.locale` → close dialog with `actionStatus: OK`

### 2. Admin Main Dialog (`admin_main`)
```
[Query List]
[Add Query]
[Delete Query]
[User Permissions]
[My Settings]   ← same as user_settings dialog
[Template Gallery]
```

### 3. Query List Dialog (`admin_query_list`)
`decoratedText` list — one row per query:
- `topLabel`: query_key
- `text`: db type
- `bottomLabel`: allowed_params

### 4. Query Add Dialog (`admin_query_add`)
Form fields:
```
query_key      [TextInput]
db             [SelectionInput DROPDOWN: postgres / oracle / mysql]
sql            [TextInput MULTIPLE_LINE]
allowed_params [TextInput — comma-separated]
[Save] [Cancel]
```
On submit → insert into `configurations.allowed_queries` → close dialog with `actionStatus: OK`

### 5. Query Delete Dialog (`admin_query_delete`)
```
query_key  [SelectionInput DROPDOWN — populated from allowed_queries]
[Delete] [Cancel]
```
On [Delete] → confirm dialog (`admin_query_delete_confirm`) → delete → close dialog with `actionStatus: OK`

> All dialog responses use `actionStatus: OK` (private, visible to requester only).

## i18n Strategy
- Default locale: `en`
- Locale stored per user in `users.locale`
- Card text strings resolved via `i18n(key, locale)` helper in `card_builder.py`
- Supported locales: `en`, `ko`

### Locale String Structure
Strings stored as a dict in `card_builder.py` (or `services/i18n.py`):

```python
STRINGS = {
    "en": {
        "welcome.title": "Welcome",
        "welcome.subtitle": "Use 'query' to search data.",
        "query_select.title": "Select Query",
        "query_result.title": "Query Result",
        "query_result.no_results": "No results found.",
        "error.title": "Error",
        "error.body": "An unexpected error occurred.",
        "help.title": "Help",
        "help.body": "Commands: query / help / settings / admin",
        "confirm.title": "Confirm",
        "confirm.yes": "Confirm",
        "confirm.no": "Cancel",
        "success.title": "Done",
        "alert.title": "Alert",
        "progress.title": "In Progress",
        "input_form.title": "Enter Parameters",
        "list_select.title": "Select",
        "monitoring.title": "DB Status",
        "settings.title": "My Settings",
        "settings.language": "Language",
        "settings.save": "Save",
        "admin.unauthorized": "Unauthorized.",
        "admin.main.title": "Admin Menu",
        "admin.query_list": "Query List",
        "admin.query_add": "Add Query",
        "admin.query_delete": "Delete Query",
        "admin.my_settings": "My Settings",
        "admin.template_gallery": "Template Gallery",
    },
    "ko": {
        "welcome.title": "환영합니다",
        "welcome.subtitle": "'조회'를 입력하여 데이터를 검색하세요.",
        "query_select.title": "쿼리 선택",
        "query_result.title": "조회 결과",
        "query_result.no_results": "결과가 없습니다.",
        "error.title": "오류",
        "error.body": "예기치 않은 오류가 발생했습니다.",
        "help.title": "도움말",
        "help.body": "명령어: query / help / settings / admin",
        "confirm.title": "확인",
        "confirm.yes": "확인",
        "confirm.no": "취소",
        "success.title": "완료",
        "alert.title": "알림",
        "progress.title": "처리 중",
        "input_form.title": "파라미터 입력",
        "list_select.title": "선택",
        "monitoring.title": "DB 상태",
        "settings.title": "내 설정",
        "settings.language": "언어",
        "settings.save": "저장",
        "admin.unauthorized": "권한이 없습니다.",
        "admin.main.title": "관리자 메뉴",
        "admin.query_list": "쿼리 목록",
        "admin.query_add": "쿼리 추가",
        "admin.query_delete": "쿼리 삭제",
        "admin.my_settings": "내 설정",
        "admin.template_gallery": "템플릿 갤러리",
    }
}
```

## CARD_CLICKED Routing Addition
| function | parameters.type | Action |
|---|---|---|
| `open_dialog` | `user_settings` | Open user settings dialog |
| `open_dialog` | `admin_main` | Open admin main dialog |
| `open_dialog` | `admin_query_list` | Open query list dialog |
| `open_dialog` | `admin_query_add` | Open query add form |
| `open_dialog` | `admin_query_delete` | Open query delete form |
| `open_dialog` | `admin_query_delete_confirm` | Open delete confirmation |
| `open_dialog` | `admin_user_permissions` | Open user permissions dialog |
| `open_dialog` | `admin_template_gallery` | Open template preview gallery |

## Card Template Preview
Card templates (A~L) are defined in `card_builder.py` as `build_template(name, data)`.
Preview is available via `admin_template_gallery` dialog — lists all 12 templates.
Each template renders with `TEMPLATE_SAMPLES[name]` sample data.

### `admin_template_preview` Response Format
```json
{
  "actionResponse": {
    "type": "DIALOG",
    "dialogAction": {
      "dialog": {
        "body": {
          "sections": [{
            "widgets": [{
              "textParagraph": { "text": "<b>Template: {name}</b>" }
            }, {
              "textParagraph": { "text": "{rendered card JSON as preformatted text}" }
            }]
          }]
        }
      }
    }
  }
}
```
- Rendered card JSON is displayed as `<pre>` formatted text inside the dialog body.
- Response is private (visible to requester only via dialog).

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
| H | confirm | Confirmation request card ([Confirm] [Cancel]) |
| I | progress | Step progress status card |
| J | input_form | Parameter input form card |
| K | list_select | List selection card (RADIO/DROPDOWN) |
| L | success | Task completion summary card |

## User Permissions

### Storage
```json
{ "key": "user_permissions", "value": { "google_id_1": { "can_run_query": false } } }
```
- Default (key absent): `can_run_query: true`
- Admin users: always allowed, no permission check

### `admin_user_permissions` Dialog
```
User    [SelectionInput DROPDOWN — populated from users table]
Allow query execution  [SelectionInput CHECK_BOX]
[Save] [Cancel]
```
On save → upsert `configurations.user_permissions[google_id]` → close with `actionStatus: OK`

### Permission Check Flow
```
run_query requested
  → admin_service.can_run_query(google_id)
  → admin user → allow
  → user_permissions[google_id].can_run_query is False → { "text": "You do not have permission to run queries." }
  → otherwise → allow
```

## Data Layer Changes
- `users` table: add `locale VARCHAR(10) DEFAULT 'en'`

## Files to Add
```
app/services/admin_service.py   ← admin_users check, query CRUD, i18n helper
```

## Files to Modify
```
app/services/event_handler.py   ← Add "settings" / "admin" keyword routing
app/routers/dialog.py           ← Add user_settings + admin_* dialog handlers
app/services/card_builder.py    ← Add build_template(), TEMPLATE_SAMPLES, i18n()
app/models/db.py                ← Add locale field to User model
```
