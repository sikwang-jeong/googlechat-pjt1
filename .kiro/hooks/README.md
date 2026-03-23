# Git Hooks Setup

Hooks are in `.kiro/hooks/`. Run this once to activate:

```bash
cp .kiro/hooks/pre-commit .git/hooks/pre-commit
cp .kiro/hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
```

## Hooks

| Hook | Runs | Action |
|---|---|---|
| `pre-commit` | Before every commit | `ruff check` + `ruff format --check` |
| `pre-push` | Before every push | `pytest tests/` |
