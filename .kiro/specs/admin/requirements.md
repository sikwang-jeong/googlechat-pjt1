# Admin — Requirements

## Overview
In-Chat admin UI via Dialog for managing `configurations.allowed_queries`.
Accessible only to designated users via the `admin` keyword in Google Chat.
All users can access personal settings (locale change) via the `settings` keyword.

## Functional Requirements

1. User sends `settings` in Chat → user settings dialog opens (all users).
2. User settings dialog: change display language (`en` / `ko`) → saved to `users.locale`.
3. User sends `admin` in Chat → system checks if user is in `admin_users` list.
4. Unauthorized user → text response: "Unauthorized."
5. Authorized user → admin main dialog opens with options:
   - Query List
   - Add Query
   - Delete Query
   - My Settings (same as user settings dialog)
   - Template Gallery
6. Query list: shows all registered query_keys with db type.
7. Query add: form with query_key, db, sql, allowed_params fields.
8. Query delete: select query_key from dropdown → confirm → delete.
9. Admin user list managed via `configurations.admin_users` (google_id array).
10. All card and dialog text rendered in the user's locale (`users.locale`, default `en`).

## Non-Functional Requirements

- No separate web UI or browser required.
- All interactions happen within Google Chat Dialog.
- Reuse existing `open_dialog` CARD_CLICKED routing.

## Out of Scope
- Query edit (add + delete covers the use case)
- Role hierarchy beyond admin / non-admin
