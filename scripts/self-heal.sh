#!/usr/bin/env bash
# Opt-in bounded recovery evidence collector for SDD + ADD.
# This script never edits source, approves work, commits, pushes, or deploys.
# A Claude CLI print invocation, when enabled, analyzes output only; it does not
# claim or request filesystem mutation.
#
# Usage:
#   ./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
#     --test-cmd="<exact approved command>" \
#     --approved-evidence=.sdd/architecture-profile.md \
#     --max-attempts=1 \
#     --scope-category=implementation-defect
#
# The command must be an approved `- Command: <exact command>` entry in the
# approved Architecture Profile and match the feature task's exact verification
# command. Shell operators, redirects, substitutions, quotes, and newlines are
# rejected so this script never evaluates an untrusted command string.

set -euo pipefail

TEST_CMD=""
FEATURE_SLUG=""
TASK_ID=""
APPROVED_EVIDENCE=""
MAX_ATTEMPTS=""
SCOPE_CATEGORY=""
DRY_RUN=false
LOG_DIR=".sdd/reviews"
TIMESTAMP="$(date -u +%Y%m%d-%H%M%SZ)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
    --test-cmd="<exact approved command>" \
    --approved-evidence=<repo-relative-path> \
    --max-attempts=1 \
    --scope-category=implementation-defect [--dry-run]

Required scope categories:
  implementation-defect
  spec-gap
  profile-config-gap
  shared-public-contract
  schema-business-data-mutation
  security-permission-dependency-runtime-config
  external-irreversible-side-effect

Only implementation-defect is eligible for bounded recovery analysis. This
script does not perform repairs. It writes structured evidence for a Human or
an approved interactive agent session to act on.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --feature=*) FEATURE_SLUG="${arg#*=}" ;;
    --task=*) TASK_ID="${arg#*=}" ;;
    --test-cmd=*) TEST_CMD="${arg#*=}" ;;
    --approved-evidence=*) APPROVED_EVIDENCE="${arg#*=}" ;;
    --max-attempts=*) MAX_ATTEMPTS="${arg#*=}" ;;
    --scope-category=*) SCOPE_CATEGORY="${arg#*=}" ;;
    --dry-run) DRY_RUN=true ;;
    --help|-h) usage; exit 0 ;;
    *) printf '[ERROR] Invalid argument: %s\n' "$arg" >&2; usage; exit 2 ;;
  esac
done

require_value() {
  local name="$1"
  local value="$2"
  if [[ -z "$value" ]]; then
    printf '[ERROR] Required argument missing: %s\n' "$name" >&2
    exit 2
  fi
}

require_value '--feature' "$FEATURE_SLUG"
require_value '--task' "$TASK_ID"
require_value '--test-cmd' "$TEST_CMD"
require_value '--approved-evidence' "$APPROVED_EVIDENCE"
require_value '--max-attempts' "$MAX_ATTEMPTS"
require_value '--scope-category' "$SCOPE_CATEGORY"

if [[ "$MAX_ATTEMPTS" != "1" ]]; then
  printf '[ERROR] --max-attempts must be 1: this evidence collector executes the approved command once and never retries or repairs.\n' >&2
  exit 2
fi

case "$SCOPE_CATEGORY" in
  implementation-defect|spec-gap|profile-config-gap|shared-public-contract|schema-business-data-mutation|security-permission-dependency-runtime-config|external-irreversible-side-effect) ;;
  *) printf '[ERROR] Unknown --scope-category: %s\n' "$SCOPE_CATEGORY" >&2; exit 2 ;;
esac

if [[ "$SCOPE_CATEGORY" != "implementation-defect" ]]; then
  printf '[BLOCKED] --scope-category=%s is outside the bounded recovery scope. Use the required SDD update or Human checkpoint path instead.\n' "$SCOPE_CATEGORY" >&2
  exit 2
fi

TASK_FILE=".sdd/features/$FEATURE_SLUG/TASKS.md"
if [[ ! "$FEATURE_SLUG" =~ ^[a-z0-9][a-z0-9-]*$ || ! "$TASK_ID" =~ ^T[0-9]+$ ]]; then
  printf '[ERROR] --feature and --task must identify a feature slug and task ID.\n' >&2
  exit 2
fi

if [[ "$APPROVED_EVIDENCE" != ".sdd/architecture-profile.md" || ! -f "$APPROVED_EVIDENCE" ]]; then
  printf '[ERROR] --approved-evidence must be the approved .sdd/architecture-profile.md.\n' >&2
  exit 2
fi

if [[ ! -f "$TASK_FILE" ]]; then
  printf '[ERROR] Task evidence not found: %s\n' "$TASK_FILE" >&2
  exit 2
fi

# Do not pass arbitrary shell syntax to an interpreter.
if [[ "$TEST_CMD" == *$'\n'* || "$TEST_CMD" =~ [\;\|\&\<\>\$\`\(\)\'\"] ]]; then
  printf '[ERROR] --test-cmd contains unsupported shell syntax. Use a plain executable and arguments.\n' >&2
  exit 2
fi

if ! grep -Fqx -- "- Command: $TEST_CMD" "$APPROVED_EVIDENCE"; then
  printf '[ERROR] --test-cmd is not an exact approved command entry in %s.\n' "$APPROVED_EVIDENCE" >&2
  exit 2
fi

has_valid_human_review() {
  local file="$1"
  awk '
    function is_non_placeholder(value) {
      return value !~ /^[[:space:]]*(<.*>|TBD|TODO|PENDING)?[[:space:]]*$/
    }
    function is_leap_year(year) {
      return year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)
    }
    function fence_run(value, marker,    count) {
      count = 0
      while (substr(value, count + 1, 1) == marker) count++
      return count
    }
    function is_valid_timestamp(value,    year,month,day,hour,minute,second,max_day,offset_hour,offset_minute) {
      if (value !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\.[0-9]+)?)?(Z|[+-][0-9]{2}:[0-9]{2})$/) return 0
      year = substr(value, 1, 4) + 0
      month = substr(value, 6, 2) + 0
      day = substr(value, 9, 2) + 0
      hour = substr(value, 12, 2) + 0
      minute = substr(value, 15, 2) + 0
      second = substr(value, 17, 1) == ":" ? substr(value, 18, 2) + 0 : 0
      if (month < 1 || month > 12 || hour > 23 || minute > 59 || second > 59) return 0
      max_day = 31
      if (month == 4 || month == 6 || month == 9 || month == 11) max_day = 30
      if (month == 2) max_day = is_leap_year(year) ? 29 : 28
      if (day < 1 || day > max_day) return 0
      if (substr(value, length(value), 1) == "Z") return 1
      offset_hour = substr(value, length(value) - 4, 2) + 0
      offset_minute = substr(value, length(value) - 1, 2) + 0
      return offset_hour <= 23 && offset_minute <= 59
    }
    {
      line = $0
      sub(/\r$/, "", line)
    }
    {
      fence_line = line
      sub(/^ +/, "", fence_line)
    }
    !in_fence && fence_line ~ /^```+/ {
      in_fence = 1
      fence_marker = "`"
      fence_length = fence_run(fence_line, fence_marker)
      next
    }
    !in_fence && fence_line ~ /^~~~/ {
      in_fence = 1
      fence_marker = "~"
      fence_length = fence_run(fence_line, fence_marker)
      next
    }
    in_fence && substr(fence_line, 1, 1) == fence_marker {
      fence_count = fence_run(fence_line, fence_marker)
      if (fence_count >= fence_length && substr(fence_line, fence_count + 1) ~ /^[ \t]*$/) {
        in_fence = 0
        fence_marker = ""
        fence_length = 0
      }
      next
    }
    in_fence { next }
    line == "## Human Final Review" {
      review_count++
      in_review = 1
      next
    }
    in_review && line ~ /^## / { in_review = 0 }
    in_review && line ~ /^- Status: / {
      status_count++
      status = substr(line, length("- Status: ") + 1)
    }
    in_review && line ~ /^- Decision: / {
      decision_count++
      decision = substr(line, length("- Decision: ") + 1)
    }
    in_review && line ~ /^- Reviewer: / {
      reviewer_count++
      reviewer = substr(line, length("- Reviewer: ") + 1)
    }
    in_review && line ~ /^- Reviewed at: / {
      reviewed_at_count++
      reviewed_at = substr(line, length("- Reviewed at: ") + 1)
    }
    in_review && line ~ /^- Follow-up: / {
      follow_up_count++
      follow_up = substr(line, length("- Follow-up: ") + 1)
    }
    END {
      exit !(review_count == 1 && status_count == 1 && status == "APPROVED" && decision_count == 1 && is_non_placeholder(decision) && reviewer_count == 1 && is_non_placeholder(reviewer) && reviewed_at_count == 1 && is_valid_timestamp(reviewed_at) && follow_up_count == 1 && is_non_placeholder(follow_up))
    }
  ' "$file"
}

if ! has_valid_human_review "$APPROVED_EVIDENCE"; then
  printf '[ERROR] Architecture Profile lacks a complete persisted Human Final Review approval.\n' >&2
  exit 2
fi

if ! awk -v task_id="$TASK_ID" -v command="$TEST_CMD" '
  function fence_run(value, marker,    count) {
    count = 0
    while (substr(value, count + 1, 1) == marker) count++
    return count
  }
  {
    line = $0
    sub(/\r$/, "", line)
  }
  {
    fence_line = line
    sub(/^ +/, "", fence_line)
  }
  !in_fence && fence_line ~ /^```+/ {
    in_fence = 1
    fence_marker = "`"
    fence_length = fence_run(fence_line, fence_marker)
    next
  }
  !in_fence && fence_line ~ /^~~~/ {
    in_fence = 1
    fence_marker = "~"
    fence_length = fence_run(fence_line, fence_marker)
    next
  }
  in_fence && substr(fence_line, 1, 1) == fence_marker {
    fence_count = fence_run(fence_line, fence_marker)
    if (fence_count >= fence_length && substr(fence_line, fence_count + 1) ~ /^[ \t]*$/) {
      in_fence = 0
      fence_marker = ""
      fence_length = 0
    }
    next
  }
  in_fence { next }
  line ~ "^### " task_id " —" { task_found = 1; in_task = 1; next }
  in_task && /^### / { in_task = 0 }
  in_task && index(line, command) { command_found = 1 }
  END { exit !(task_found && command_found) }
' "$TASK_FILE"; then
  printf '[ERROR] %s does not bind %s to exact command %s.\n' "$TASK_FILE" "$TASK_ID" "$TEST_CMD" >&2
  exit 2
fi

if ! has_valid_human_review "$TASK_FILE"; then
  printf '[ERROR] Task evidence lacks a complete persisted Human Final Review approval.\n' >&2
  exit 2
fi

read -r -a TEST_ARGS <<< "$TEST_CMD"
if [[ "${#TEST_ARGS[@]}" -eq 0 || -z "${TEST_ARGS[0]}" ]]; then
  printf '[ERROR] --test-cmd did not yield an executable.\n' >&2
  exit 2
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  printf '[ERROR] Run this script from a Git repository.\n' >&2
  exit 2
fi

if [[ "$DRY_RUN" == true ]]; then
  cat <<EOF
SELF-HEAL DRY RUN
Feature: $FEATURE_SLUG
Task: $TASK_ID
Approved evidence: $APPROVED_EVIDENCE
Test command: $TEST_CMD
Attempt budget: $MAX_ATTEMPTS
Scope category: $SCOPE_CATEGORY
Mutation: disabled by design
EOF
  exit 0
fi

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/self-heal-${FEATURE_SLUG}-${TASK_ID}-${TIMESTAMP}.log"
REPORT_FILE="$LOG_DIR/self-heal-${FEATURE_SLUG}-${TASK_ID}-${TIMESTAMP}.md"

run_test() {
  local exit_code=0
  {
    printf '## Test command\n\n```text\n%s\n```\n\n' "$TEST_CMD"
    printf '## Output\n\n```text\n'
    "${TEST_ARGS[@]}"
  } >>"$LOG_FILE" 2>&1 || exit_code=$?
  printf '\n```\nexit_code=%s\n' "$exit_code" >>"$LOG_FILE"
  return "$exit_code"
}

classify_failure() {
  local output
  output="$(cat "$LOG_FILE")"
  if [[ "$SCOPE_CATEGORY" != "implementation-defect" ]]; then
    printf '%s' "$SCOPE_CATEGORY"
  elif grep -Eiq 'SPEC|requirement|ambiguous|acceptance criteria' <<<"$output"; then
    printf 'spec-gap'
  elif grep -Eiq 'CONFIGURATION GAP|binding|not selected|command not found|profile' <<<"$output"; then
    printf 'profile-config-gap'
  else
    printf 'implementation-defect'
  fi
}

if run_test; then
  cat >"$REPORT_FILE" <<EOF
# Self-Heal Action Record

- Status: PASS — no recovery action required
- Feature/task: $FEATURE_SLUG / $TASK_ID
- Approved scope and file boundary: recorded in TASKS.md; this script did not modify files
- Profile binding and exact command: $APPROVED_EVIDENCE — \`$TEST_CMD\`
- State-change category: $SCOPE_CATEGORY
- Human checkpoint: N/A — no mutation occurred
- Actions and result: command passed on first execution
- Residual blocker: none
- Sync-back decision: N/A — no artifact or code changed
- Log: \`$LOG_FILE\`
EOF
  printf '[PASS] Test command passed. Evidence: %s\n' "$REPORT_FILE"
  exit 0
fi

CLASSIFICATION="$(classify_failure)"
cat >"$REPORT_FILE" <<EOF
# Self-Heal Action Record

- Status: BLOCKED — Human review required
- Feature/task: $FEATURE_SLUG / $TASK_ID
- Approved scope and file boundary: recorded in TASKS.md; this script did not modify files
- Profile binding and exact command: $APPROVED_EVIDENCE — \`$TEST_CMD\`
- State-change category: $SCOPE_CATEGORY
- Failure classification: $CLASSIFICATION
- Attempt budget: $MAX_ATTEMPTS; no automated repair attempt was run
- Human checkpoint: required before any material state-change repair
- Actions and result: exact approved command failed; output retained in \`$LOG_FILE\`
- Residual blocker: classify root cause and approve a scoped repair or artifact update
- Sync-back decision: pending repair outcome; run /sdd-trace and /sdd-sync if the repair changes requirement, contract, or shared state

## Recovery boundary

This script does not invoke a mutating Claude session. A \`claude --print\` call is analysis-only and must not be represented as an applied repair. Do not use this path for Spec gap, missing profile binding, schema/business-data mutation, shared/public contract, permission/security/dependency/runtime configuration, or external/irreversible side effect.

## Next step

- \`implementation-defect\`: Human reviews this record, approves a scoped repair, then runs the exact command again.
- \`spec-gap\`: use \`/sdd-update --artifact=spec\` and complete required review before execution.
- \`profile-config-gap\`: update and review \`.sdd/architecture-profile.md\` before execution.
- Other material state change: obtain persisted Human checkpoint before any action.
EOF

printf '[BLOCKED] %s. Evidence: %s\n' "$CLASSIFICATION" "$REPORT_FILE" >&2
exit 1
