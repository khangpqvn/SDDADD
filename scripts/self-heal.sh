#!/usr/bin/env bash
# self-heal.sh — Self-Healing Loop cho SDD+ADD workflow
# Reference: Slide 11.4 — Automated Self-Healing Loop
#
# Flow: run tests → capture errors → invoke Claude to fix → re-test → auto commit if pass
# Safety: max 3 fix attempts; escalates to human on failure
#
# Usage:
#   ./scripts/self-heal.sh                    # Run all tests
#   ./scripts/self-heal.sh --test-cmd "npm run test:unit"
#   ./scripts/self-heal.sh --feature=auth     # Scope to feature tests
#   ./scripts/self-heal.sh --max-attempts=2   # Override retry limit
#   ./scripts/self-heal.sh --dry-run          # Show plan without executing

set -euo pipefail

# ─── Config ───────────────────────────────────────────────────────────────────
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"
TEST_CMD="${TEST_CMD:-npm test}"
FEATURE_SLUG=""
DRY_RUN=false
LOG_DIR=".sdd/reviews"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="${LOG_DIR}/self-heal-${TIMESTAMP}.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ─── Arg Parsing ──────────────────────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --test-cmd=*)   TEST_CMD="${arg#*=}" ;;
    --feature=*)    FEATURE_SLUG="${arg#*=}" ;;
    --max-attempts=*) MAX_ATTEMPTS="${arg#*=}" ;;
    --dry-run)      DRY_RUN=true ;;
    *)              echo "Unknown arg: $arg"; exit 1 ;;
  esac
done

# Scope test command to feature if provided
if [[ -n "$FEATURE_SLUG" ]]; then
  TEST_CMD="$TEST_CMD -- --testPathPattern=$FEATURE_SLUG"
fi

# ─── Safety checks ────────────────────────────────────────────────────────────
if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "${BLUE}[DRY RUN] Self-Heal config:${NC}"
  echo "  Test command : $TEST_CMD"
  echo "  Max attempts : $MAX_ATTEMPTS"
  echo "  Feature scope: ${FEATURE_SLUG:-all}"
  echo "  Log file     : $LOG_FILE"
  exit 0
fi

# Ensure .sdd/reviews directory exists
mkdir -p "$LOG_DIR"

# Verify we're in a git repo with clean working state (except uncommitted fixes)
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo -e "${RED}[ERROR] Not in a git repository. Aborting.${NC}"
  exit 1
fi

# ─── Logging helpers ──────────────────────────────────────────────────────────
log() { echo -e "$1" | tee -a "$LOG_FILE"; }

log_section() {
  log ""
  log "${BLUE}══════════════════════════════════════════${NC}"
  log "${BLUE}  $1${NC}"
  log "${BLUE}══════════════════════════════════════════${NC}"
}

# ─── Test runner ──────────────────────────────────────────────────────────────
run_tests() {
  local output
  local exit_code=0
  output=$(eval "$TEST_CMD" 2>&1) || exit_code=$?
  echo "$output" >> "$LOG_FILE"
  echo "$output"
  return $exit_code
}

# ─── Error extractor ──────────────────────────────────────────────────────────
# Extracts failed test names and error messages for Claude context
extract_errors() {
  local test_output="$1"
  echo "$test_output" | grep -E "(FAIL|✗|×|Error:|expect\(|●)" | head -50
}

# ─── Claude fix invocation ────────────────────────────────────────────────────
# Calls Claude CLI to analyze errors and suggest fixes
# NOTE: Requires `claude` CLI installed and authenticated
invoke_claude_fix() {
  local error_summary="$1"
  local attempt="$2"

  log "${YELLOW}[ATTEMPT $attempt/$MAX_ATTEMPTS] Invoking Claude to analyze errors...${NC}"

  # Check if claude CLI is available
  if ! command -v claude &> /dev/null; then
    log "${YELLOW}[WARN] claude CLI not found. Skipping auto-fix.${NC}"
    log "${YELLOW}       Install: https://claude.ai/code${NC}"
    return 1
  fi

  local prompt
  prompt=$(cat <<EOF
You are a Senior Engineer fixing test failures.
Analyze these test errors and fix the code:

FAILED TESTS:
$error_summary

RULES:
1. Follow Fix the Spec NOT the Code — if business logic is wrong, update .sdd/features/*/SPEC.md
2. Follow CONSTITUTION.md constraints
3. No hardcoded secrets, no raw DELETE without WHERE
4. Fix root cause, not symptoms
5. Keep changes minimal and focused

Apply fixes now.
EOF
)

  # Invoke Claude with auto-approve for safe operations
  claude --print "$prompt" 2>> "$LOG_FILE" || return 1
}

# ─── Auto commit ──────────────────────────────────────────────────────────────
auto_commit() {
  local attempt="$1"
  local feature_ref="${FEATURE_SLUG:+($FEATURE_SLUG)}"

  # Only commit if there are changes
  if git diff --quiet && git diff --cached --quiet; then
    log "${YELLOW}[COMMIT] No changes to commit.${NC}"
    return 0
  fi

  # Stage all modified tracked files (not new untracked files — human decides those)
  git add -u

  local commit_msg="fix${feature_ref}: self-heal pass after ${attempt} attempt(s) — all tests green"
  git commit -m "$commit_msg" >> "$LOG_FILE" 2>&1

  log "${GREEN}[COMMIT] Auto-committed: $commit_msg${NC}"
}

# ─── Escalation ───────────────────────────────────────────────────────────────
escalate_to_human() {
  local error_summary="$1"
  local incident_file="${LOG_DIR}/self-heal-incident-${TIMESTAMP}.md"

  cat > "$incident_file" <<EOF
# Self-Heal Incident Report

**Date:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Status:** ESCALATED — Requires Human Review
**Feature:** ${FEATURE_SLUG:-all}
**Attempts:** $MAX_ATTEMPTS (exhausted)

## Failed Test Errors

\`\`\`
$error_summary
\`\`\`

## Next Steps for Human Director

1. Review errors above
2. Check if Spec needs updating: \`.sdd/features/${FEATURE_SLUG:-*}/SPEC.md\`
3. Apply manual fix
4. Re-run: \`./scripts/self-heal.sh ${FEATURE_SLUG:+--feature=$FEATURE_SLUG}\`

## Log File
\`$LOG_FILE\`
EOF

  log ""
  log "${RED}╔══════════════════════════════════════════╗${NC}"
  log "${RED}║  ⚠️  ESCALATION REQUIRED                   ║${NC}"
  log "${RED}║  Max attempts ($MAX_ATTEMPTS) exhausted      ║${NC}"
  log "${RED}║  Incident: $incident_file  ║${NC}"
  log "${RED}╚══════════════════════════════════════════╝${NC}"
  log ""
  log "AI RECOMMENDATION: PENDING HUMAN REVIEW"
  log "HUMAN DECISION REQUIRED: Review test failures and fix Spec or code"
  log "NEXT STEP: Human Director reviews $incident_file"
}

# ─── Main Loop ────────────────────────────────────────────────────────────────
main() {
  log_section "Self-Healing Loop Started — $(date)"
  log "Config: cmd='$TEST_CMD' | max_attempts=$MAX_ATTEMPTS | feature=${FEATURE_SLUG:-all}"

  local attempt=0
  local test_output
  local errors

  # Initial test run
  log_section "Initial Test Run"
  if test_output=$(run_tests 2>&1); then
    log "${GREEN}✅ All tests PASS on initial run. No healing needed.${NC}"
    exit 0
  fi

  errors=$(extract_errors "$test_output")
  log "${RED}❌ Tests FAILED. Starting heal loop...${NC}"
  log "Errors detected:"
  log "$errors"

  # Heal loop — max 3 attempts
  while [[ $attempt -lt $MAX_ATTEMPTS ]]; do
    attempt=$((attempt + 1))
    log_section "Heal Attempt $attempt / $MAX_ATTEMPTS"

    # Invoke Claude to fix
    if ! invoke_claude_fix "$errors" "$attempt"; then
      log "${YELLOW}[WARN] Claude fix invocation failed or skipped on attempt $attempt.${NC}"
    fi

    # Re-run tests
    log "Re-running tests after fix attempt $attempt..."
    if test_output=$(run_tests 2>&1); then
      log ""
      log "${GREEN}╔══════════════════════════════════════════╗${NC}"
      log "${GREEN}║  ✅ ALL TESTS PASS after attempt $attempt    ║${NC}"
      log "${GREEN}╚══════════════════════════════════════════╝${NC}"

      # Auto commit the fix
      auto_commit "$attempt"

      log ""
      log "${GREEN}Self-Heal COMPLETE. Log: $LOG_FILE${NC}"
      exit 0
    fi

    # Extract new errors for next attempt
    errors=$(extract_errors "$test_output")
    log "${RED}Tests still failing after attempt $attempt.${NC}"

    if [[ $attempt -lt $MAX_ATTEMPTS ]]; then
      log "Retrying with updated error context..."
    fi
  done

  # All attempts exhausted
  escalate_to_human "$errors"
  exit 1
}

main
