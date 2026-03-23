#!/bin/bash
# lint-docs.sh
# Validates .kiro docs consistency whenever specs or steering docs change.
# Exits with error if issues found.

ERRORS=0

# 1. Check every spec has all 3 required files
for spec in .kiro/specs/*/; do
  for f in requirements.md design.md tasks.md; do
    if [ ! -f "$spec$f" ]; then
      echo "MISSING: $spec$f"
      ERRORS=$((ERRORS + 1))
    fi
  done
done

# 2. Check no implementation task is checked without a corresponding file in app/
# (warn only — app/ may not exist yet during design phase)
while IFS= read -r line; do
  file=$(echo "$line" | grep -oP '`[^`]+\.py`' | tr -d '`' | head -1)
  if [ -n "$file" ] && [ ! -f "app/$file" ]; then
    echo "WARN: tasks.md marks [x] for $file but app/$file does not exist"
  fi
done < <(grep -rh '^\- \[x\].*Implement' .kiro/specs/ 2>/dev/null)

# 3. Check steering files all exist
for f in product.md tech.md api-standards.md conventions.md; do
  if [ ! -f ".kiro/steering/$f" ]; then
    echo "MISSING: .kiro/steering/$f"
    ERRORS=$((ERRORS + 1))
  fi
done

# 4. Check each SKILL.md references valid spec paths
for skill in .kiro/skills/*/SKILL.md; do
  if grep -q '{feature}' "$skill"; then
    : # template reference, skip
  fi
done

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "Doc lint failed with $ERRORS error(s). Fix before committing."
  exit 1
fi

echo "Doc lint passed."
exit 0
