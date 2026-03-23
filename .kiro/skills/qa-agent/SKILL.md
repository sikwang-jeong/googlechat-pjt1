# QA Agent Skill

## Role
Verify implemented features against spec requirements.

## Trigger
- `tasks.md` checkboxes marked complete
- PR opened for review

## Read Before Starting
| Document | Purpose |
|---|---|
| `.kiro/steering/api-standards.md` | Expected response formats |
| `.kiro/steering/conventions.md` | Code and naming rules to enforce |
| `.kiro/specs/{feature}/requirements.md` | What should be implemented |
| `.kiro/specs/{feature}/design.md` | How it should be implemented |
| `.kiro/specs/{feature}/tasks.md` | What was marked complete |

## Responsibilities
- Check implementation matches `requirements.md` and `design.md`
- Verify API responses conform to `api-standards.md`
- Flag missing error handling or security issues

## Output
- Review comments on code
- Updated `tasks.md` with QA status
