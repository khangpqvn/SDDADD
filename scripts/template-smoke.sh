#!/usr/bin/env bash
# Dependency-free static release check for the SDD + ADD template.
# It reads files only. It does not run application commands or use network/DB.

set -euo pipefail

ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"
FAILURES=0

pass() { printf '[PASS] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1" >&2; FAILURES=$((FAILURES + 1)); }
require_file() {
  local rel="$1"
  [[ -f "$ROOT/$rel" ]] && pass "exists: $rel" || fail "missing: $rel"
}
require_absent_file() {
  local rel="$1"
  [[ ! -e "$ROOT/$rel" ]] && pass "absent: $rel" || fail "unexpected file: $rel"
}
require_token() {
  local rel="$1" token="$2"
  if [[ -f "$ROOT/$rel" ]] && grep -Fq -- "$token" "$ROOT/$rel"; then
    pass "token: $rel :: $token"
  else
    fail "missing token: $rel :: $token"
  fi
}
require_absent_token() {
  local rel="$1" token="$2"
  if [[ -f "$ROOT/$rel" ]] && ! grep -Fq -- "$token" "$ROOT/$rel"; then
    pass "absent token: $rel :: $token"
  else
    fail "unexpected token: $rel :: $token"
  fi
}
require_valid_header() {
  local rel="$1"
  local header="$2"
  local values="$3"
  local label="$4"
  local path="$ROOT/$rel"
  local header_count valid_count
  header_count="$(grep -Ec "^# ${header}:.*\\r?$" "$path" || true)"
  valid_count="$(grep -Ec "^# ${header}: (${values})\\r?$" "$path" || true)"
  if [[ "$header_count" == "1" && "$valid_count" == "1" ]]; then
    pass "valid $label: $rel"
  else
    fail "invalid $label: $rel (require exactly one # $header: $values)"
  fi
}

required_files=(
  AGENTS.md CLAUDE.md CONSTITUTION.md README.md
  .claude/skills/_shared/ai-review-protocol.md
  .claude/skills/_shared/architecture-profile-protocol.md
  .claude/skills/add-execute/SKILL.md
  .claude/skills/sdd-context/SKILL.md .claude/skills/sdd-spec/SKILL.md
  .claude/skills/sdd-plan/SKILL.md .claude/skills/sdd-tasks/SKILL.md
  .claude/skills/sdd-resume/SKILL.md .claude/skills/sdd-handoff/SKILL.md
  .claude/skills/sdd-review/SKILL.md .claude/skills/sdd-sync/SKILL.md
  .claude/skills/git-commit/SKILL.md .claude/skills/git-pr/SKILL.md
  .claude/skills/git-validate/SKILL.md
  .sdd/architecture-profile.md .sdd/shared_context.md .sdd/mcp-config.yaml
  .sdd/constraints/safety.md .sdd/template-version.md
  docs/sdd-add-quickstart.md docs/sdd-add-guide.md docs/sdd-add-field-guide.md
  docs/sdd-add-scenario-playbook.md docs/architecture-profile-guide.md
  docs/multi-agent-orchestration-guide.md
  scripts/adopt.sh scripts/adopt.ps1 scripts/update.sh scripts/update.ps1
  scripts/self-heal.sh scripts/template-smoke.sh scripts/template-smoke.ps1
)
for file in "${required_files[@]}"; do require_file "$file"; done
require_absent_file ".claude/skills/sdd-dispatch/SKILL.md"

require_token ".claude/skills/_shared/ai-review-protocol.md" "## Execution Record"
require_token ".claude/skills/_shared/ai-review-protocol.md" 'Only `/add-execute` may allocate, revoke, retire or renew a grant.'
require_token ".claude/skills/_shared/ai-review-protocol.md" "Markdown grant state is cooperative evidence only"
require_token ".claude/skills/_shared/ai-review-protocol.md" "At five consecutive failures"
require_token ".claude/skills/add-execute/SKILL.md" "--feature=<feature-slug> --task=<T00X>"
require_token ".claude/skills/add-execute/SKILL.md" "--feature=<feature-slug> --all"
require_token ".claude/skills/add-execute/SKILL.md" "--retry"
require_token ".claude/skills/add-execute/SKILL.md" "--resume"
require_token ".claude/skills/add-execute/SKILL.md" 'Reject `--agent-execution`'
require_token ".claude/skills/add-execute/SKILL.md" 'Runtime worker unavailable là `BLOCKED`; không fallback sang `direct`.'
require_token ".claude/skills/add-execute/SKILL.md" "Execution Record"
require_token ".claude/skills/add-execute/SKILL.md" 'persist matching grant thành `RUNNING`/`CONSUMED`'
require_token ".claude/skills/add-execute/SKILL.md" "cấp worker packet immutable"
require_token ".claude/skills/add-execute/SKILL.md" "Sau 5 consecutive implementation failures"
require_absent_token ".claude/skills/add-execute/SKILL.md" "--dispatch-record=<reference>"
require_absent_token ".claude/skills/add-execute/SKILL.md" "--dispatch-grant=<grant-id>"
require_absent_token ".claude/skills/add-execute/SKILL.md" "--dispatch-consumer=<consumer-ref>"
require_token ".claude/skills/sdd-tasks/SKILL.md" 'Only `/add-execute` may issue'
require_token ".claude/skills/sdd-resume/SKILL.md" "--task=<task-id> --retry"
require_token ".claude/skills/sdd-handoff/SKILL.md" "Action/Execution Record"
require_token ".sdd/shared_context.md" '`/add-execute` điều phối worker'
require_token ".sdd/shared_context.md" 'unavailable là `BLOCKED`, không fallback sang direct'
require_token ".sdd/mcp-config.yaml" "execution_packet:"
require_token ".sdd/mcp-config.yaml" "claude_code_execution:"
require_token ".sdd/constraints/safety.md" "Execution retry"
require_token "AGENTS.md" "# Version: 2.0.0"
require_token "AGENTS.md" 'Retire `/sdd-dispatch`'
require_token ".sdd/template-version.md" "template-version: 2.0.0"
require_token "docs/sdd-add-quickstart.md" "/add-execute --feature=feat-user-register --all"
require_token "docs/multi-agent-orchestration-guide.md" 'Runtime worker unavailable với `orchestrated` là `BLOCKED`'
require_absent_token "docs/sdd-add-quickstart.md" "/sdd-dispatch --"
require_absent_token "docs/sdd-add-field-guide.md" "/sdd-dispatch --"
require_absent_token "docs/multi-agent-orchestration-guide.md" "/sdd-dispatch --"
require_token "scripts/adopt.sh" "retire_legacy_dispatch_skill"
require_token "scripts/adopt.ps1" "Retire-LegacyDispatchSkill"
require_token "scripts/update.sh" "retire_legacy_dispatch_skill"
require_token "scripts/update.ps1" "Retire-LegacyDispatchSkill"
require_token "AGENTS.md" '`git push`, `npm publish` | Forbidden'
require_token ".sdd/constraints/safety.md" 'Agent không được `git push`'
require_token ".claude/skills/git-commit/SKILL.md" 'Agent không `git push`'
require_token ".claude/skills/git-pr/SKILL.md" "Agent never pushes on behalf of a human."
require_valid_header ".sdd/shared_context.md" "Project Ownership" "solo|team" "project ownership"
require_valid_header ".sdd/shared_context.md" "Agent Execution" "direct|orchestrated" "agent execution"

# Every remaining local skill keeps one terminal Completion output section.
skill_count=0
while IFS= read -r -d '' skill; do
  rel="${skill#$ROOT/}"
  count="$(grep -Fc "## Completion output" "$skill" || true)"
  terminal="$(grep -n "## Completion output" "$skill" | tail -n 1 | cut -d: -f1)"
  total="$(wc -l < "$skill")"
  if [[ "$count" == "1" && -n "$terminal" && "$terminal" -lt "$total" ]]; then
    pass "terminal completion output: $rel"
  else
    fail "invalid completion output: $rel"
  fi
  skill_count=$((skill_count + 1))
done < <(find "$ROOT/.claude/skills" -path "$ROOT/.claude/skills/_shared" -prune -o -name SKILL.md -print0)
[[ "$skill_count" == "26" ]] && pass "skill inventory: 26" || fail "skill inventory: expected 26, found $skill_count"

# Active Markdown must not present retired dispatch as an executable command.
while IFS= read -r -d '' markdown; do
  if grep -Fq "/sdd-dispatch --" "$markdown"; then
    fail "retired public route: ${markdown#$ROOT/}"
  fi
done < <(find "$ROOT" -path "$ROOT/.git" -prune -o -path "$ROOT/.claude/worktrees" -prune -o -type f -name '*.md' -print0)

# Resolve relative Markdown links. External URLs, anchors and images are excluded.
while IFS= read -r -d '' markdown; do
  dir="$(dirname "$markdown")"
  while IFS= read -r link; do
    target="${link#*(}"; target="${target%%)*}"; target="${target%%#*}"
    [[ -z "$target" || "$target" =~ ^(https?://|mailto:|#) ]] && continue
    [[ -e "$dir/$target" ]] || fail "broken Markdown link: ${markdown#$ROOT/} -> $target"
  done < <(grep -Eo '\[[^]]+\]\([^)]*\)' "$markdown" || true)
done < <(find "$ROOT" -path "$ROOT/.git" -prune -o -path "$ROOT/.claude/worktrees" -prune -o -type f -name '*.md' -print0)

if (( FAILURES > 0 )); then
  printf 'TEMPLATE SMOKE: FAIL (%d finding(s))\n' "$FAILURES" >&2
  exit 1
fi
printf 'TEMPLATE SMOKE: PASS\n'
