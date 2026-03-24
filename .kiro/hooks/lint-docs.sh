#!/bin/bash
# lint-docs.sh
# Cross-validates .kiro design docs for consistency.
# Writes warnings to .kiro/hooks/.lint-warnings for REVIEW.md.

ERRORS=0
WARNINGS=()
WARN_FILE=".kiro/hooks/.lint-warnings"
> "$WARN_FILE"

warn() { WARNINGS+=("$1"); }
fail() { echo "ERROR: $1"; ERRORS=$((ERRORS + 1)); }

# ── 1. Required files exist ──────────────────────────────────────────────────
for spec in .kiro/specs/*/; do
  for f in requirements.md design.md tasks.md; do
    [ ! -f "${spec}${f}" ] && fail "MISSING: ${spec}${f}"
  done
done

for f in product.md tech.md api-standards.md conventions.md; do
  [ ! -f ".kiro/steering/$f" ] && fail "MISSING: .kiro/steering/$f"
done

# ── 2. Redis keys: backend-api uses → data-layer defines ────────────────────
# Extract keys like `executed:{message_name}:{function}` from backend-api
USED_KEYS=$(grep -oP '`[a-z_]+(?::[a-z_{}\|]+)+`' .kiro/specs/backend-api/design.md 2>/dev/null | tr -d '`' | sort -u)
# Normalize {xxx} → {} for pattern matching
normalize() { echo "$1" | sed 's/{[^}]*}/{}/g'; }

while IFS= read -r key; do
  [ -z "$key" ] && continue
  norm=$(normalize "$key")
  found=0
  while IFS= read -r defined; do
    [ -z "$defined" ] && continue
    def_norm=$(normalize "$defined")
    [ "$norm" = "$def_norm" ] && found=1 && break
  done < <(grep -oP '`[a-z_]+(?::[a-z_{}\|]+)+`' .kiro/specs/data-layer/design.md 2>/dev/null | tr -d '`')
  [ "$found" -eq 0 ] && warn "Redis key '$key' used in backend-api/design.md but not defined in data-layer/design.md"
done <<< "$USED_KEYS"

# ── 3. CARD_CLICKED functions: backend-api ↔ card-interaction ───────────────
# Functions defined in backend-api routing table
API_FUNCS=$(grep -oP '`(open_dialog|run_query|refresh_card)`' .kiro/specs/backend-api/design.md | tr -d '`' | sort -u)
# Functions referenced in card-interaction button examples
CARD_FUNCS=$(grep -oP '"function": "[a-z_]+"' .kiro/specs/card-interaction/design.md | grep -oP '[a-z_]+(?=")' | tail -n +1 | sort -u)

while IFS= read -r fn; do
  [ -z "$fn" ] && continue
  echo "$CARD_FUNCS" | grep -qx "$fn" || \
    warn "CARD_CLICKED function '$fn' defined in backend-api/design.md but not shown in card-interaction/design.md button examples"
done <<< "$API_FUNCS"

# ── 4. Endpoints: card-interaction ↔ infra Cloud Run relay ──────────────────
CI_ENDPOINTS=$(grep -oP '(POST|GET) /[a-z/]+' .kiro/specs/card-interaction/design.md | sort -u)
# Normalize multiple spaces to single space
CR_ENDPOINTS=$(grep -oP '(POST|GET)\s+/[a-z/]+' .kiro/specs/infra/design.md | tr -s ' ' | sort -u)

while IFS= read -r ep; do
  [ -z "$ep" ] && continue
  echo "$CR_ENDPOINTS" | grep -qF "$ep" || \
    warn "Endpoint '$ep' in card-interaction/design.md not found in infra Cloud Run relay design"
done <<< "$CI_ENDPOINTS"

# ── 5. Celery task payload: backend-api ↔ integration ───────────────────────
# Check required payload fields appear in both files
for field in query_key space_name thread_name user_google_id message_name; do
  grep -q "\"$field\"" .kiro/specs/backend-api/design.md || \
    warn "Celery task payload field '$field' missing in backend-api/design.md"
  grep -q "\"$field\"" .kiro/specs/integration/design.md || \
    warn "Celery task payload field '$field' missing in integration/design.md"
done

# ── 6. HTTP status codes: integration ↔ api-standards ───────────────────────
# api-standards defines: 200, 401, 400, 502
# integration error table should not use undefined codes
INTEG_CODES=$(grep -oP 'HTTP \d+|\b[45]\d\d\b' .kiro/specs/integration/design.md | grep -oP '\d{3}' | sort -u)
ALLOWED_CODES="200 400 401 502"
while IFS= read -r code; do
  [ -z "$code" ] && continue
  echo "$ALLOWED_CODES" | grep -qw "$code" || \
    warn "HTTP status $code used in integration/design.md but not defined in api-standards.md"
done <<< "$INTEG_CODES"

# ── 7. Health check response: integration ↔ backend-api router ──────────────
grep -q '/health' .kiro/specs/backend-api/design.md || \
  warn "/health endpoint not referenced in backend-api/design.md"
grep -q '/health' .kiro/specs/integration/design.md || \
  warn "/health endpoint not referenced in integration/design.md"

# ── 8. Warn on implementation tasks checked without app/ file ────────────────
while IFS= read -r line; do
  file=$(echo "$line" | grep -oP '`[^`]+\.py`' | tr -d '`' | head -1)
  if [ -n "$file" ] && [ ! -f "app/$file" ]; then
    echo "WARN: tasks.md marks [x] for $file but app/$file does not exist"
  fi
done < <(grep -rh '^\- \[x\].*Implement' .kiro/specs/ 2>/dev/null)

# ── 9. Cross-check: design features reflected in requirements ────────────────
# alert_actions in admin/design.md → should appear in admin/requirements.md
grep -q 'alert_actions\|Alert Action' .kiro/specs/admin/design.md && \
  ! grep -qi 'alert.action' .kiro/specs/admin/requirements.md && \
  warn "admin/design.md has alert_actions but admin/requirements.md has no alert action requirement"

# user_permissions in admin/design.md → should appear in admin/requirements.md
grep -q 'user_permissions\|User Permission' .kiro/specs/admin/design.md && \
  ! grep -qi 'user.permission\|can_run_query' .kiro/specs/admin/requirements.md && \
  warn "admin/design.md has user_permissions but admin/requirements.md has no user permission requirement"

# /webhook/alert in backend-api/design.md → should appear in backend-api/requirements.md
grep -q '/webhook/alert' .kiro/specs/backend-api/design.md && \
  ! grep -q '/webhook/alert' .kiro/specs/backend-api/requirements.md && \
  warn "backend-api/design.md has /webhook/alert but backend-api/requirements.md missing R for it"

# /report/ in backend-api/design.md → should appear in backend-api/requirements.md
grep -q '/report/' .kiro/specs/backend-api/design.md && \
  ! grep -q '/report/' .kiro/specs/backend-api/requirements.md && \
  warn "backend-api/design.md has /report/{alert_id} but backend-api/requirements.md missing R for it"

# alerts table in data-layer/design.md → should appear in data-layer/requirements.md
grep -q 'CREATE TABLE alerts' .kiro/specs/data-layer/design.md && \
  ! grep -qi 'alert' .kiro/specs/data-layer/requirements.md && \
  warn "data-layer/design.md has alerts table but data-layer/requirements.md does not mention it"

# i18n/locale in admin/design.md → should appear in admin/requirements.md
grep -q 'users.locale\|i18n' .kiro/specs/admin/design.md && \
  ! grep -qi 'locale\|i18n\|language' .kiro/specs/admin/requirements.md && \
  warn "admin/design.md has i18n/locale but admin/requirements.md has no language requirement"

# Cross-check: design features reflected in tasks ────────────────────────────
# alert_actions dialog in admin/design.md → should appear in admin/tasks.md
grep -q 'admin_alert_actions' .kiro/specs/admin/design.md && \
  ! grep -q 'admin_alert_actions' .kiro/specs/admin/tasks.md && \
  warn "admin/design.md has admin_alert_actions dialog but admin/tasks.md missing task"

# user_permissions dialog in admin/design.md → should appear in admin/tasks.md
grep -q 'admin_user_permissions' .kiro/specs/admin/design.md && \
  ! grep -q 'admin_user_permissions' .kiro/specs/admin/tasks.md && \
  warn "admin/design.md has admin_user_permissions dialog but admin/tasks.md missing task"

# /webhook/alert in backend-api/design.md → should appear in backend-api/tasks.md
grep -q '/webhook/alert\|alert.py' .kiro/specs/backend-api/design.md && \
  ! grep -q 'alert' .kiro/specs/backend-api/tasks.md && \
  warn "backend-api/design.md has alert endpoint but backend-api/tasks.md missing task"


for w in "${WARNINGS[@]}"; do
  echo "$w" >> "$WARN_FILE"
done

if [ "${#WARNINGS[@]}" -gt 0 ]; then
  echo "Design gap warnings (${#WARNINGS[@]}):"
  for w in "${WARNINGS[@]}"; do echo "  ⚠ $w"; done
  echo ""
fi

if [ "$ERRORS" -gt 0 ]; then
  echo "Doc lint failed with $ERRORS error(s). Fix before committing."
  exit 1
fi

echo "Doc lint passed."
exit 0
