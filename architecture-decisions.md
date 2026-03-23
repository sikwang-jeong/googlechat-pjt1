# Google Chat 카드 메시지 인터랙션 시스템 — 아키텍처 설계 결정사항

> 작성일: 2026-03-23  
> 규모: 1~10명, 동시접속 100명 미만, MAU 10,000 미만  
> 스택: Python/FastAPI, PostgreSQL, Redis, Docker, GCP + 온프레미스 VM

---

## Stage 1 — Google Chat 카드 설계

| 항목 | 선택 |
|---|---|
| 카드 버전 | Card v2 (`cardsV2`) |
| 텍스트 위젯 | TextParagraph + DecoratedText 혼용 |
| 입력 위젯 | TextInput + SelectionInput + DateTimePicker 전부 |
| 액션 위젯 | ButtonList + ImageButton 조합 |
| 인터랙션 패턴 | 버튼 액션 + 폼 제출 + 다이얼로그 전부 |
| 이벤트 전달 방식 | HTTP 엔드포인트 (Chat → FastAPI 직접 POST) |
| 카드 업데이트 전략 | 동기 업데이트 + 비동기 REST + 새 메시지 전부 |

### 도출된 Webhook 엔드포인트
- `POST /webhook/chat` — 버튼 클릭, 메시지, 스페이스 이벤트 수신
- `POST /webhook/chat/dialog` — 다이얼로그 폼 제출 수신
- `GET /health` — Chat App 연결 확인용

---

## Stage 2 — 백엔드 API 아키텍처

| 항목 | 선택 |
|---|---|
| 엔드포인트 구조 | 메인 webhook + 다이얼로그 전용 엔드포인트 분리 |
| 데이터 모델 | Pydantic (핵심 필드만 정의, 나머지 유연하게) |
| 인증 전략 | Google 서비스 계정 JWT 검증 |
| Rate Limiting | Caddy 리버스 프록시 (Nginx 대체) |
| 비동기 처리 | Celery + Redis (백그라운드 작업 큐) |

---

## Stage 3 — 데이터 레이어 설계

| 항목 | 선택 |
|---|---|
| 테이블 구성 | 6개 테이블 |
| 스키마 설계 | 표준 컬럼 + JSONB metadata |
| 마이그레이션 도구 | Alembic |
| Redis 캐싱 | JWT + 사용자 정보 + 쿼리 결과 + 다이얼로그 세션 |
| 데이터 보존 | 테이블별 차등 정책 |
| 커넥션 풀링 | SQLAlchemy 비동기 풀 (asyncpg) |
| 다중 DB 연결 방식 | DB별 개별 SQLAlchemy 엔진 |
| DB 드라이버 | asyncpg (PG) + python-oracledb (Oracle) + aiomysql (MySQL) |
| SQL 제약 방식 | 미리 정의된 쿼리만 허용 |
| 쿼리 관리 위치 | configurations 테이블에 저장 |

### 테이블 목록
| 테이블 | 역할 | 보존 기간 |
|---|---|---|
| `users` | Google Chat 사용자 정보 | 무기한 |
| `events` | 카드 인터랙션 이벤트 기록 | 6개월 |
| `tasks` | Celery 작업 상태 추적 | 3개월 |
| `audit_logs` | 변경 이력 감사 추적 | 1년 |
| `notifications` | 발송 알림 이력 | 3개월 |
| `configurations` | 시스템 설정 + 허용 쿼리 저장 | 무기한 |

### Redis 키 패턴
| 용도 | 키 패턴 | TTL |
|---|---|---|
| JWT 검증 결과 | `auth:jwt:{token_hash}` | 5분 |
| 사용자 정보 | `user:{google_id}` | 1시간 |
| 쿼리 결과 캐시 | `query:{hash}` | 10분 |
| 다이얼로그 세션 | `session:dialog:{user_id}:{dialog_id}` | 30분 |

### 사내 DB 연결 대상
| DB | 드라이버 | 용도 |
|---|---|---|
| PostgreSQL (사내) | asyncpg | 사내 업무 데이터 조회 |
| Oracle | python-oracledb | 레거시 데이터 조회 |
| MySQL | aiomysql | 사내 업무 데이터 조회 |

---

## Stage 4 — 인프라 아키텍처

| 항목 | 선택 |
|---|---|
| 컨테이너 오케스트레이션 | Docker Compose |
| GCP 서비스 | Cloud Run (Google Chat 이벤트 수신 중계점) |
| GCP ↔ 온프레미스 연결 | HTTPS + 인증 토큰 |
| 비용 최적화 | Cloud Run 최소 인스턴스 1 유지 |
| 백업 | pg_dump 스크립트 로컬 저장 |

### Docker Compose 컨테이너 구성
- FastAPI (백엔드 API)
- Celery Worker (비동기 작업)
- PostgreSQL (메인 DB)
- Redis (캐시 + Celery 브로커)
- Caddy (리버스 프록시 + Rate Limiting)

### 월 예상 비용
| 항목 | 비용 |
|---|---|
| Cloud Run (최소 인스턴스 1) | $5~10 |
| 온프레미스 VM | 기존 비용 |
| 기타 GCP | $0 |
| **합계** | **$5~10/월** |

---

## Stage 5 — 통합 블루프린트

| 항목 | 선택 |
|---|---|
| 메시지 흐름 | 직접 전달 + Cloud Run 이벤트 타입 분기 |
| 에러 처리 | 구간별 에러 처리 + Celery 자동 재시도 (최대 3회) |
| 로깅 | 로컬 파일 로그 (JSON 구조화) |
| 모니터링 | Uptime 헬스체크 엔드포인트 |
| 배포 방식 | GitLab CI/CD |

### 시스템 흐름
```
[Google Chat]
     │ HTTPS POST
     ▼
[Cloud Run] ── 이벤트 타입 분기
     │ HTTPS + JWT 토큰
     ▼
[Caddy] ── Rate Limiting
     │
     ▼
[FastAPI] ── JWT 검증
  │    │
  │    └── 즉시처리 → 동기 카드 응답
  │
  └── 비동기처리
       │
       ▼
  [Celery Worker]
    │       │
    ▼       ▼
[PostgreSQL] [사내 DB]
(메인)    Oracle/PG/MySQL
    │
    ▼
[Redis]
Celery 브로커 + 캐시
```

### 5대 핵심 리스크 및 대응
| 리스크 | 대응 |
|---|---|
| Cloud Run ↔ 온프레미스 연결 장애 | 헬스체크 + 에러 카드 즉시 반환 |
| 사내 DB 연결 실패 | 구간별 에러 처리 + 사용자 안내 메시지 |
| JWT 검증 우회 시도 | Google 공개키 주기적 갱신 + IP 제한 병행 |
| pg_dump 백업 유실 | 백업 스크립트 실행 결과 로그 보존 |
| Celery 작업 무한 적체 | 최대 재시도 3회 + 실패 시 알림 카드 발송 |

---

## 다음 작업 (미완료)

- [ ] Stage별 상세 구현 가이드 (컴포넌트별 설정 방법)
  - [ ] Stage 1: Card v2 JSON 구조, webhook 설정
  - [ ] Stage 2: FastAPI 프로젝트 구조, 엔드포인트, JWT 미들웨어
  - [ ] Stage 3: PostgreSQL 스키마, Alembic 설정, 다중 DB 연결
  - [ ] Stage 4: Docker Compose 구성, Cloud Run 설정, Caddy 설정, GitLab CI/CD
  - [ ] Stage 5: 전체 흐름 시퀀스, 에러 처리 흐름, 헬스체크 설계
- [ ] 전체 배포 체크리스트 (10단계)
