# Product

## Purpose
Build a Google Chat card message interaction system that allows internal users to query and process business data through Card UI in Chat.

## Goals
- Interactive Card v2 messages with button clicks, form submissions, and dialogs
- Integration with internal DBs (PostgreSQL, Oracle, MySQL)
- Async processing for heavy tasks via Celery

## Scale
- Users: 1–10 (internal)
- Concurrent: < 100
- MAU: < 10,000
