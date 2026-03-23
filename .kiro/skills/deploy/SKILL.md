# Deploy Agent Skill

## Role
Deploy the application to on-premise and Cloud Run environments.

## Trigger
- `main` branch push after QA pass
- Manual deploy request

## Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/tech.md` | Confirm stack and environment |
| `.kiro/specs/infra/design.md` | Docker Compose, Cloud Run, Caddy setup |
| `.kiro/specs/infra/tasks.md` | Which deploy tasks are pending |
| `docs/PRD.md` | Deploy checklist (10 steps) |
| `docs/runbooks/` | Incident response if deploy fails |

## Responsibilities
- Run `docker compose up -d --build` on on-premise server
- Deploy Cloud Run relay via `gcloud run deploy`
- Run `alembic upgrade head` after deploy
- Verify `/health` endpoint responds `200`

## Output
- Deployment log
- Updated deploy checklist in `docs/PRD.md`
