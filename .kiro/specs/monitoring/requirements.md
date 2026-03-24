# Monitoring — Requirements

## Overview
Scheduled DB monitoring that sends a summary card to a Google Chat space twice daily.
Intended to replace the existing cron-based script on a separate server.

## Functional Requirements

1. Run automatically at 05:00 and 17:00 KST every day via Celery Beat.
2. Check connectivity and health of all internal DBs registered in `configurations`.
3. Send a card message to a designated Google Chat space with:
   - Error count and healthy count
   - A "View Details" button that opens a dialog listing each DB's status
4. If all DBs are healthy, send a minimal "All OK" card.
5. Use the existing `GOOGLE_APPLICATION_CREDENTIALS` service account for Chat REST API auth.

## Non-Functional Requirements

- Must not block or interfere with existing webhook handling.
- Reuse `card_builder.py` for card JSON construction.
- Target space configurable via environment variable (`MONITORING_SPACE_NAME`).

## Out of Scope (for now)
- Alert escalation (email, PagerDuty, etc.)
- Per-query monitoring (only connection-level health check)
- Integration with existing card interaction flow (planned for later)
