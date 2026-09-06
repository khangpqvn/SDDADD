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
require_token() {
  local rel="$1"
  local token="$2"
  if [[ -f "$ROOT/$rel" ]] && grep -Fq -- "$token" "$ROOT/$rel"; then
    pass "token: $rel :: $token"
  else
    fail "missing token: $rel :: $token"
  fi
}
require_absent_token() {
  local rel="$1"
  local token="$2"
  if [[ -f "$ROOT/$rel" ]] && ! grep -Fq -- "$token" "$ROOT/$rel"; then
    pass "absent token: $rel :: $token"
  else
    fail "unexpected token: $rel :: $token"
  fi
}

required_files=(
  AGENTS.md CLAUDE.md CONSTITUTION.md
  .claude/skills/_shared/ai-review-protocol.md
  .claude/skills/_shared/architecture-profile-protocol.md
  .claude/skills/sdd-context/SKILL.md
  .claude/skills/sdd-spec/SKILL.md
  .claude/skills/sdd-plan/SKILL.md
  .claude/skills/sdd-tasks/SKILL.md
  .claude/skills/sdd-update/SKILL.md
  .claude/skills/add-execute/SKILL.md
  .claude/skills/sdd-dispatch/SKILL.md
  .claude/skills/sdd-trace/SKILL.md
  .claude/skills/sdd-sync/SKILL.md
  .claude/skills/sdd-review/SKILL.md
  .claude/skills/git-commit/SKILL.md
  .claude/skills/git-pr/SKILL.md
  .claude/skills/git-validate/SKILL.md
  .sdd/architecture-profile.md .sdd/shared_context.md .sdd/mcp-config.yaml
  .sdd/constraints/safety.md
  docs/sdd-add-quickstart.md docs/sdd-add-guide.md docs/sdd-add-field-guide.md
  docs/sdd-add-scenario-playbook.md docs/architecture-profile-guide.md
  docs/multi-agent-orchestration-guide.md
  scripts/adopt.sh scripts/adopt.ps1 scripts/update.sh scripts/update.ps1
  scripts/self-heal.sh scripts/template-smoke.sh scripts/template-smoke.ps1
)

for file in "${required_files[@]}"; do require_file "$file"; done

require_token ".claude/skills/_shared/ai-review-protocol.md" "## AI Agent Recommendation"
require_token ".claude/skills/_shared/ai-review-protocol.md" "## Human Final Review"
require_token ".claude/skills/_shared/ai-review-protocol.md" "## Methodology Profile"
require_token ".claude/skills/_shared/ai-review-protocol.md" "## Intent Packet"
require_token ".claude/skills/_shared/ai-review-protocol.md" "## Action Record"
require_token ".claude/skills/_shared/architecture-profile-protocol.md" "Resolve technology binding theo thứ tự"
require_token ".claude/skills/_shared/architecture-profile-protocol.md" "Methodology Profile"
require_token ".claude/skills/sdd-context/SKILL.md" "Intent Packet"
require_token ".claude/skills/_shared/ai-review-protocol.md" "## Describe-back record"
require_token ".claude/skills/sdd-context/SKILL.md" "Describe-back record"
require_token ".claude/skills/sdd-spec/SKILL.md" "SKIP | SKETCH | DETAILED | FORMAL"
require_token ".claude/skills/sdd-spec/SKILL.md" "Adversarial quality pass"
require_token ".claude/skills/sdd-tasks/SKILL.md" "Estimated effort"
require_token ".claude/skills/sdd-tasks/SKILL.md" "about four hours"
require_token ".claude/skills/add-execute/SKILL.md" "Validation route"
require_token ".claude/skills/add-execute/SKILL.md" "Post-code Human review"
require_token ".claude/skills/sdd-review/SKILL.md" "Post-code review và completion"
require_token ".claude/skills/git-validate/SKILL.md" "### 4. Post-code review"
require_token "docs/sdd-add-quickstart.md" "Bước 8 — Review sau code khi cần"
require_token ".claude/skills/sdd-init/SKILL.md" "--project-ownership=solo|team"
require_token ".claude/skills/sdd-init/SKILL.md" "--agent-execution=direct|orchestrated"
require_token ".claude/skills/sdd-spec/SKILL.md" "## Feature Lock"
require_token ".claude/skills/sdd-plan/SKILL.md" "## Consistency Map"
require_token ".claude/skills/sdd-tasks/SKILL.md" "Scope category"
require_token ".claude/skills/sdd-update/SKILL.md" "## Change Impact Record"
require_token ".claude/skills/add-execute/SKILL.md" "Atomic session"
require_token ".claude/skills/add-execute/SKILL.md" "Human checkpoint"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Claude Code"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Agent"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "TaskCreate"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "AUDIT EVIDENCE REFERENCE"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "--resume"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Dispatch Record"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "RETRY_PENDING"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Project Ownership"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Agent Execution"
require_token ".claude/skills/sdd-dispatch/SKILL.md" '`direct` is not a bypass.'
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Runtime identity evidence"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Runtime enforcement evidence"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "maximum 5"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "policy-only; host evidence is"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "VERIFYING -> COMPLETED | RETRY_PENDING | BLOCKED | ESCALATED"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "ESCALATED -> PLANNED"
require_token ".claude/skills/sdd-resume/SKILL.md" "RETRY_PENDING retry-only"
require_token "docs/multi-agent-orchestration-guide.md" "VERIFYING -> COMPLETED | RETRY_PENDING | BLOCKED | ESCALATED"
require_token "docs/multi-agent-orchestration-guide.md" "ESCALATED -> PLANNED"
require_token "docs/multi-agent-orchestration-guide.md" "[--resume]"
require_token ".sdd/mcp-config.yaml" "claude_code_dispatch"
require_token ".sdd/mcp-config.yaml" "UNVERIFIED"
require_token ".sdd/shared_context.md" "task ID"
require_token ".sdd/shared_context.md" "audit evidence reference"
require_token "docs/multi-agent-orchestration-guide.md" "task_id"
require_token "docs/multi-agent-orchestration-guide.md" "audit_evidence_reference"
require_token ".claude/skills/sdd-trace/SKILL.md" 'contract `DRIFT`'
require_token ".claude/skills/sdd-sync/SKILL.md" "--feature=<feature-slug>"
require_token ".claude/skills/sdd-sync/SKILL.md" 'checkpoint persisted đã `APPROVED`'
require_token ".claude/skills/sdd-review/SKILL.md" ".sdd/architecture-profile.md"
require_token ".sdd/mcp-config.yaml" "global_denied:"
require_token ".sdd/mcp-config.yaml" "audit:"
require_token ".sdd/mcp-config.yaml" "frozen_contract_version"
require_token ".sdd/shared_context.md" "Frozen shared-contract record"
require_valid_header() {
  local rel="$1"
  local header="$2"
  local values="$3"
  local label="$4"
  local path="$ROOT/$rel"
  local header_count
  local valid_count
  header_count="$(grep -Ec $"^# ${header}:.*\\r?$" "$path" || true)"
  valid_count="$(grep -Ec $"^# ${header}: (${values})\\r?$" "$path" || true)"
  if [[ "$header_count" == "1" && "$valid_count" == "1" ]]; then
    pass "valid $label: $rel"
  else
    fail "invalid $label: $rel (require exactly one # $header: $values)"
  fi
}
require_valid_header ".sdd/shared_context.md" "Project Ownership" "solo|team" "project ownership"
require_valid_header ".sdd/shared_context.md" "Agent Execution" "direct|orchestrated" "agent execution"
require_token ".sdd/constraints/safety.md" "AGT-S-06"
require_token "scripts/self-heal.sh" "--approved-evidence"
require_token "scripts/self-heal.sh" "review_count == 1"
require_token "scripts/self-heal.sh" "is_valid_timestamp"
require_token "scripts/self-heal.sh" "in_fence"
require_token "scripts/self-heal.sh" "fence_count >= fence_length"
require_token "scripts/self-heal.sh" 'sub(/\r$/, "", line)'
require_token "scripts/self-heal.sh" "Mutation: disabled by design"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "--team-size=solo|team"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Emit migration warning"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Project ownership does not change worker eligibility."
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Shadow Plan, Action Record, material checkpoint"
require_token ".claude/skills/add-execute/SKILL.md" "--dispatch-record=<reference>"
require_token ".claude/skills/add-execute/SKILL.md" 'Thiếu, trùng hoặc malformed canonical header là `BLOCKED`'
require_token ".claude/skills/add-execute/SKILL.md" "Governance resolution"
require_token ".claude/skills/add-execute/SKILL.md" "áp dụng đúng override đã record"
require_token ".claude/skills/add-execute/SKILL.md" "--dispatch-grant=<grant-id>"
require_token ".claude/skills/add-execute/SKILL.md" "--dispatch-consumer=<consumer-ref>"
require_token ".claude/skills/add-execute/SKILL.md" 'mismatched consumer, cross-feature, cross-task, cross-record hoặc replay là `BLOCKED`'
require_token "docs/sdd-add-quickstart.md" "--dispatch-grant=<grant-id>"
require_token "docs/sdd-add-quickstart.md" "--dispatch-consumer=<consumer-ref>"
require_token "docs/sdd-add-field-guide.md" "--dispatch-consumer=<consumer-ref>"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Task execution grants"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "consumption state=UNCONSUMED|CONSUMED"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "GRANT STATE: DISPATCHED"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "DISPATCH GRANT ID: <grant-id>"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "CONSUMER: <dispatcher-issued opaque consumer reference"
require_token "docs/multi-agent-orchestration-guide.md" "consumer=<dispatcher-issued opaque consumer reference"
require_token ".claude/skills/_shared/ai-review-protocol.md" "Task execution eligibility is controlled by the matching task execution grant"
require_token ".claude/skills/sdd-resume/SKILL.md" "consumed hoặc non-eligible grant"
require_token ".sdd/shared_context.md" "Worker trả consumer và consumption evidence"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "host-controlled atomic claim"
require_token ".claude/skills/add-execute/SKILL.md" "Markdown grant state không atomic"
require_token ".claude/skills/_shared/ai-review-protocol.md" "Markdown grant state is cooperative evidence only"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "do not claim host-level replay prevention"
require_token ".claude/skills/sdd-dispatch/SKILL.md" '--team-size` cannot be combined'
require_token ".claude/skills/sdd-dispatch/SKILL.md" 'alias with either canonical header is `BLOCKED`'
require_token ".sdd/shared_context.md" 'có một trong hai canonical header, `--team-size` là `BLOCKED`'
require_token ".claude/skills/sdd-dispatch/SKILL.md" 'coexist là `BLOCKED`'
require_token ".claude/skills/git-commit/SKILL.md" "không fallback legacy"
require_token ".claude/skills/git-pr/SKILL.md" "never fallback legacy"
require_token ".claude/skills/git-validate/SKILL.md" "never fallback legacy"
require_token ".sdd/constraints/safety.md" "Human collaborator được project ủy quyền"
require_token ".claude/skills/git-validate/SKILL.md" '`Agent Execution` does not affect delivery validation.'
require_absent_token ".claude/skills/sdd-dispatch/SKILL.md" "solo-bypass"
require_token ".claude/skills/git-commit/SKILL.md" "# Project Ownership: team|solo"
require_token ".claude/skills/git-pr/SKILL.md" "# Project Ownership: team|solo"
require_token ".claude/skills/git-validate/SKILL.md" "# Project Ownership: solo|team"
require_token "scripts/adopt.sh" "docs/sdd-add-scenario-playbook.md"
require_token "scripts/adopt.ps1" "docs\\sdd-add-scenario-playbook.md"
require_token "scripts/update.sh" "scripts/template-smoke.ps1"
require_token "scripts/update.ps1" "scripts\\template-smoke.ps1"
require_token "scripts/update.sh" '"$src_rel" != "CONSTITUTION.md"'
require_token "scripts/update.ps1" '$SrcRel -ne "CONSTITUTION.md"'

# Resolve relative Markdown links. External URLs, anchors and images are excluded.
while IFS= read -r -d '' markdown; do
  dir="$(dirname "$markdown")"
  while IFS= read -r link; do
    target="${link#*(}"
    target="${target%%)*}"
    target="${target%%#*}"
    [[ -z "$target" || "$target" =~ ^(https?://|mailto:|#) ]] && continue
    if [[ ! -e "$dir/$target" ]]; then
      fail "broken Markdown link: ${markdown#$ROOT/} -> $target"
    fi
  done < <(grep -Eo '\[[^]]+\]\([^)]*\)' "$markdown" || true)
done < <(find "$ROOT" \
  -path "$ROOT/.git" -prune -o \
  -path "$ROOT/.claude/worktrees" -prune -o \
  -type f -name '*.md' -print0)

# Agent push must stay prohibited in the solo delivery authority surfaces.
require_token "AGENTS.md" '`git push`, `npm publish` | Forbidden'
require_token ".sdd/constraints/safety.md" 'Agent không được `git push`'
require_token ".claude/skills/git-commit/SKILL.md" 'Agent không `git push`'
require_token ".claude/skills/git-pr/SKILL.md" "Agent never pushes on behalf of a human."

if (( FAILURES > 0 )); then
  printf 'TEMPLATE SMOKE: FAIL (%d finding(s))\n' "$FAILURES" >&2
  exit 1
fi
printf 'TEMPLATE SMOKE: PASS\n'
