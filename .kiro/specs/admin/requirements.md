# Admin — Requirements

## Overview
Local-only web UI for managing `configurations.allowed_queries` and previewing card templates.

## Functional Requirements

1. List all registered queries in `configurations.allowed_queries`.
2. Add a new query entry (query_key, db, sql, allowed_params).
3. Edit an existing query entry.
4. Delete a query entry.
5. Preview any of the 12 card templates with sample data.
6. No authentication required (local environment only).

## Non-Functional Requirements

- Accessible only on localhost (not exposed via Caddy or Cloud Run).
- Served by the existing FastAPI app under `/admin` prefix.
- No separate frontend build step — plain HTML + vanilla JS.

## Out of Scope
- User management
- Role-based access control
- Production deployment
