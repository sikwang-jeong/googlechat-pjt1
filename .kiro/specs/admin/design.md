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

## CARD_CLICKED Routing Addition
| function | parameters.type | Action |
|---|---|---|
| `open_dialog` | `user_settings` | Open user settings dialog |
| `open_dialog` | `admin_main` | Open admin main dialog |
| `open_dialog` | `admin_query_list` | Open query list dialog |
| `open_dialog` | `admin_query_add` | Open query add form |
| `open_dialog` | `admin_query_delete` | Open query delete form |
| `open_dialog` | `admin_query_delete_confirm` | Open delete confirmation |
| `open_dialog` | `admin_template_gallery` | Open template preview gallery |

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
| H | confirm | Confirmation request card ([Confirm] [Cancel]) |
| I | progress | Step progress status card |
| J | input_form | Parameter input form card |
| K | list_select | List selection card (RADIO/DROPDOWN) |
| L | success | Task completion summary card |

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
