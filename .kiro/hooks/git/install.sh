#!/bin/sh
# Install git hooks from .kiro/hooks/git/ → .git/hooks/
HOOKS_DIR="$(git rev-parse --show-toplevel)/.kiro/hooks/git"
GIT_HOOKS_DIR="$(git rev-parse --show-toplevel)/.git/hooks"

for hook in pre-commit commit-msg prepare-commit-msg; do
  cp "$HOOKS_DIR/$hook" "$GIT_HOOKS_DIR/$hook"
  chmod +x "$GIT_HOOKS_DIR/$hook"
  echo "Installed: $hook"
done
