# Hooks

## Kiro Hooks (`.kiro/hooks/`)
Kiro 자동화 스크립트 — Kiro agent가 직접 실행.

| 파일 | 역할 |
|---|---|
| `lint-docs.sh` | `.kiro/specs/` 문서 구조 검증 |
| `update-review.sh` | `REVIEW.md` 자동 재생성 |

## Git Hooks (`.kiro/hooks/git/`)
Git 이벤트에 연결되는 hook 소스 파일.
`.git/hooks/`에 직접 복사해서 사용 (`.gitignore` 대상인 `.git/`은 버전 관리 불가).

| 파일 | Git 이벤트 | 역할 |
|---|---|---|
| `pre-commit` | `git commit` 전 | doc lint + ruff check/format |
| `commit-msg` | 커밋 메시지 저장 전 | Conventional Commits 형식 검증 |
| `prepare-commit-msg` | 커밋 메시지 편집기 열기 전 | 브랜치명에서 이슈 번호 자동 삽입 |

### 설치 (최초 1회)
```bash
sh .kiro/hooks/git/install.sh
```
