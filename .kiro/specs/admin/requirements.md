# Admin — Requirements

## Overview
In-Chat admin UI via Dialog for managing `configurations.allowed_queries`.
Accessible only to designated users via the `관리` keyword in Google Chat.

## Functional Requirements

1. User sends `관리` in Chat → system checks if user is in `admin_users` list.
2. Unauthorized user → text response: "권한이 없습니다."
3. Authorized user → admin main dialog opens with options:
   - 쿼리 목록 보기
   - 쿼리 추가
   - 쿼리 삭제
4. Query list: shows all registered query_keys with db type.
5. Query add: form with query_key, db, sql, allowed_params fields.
6. Query delete: select query_key from dropdown → confirm → delete.
7. Admin user list managed via `configurations.admin_users` (google_id array).

## Non-Functional Requirements

- No separate web UI or browser required.
- All interactions happen within Google Chat Dialog.
- Reuse existing `open_dialog` CARD_CLICKED routing.

## Out of Scope
- Query edit (add + delete covers the use case)
- Role hierarchy (admin / non-admin only)
