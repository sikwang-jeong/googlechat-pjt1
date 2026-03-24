# 프로젝트 종합 정리 (점검용)

> 마지막 갱신: 2026-03-24 15:03
> 이 파일은 .kiro 문서 변경 시 pre-commit hook에 의해 자동 갱신됩니다.

---

## 1. 프로젝트 개요

Google Chat Card v2 인터랙션 시스템.
사내 사용자가 Chat에서 카드 UI로 업무 데이터를 조회·처리할 수 있도록 한다.

- 스택: Python 3.12 / FastAPI / PostgreSQL / Redis / Celery / Docker Compose / GCP Cloud Run
- 규모: 내부 사용자 1~10명, 동시접속 100명 미만, MAU 10,000 미만

---

## 2. 디렉토리 구조

```
.kiro/
├── steering/          ← 프로젝트 규칙 (전 에이전트 공통 참조)
│   ├── product.md     → 제품 목적·목표
│   ├── tech.md        → 기술 스택
│   ├── api-standards.md → API 응답 형식
│   └── conventions.md → 네이밍·코드 규칙
├── skills/            ← 에이전트별 역할 정의
│   ├── dev-agent/SKILL.md
│   ├── qa-agent/SKILL.md
│   └── deploy/SKILL.md
├── specs/             ← 기능별 명세
│   ├── card-interaction/
│   ├── backend-api/
│   ├── data-layer/
│   ├── infra/
│   └── integration/
└── hooks/             ← Git hooks

app/                   ← FastAPI 소스 (Codex 구현 예정)
cloudrun/              ← Cloud Run 릴레이 (Codex 구현 예정)
scripts/               ← 백업·보존 스크립트 (Codex 구현 예정)
docs/
├── PRD.md
├── API-SPEC.md
├── local-dev-guide.md
└── runbooks/
```

---

## 3. 시스템 흐름

```
[Google Chat]
     │ HTTPS POST
     ▼
[Cloud Run]  ← 이벤트 중계 (GCP, 최소 인스턴스 1)
     │ HTTPS + INTERNAL_API_TOKEN
     ▼
[Caddy]  ← TLS 종료, Rate Limiting (60req/min/IP)
     │
     ▼
[FastAPI]  ← 이벤트 라우팅, 토큰 검증
  │    └── 즉시 처리 → Card JSON 응답
  └── 비동기 → [Celery] → [PostgreSQL / 사내 DB]
                          [Redis]
```

개발 환경: Google Chat → ngrok → localhost:8000 (Cloud Run, Caddy 없음)

---

## 4. 에이전트별 역할

| 에이전트 | 역할 | 읽는 문서 |
|---|---|---|
| Dev | 코드 구현 | product + tech + conventions + api-standards + feature specs |
| QA | 구현 검증 | api-standards + conventions + feature specs |
| Deploy | 배포 | tech + infra/design + infra/tasks + PRD + runbooks |

---

## 5. Stage별 진행 현황

| Stage | 내용 | 태스크 진행 | 상태 |
|---|---|---|---|
| 1 | Card v2 설계 | 4/7 | ✅ 설계 완료 |
| 2 | FastAPI 백엔드 | 6/16 | ✅ 설계 완료 |
| 3 | DB / Redis / Celery | 3/12 | ✅ 설계 완료 |
| 4 | 인프라 | 5/13 | ✅ 설계 완료 |
| 5 | 통합 + 에러 처리 + 로깅 | 4/10 | ✅ 설계 완료 |
| - | app/ 코드 구현 | -/- | 🔲 Codex 예정 |

---

## 6. 주요 설계 결정사항

| 항목 | 결정 |
|---|---|
| Card 버전 | Card v2 (cardsV2) |
| 인증 (Chat → Cloud Run) | Google JWT 검증 |
| 인증 (Cloud Run → 온프레미스) | INTERNAL_API_TOKEN (Bearer) |
| 비동기 처리 | Celery + Redis, 최대 재시도 3회 |
| 사내 DB 쿼리 | configurations 테이블 허용 쿼리만 실행 |
| Rate Limiting | Caddy caddy-ratelimit (60req/min/IP) |
| 온프레미스 연결 | VPN 예정 (공인 IP 없음) |
| 로컬 개발 | ngrok 터널링 |
| 로깅 | JSON 구조화 로그 (/var/log/app/app.log) |
| 백업 | pg_dump 일일, 30일 보존 |

---

## 7. 로컬 개발 시작 방법

```bash
cp .env.dev.example .env.dev
docker compose -f docker-compose.dev.yml up -d
docker compose -f docker-compose.dev.yml exec fastapi alembic upgrade head
ngrok http 8000
# ngrok URL → Google Chat API 콘솔 → HTTP endpoint URL 등록
```

---

## 8. 배포 체크리스트 (운영)

1. .env 파일 작성
2. Google Chat API 활성화, 서비스 계정 생성, Cloud Run 배포
3. 온프레미스 docker compose up -d --build
4. alembic upgrade head + configurations 초기 데이터 삽입
5. Google Chat API 콘솔에 Cloud Run URL 등록
6. GET /health 응답 확인
7. JWT 검증 흐름 확인
8. Celery 태스크 실행 및 재시도 로그 확인
9. backup.sh crontab 등록
10. GitLab CI/CD main 브랜치 push 후 자동 배포 확인

---

## 9. 미완료 항목

- [ ] Add `MONITORING_SPACE_NAME` to `.env.dev.example`
- [ ] Implement `app/services/db_health.py` — connection check per driver (postgres/oracle/mysql)
- [ ] Implement `app/tasks/monitoring.py` — Celery task + card send logic
- [ ] Register Celery Beat schedule in `tasks/celery_app.py`
- [ ] Add `monitoring_detail` dialog handler to `routers/dialog.py`
- [ ] Manual test: trigger task via `celery call tasks.monitoring.run_db_monitor`
- [ ] Implement `db/session.py` (main + internal DB engines)
- [ ] Implement `db/redis.py`
- [ ] Implement `tasks/celery_app.py`
- [ ] Implement `models/db.py` (SQLAlchemy ORM models)
- [ ] Configure Alembic (`alembic init`, `env.py`)
- [ ] Create initial migration (`alembic revision --autogenerate`)
- [ ] Apply migration (`alembic upgrade head`)
- [ ] Insert initial `configurations` data (allowed queries)
- [ ] Set up data retention cron job
- [ ] Implement `core/config.py`
- [ ] Implement `core/auth.py`
- [ ] Implement `models/chat_event.py`
- [ ] Implement `models/db.py` (SQLAlchemy models, including `users.locale`)
- [ ] Implement `routers/health.py`, `webhook.py`, `dialog.py`
- [ ] Implement `services/event_handler.py`
- [ ] Implement `services/card_builder.py`
- [ ] Implement `services/db_query.py`
- [ ] Write unit tests for event routing
- [ ] Integration test with Cloud Run relay
- [ ] Implement `services/card_builder.py` error_card
- [ ] Implement extended `/health` with DB + Redis checks
- [ ] Implement `core/logging.py` JSON formatter
- [ ] End-to-end test: Chat → Cloud Run → FastAPI → response
- [ ] Verify Celery retry behavior (3x max)
- [ ] Verify failure card sent after max retries
- [ ] Add `settings` keyword routing in `app/services/event_handler.py`
- [ ] Add `admin` keyword routing in `app/services/event_handler.py`
- [ ] Implement `admin_service.py` — `is_admin(google_id)` check via `configurations.admin_users`, `can_run_query(google_id)` check via `configurations.user_permissions`
- [ ] Add `locale` column to `users` table via Alembic migration
- [ ] Implement `i18n(key, locale)` helper in `app/services/card_builder.py`
- [ ] Add locale string files / dict for `en` and `ko`
- [ ] Pass `locale` to all `build_template()` calls in event_handler and tasks
- [ ] `user_settings` — locale change form + save handler (all users)
- [ ] `admin_main` — main menu dialog
- [ ] `admin_query_list` — query list dialog
- [ ] `admin_query_add` — query add form + submit handler
- [ ] `admin_query_delete` — query delete form
- [ ] `admin_alert_actions` — alert action mapping form + save handler
- [ ] `admin_user_permissions` — user permission form + save handler
- [ ] `admin_query_delete_confirm` — delete confirmation + execute
- [ ] `admin_template_gallery` — card template preview list
- [ ] Add `build_template(name, data, locale="en")` function
- [ ] Add `TEMPLATE_SAMPLES` dict for all 12 templates (A~L)
- [ ] Verify `settings` keyword opens user settings dialog for all users
- [ ] Verify locale change updates `users.locale` and subsequent cards use new locale
- [ ] Verify unauthorized user gets "Unauthorized." response for `admin` keyword
- [ ] Verify query add → appears in `configurations.allowed_queries`
- [ ] Verify query delete → removed from `configurations.allowed_queries`
- [ ] Verify all 12 templates render without error in preview dialog
- [ ] Write `docker-compose.yml`
- [ ] Write `Dockerfile`
- [ ] Write `Caddyfile`
- [ ] Write `cloudrun/main.py`
- [ ] Write `.gitlab-ci.yml`
- [ ] Write `backup.sh` + register crontab
- [ ] Deploy Cloud Run and verify relay
- [ ] Verify Caddy TLS certificate issued
- [ ] Implement `card_builder.py` service
- [ ] Test all widgets in Card Builder
- [ ] Verify webhook receives events from Google Chat

---

## 10. 설계 보완 필요 항목

없음
