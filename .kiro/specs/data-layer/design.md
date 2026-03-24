# Data Layer — Design

## Tables

| Table | Purpose | Retention |
|---|---|---|
| `users` | Google Chat user info | indefinite |
| `events` | Card interaction event log | 6 months |
| `tasks` | Celery task status | 3 months |
| `audit_logs` | Change audit trail | 1 year |
| `notifications` | Sent notification history | 3 months |
| `alerts` | External alert events + report data | 3 months |
| `configurations` | System config + allowed queries | indefinite |

## DDL

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    google_id VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255),
    email VARCHAR(255),
    space_name VARCHAR(255),
    locale VARCHAR(10) DEFAULT 'en',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    event_type VARCHAR(100) NOT NULL,
    function_name VARCHAR(255),
    payload JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_events_created_at ON events(created_at);

CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    celery_task_id VARCHAR(255) UNIQUE,
    status VARCHAR(50) DEFAULT 'pending',  -- pending/running/success/failed
    payload JSONB DEFAULT '{}',
    result JSONB,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(255) NOT NULL,
    target_table VARCHAR(100),
    before_data JSONB,
    after_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    space_name VARCHAR(255),
    message_type VARCHAR(100),
    payload JSONB DEFAULT '{}',
    status VARCHAR(50) DEFAULT 'sent',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE configurations (
    id SERIAL PRIMARY KEY,
    key VARCHAR(255) UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Initial seed: allowed queries
INSERT INTO configurations (key, value, description) VALUES
('allowed_queries', '{}', 'Map of query_key to SQL string for internal DB execution');

CREATE TABLE alerts (
    id SERIAL PRIMARY KEY,
    alert_code VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body JSONB DEFAULT '{}',
    space_name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_alerts_created_at ON alerts(created_at);
```

## Redis Key Patterns

| Purpose | Key | TTL |
|---|---|---|
| JWT verification | `auth:jwt:{token_hash}` | 5 min |
| User info | `user:{google_id}` | 1 hour |
| Query result cache | `query:{hash}` | 10 min |
| Dialog session | `session:dialog:{user_id}:{dialog_id}` | 30 min |
| Executed action | `executed:{message_name}:{function}` | 1 hour |

## Internal DB Connections

| DB | Driver |
|---|---|
| PostgreSQL (internal) | asyncpg |
| Oracle | python-oracledb (sync, thread pool) |
| MySQL | aiomysql |

## Allowed Query Execution Flow
1. Look up `query_key` in `configurations.allowed_queries` → 400 if not found
2. Validate request params against `allowed_params` list → 400 if invalid
3. Select target DB from `db` field (postgres / oracle / mysql)
4. Execute SQL with bound params
