# Data Layer — Requirements

## Requirements
- R1: PostgreSQL as main DB with 6 tables
- R2: Redis for JWT cache, user cache, query cache, dialog session
- R3: Alembic for schema migrations
- R4: Connect to internal DBs: PostgreSQL, Oracle, MySQL
- R5: Only pre-approved queries (stored in `configurations` table) allowed for internal DBs
- R6: Data retention policy per table
