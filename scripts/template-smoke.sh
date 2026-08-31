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
require_token ".claude/skills/sdd-init/SKILL.md" "# Collaboration Mode: solo|team"
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
require_token ".claude/skills/sdd-dispatch/SKILL.md" "solo-bypass"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Runtime identity evidence"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "Runtime enforcement evidence"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "maximum 5"
require_token ".claude/skills/sdd-dispatch/SKILL.md" "does not prove host enforcement"
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
require_valid_collaboration_mode() {
  local rel="$1"
  local path="$ROOT/$rel"
  local header_count
  local valid_count
  header_count="$(grep -Ec $'^# Collaboration Mode:.*\\r?$' "$path" || true)"
  valid_count="$(grep -Ec $'^# Collaboration Mode: (solo|team)\\r?$' "$path" || true)"
  if [[ "$header_count" == "1" && "$valid_count" == "1" ]]; then
    pass "valid collaboration mode: $rel"
  else
    fail "invalid collaboration mode: $rel (require exactly one # Collaboration Mode: solo|team)"
  fi
}
require_valid_collaboration_mode ".sdd/shared_context.md"
require_token ".sdd/constraints/safety.md" "AGT-S-06"
require_token "scripts/self-heal.sh" "--approved-evidence"
require_token "scripts/self-heal.sh" "review_count == 1"
require_token "scripts/self-heal.sh" "is_valid_timestamp"
require_token "scripts/self-heal.sh" "in_fence"
require_token "scripts/self-heal.sh" "fence_count >= fence_length"
require_token "scripts/self-heal.sh" "sub(/\\r$/, \"\", line)"
require_token "scripts/self-heal.sh" "Mutation: disabled by design"
require_token ".claude/skills/git-commit/SKILL.md" "# Collaboration Mode: team|solo"
require_token ".claude/skills/git-pr/SKILL.md" "# Collaboration Mode: team|solo"
require_token ".claude/skills/git-validate/SKILL.md" "# Collaboration Mode: team|solo"
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
require_token ".claude/skills/git-pr/SKILL.md" 'Agent không chạy `git push`'

if (( FAILURES > 0 )); then
  printf 'TEMPLATE SMOKE: FAIL (%d finding(s))\n' "$FAILURES" >&2
  exit 1
fi
printf 'TEMPLATE SMOKE: PASS\n'
