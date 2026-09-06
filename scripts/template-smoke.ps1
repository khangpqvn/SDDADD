# Dependency-free static release check for the SDD + ADD template.
# It reads files only. It does not run application commands or use network/DB.
param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Root = "."
)

$Root = (Resolve-Path $Root).Path
$script:Failures = 0

function Pass([string]$Message) { Write-Host "[PASS] $Message" }
function Fail([string]$Message) {
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    $script:Failures++
}
function Require-File([string]$RelativePath) {
    if (Test-Path (Join-Path $Root $RelativePath) -PathType Leaf) { Pass "exists: $RelativePath" }
    else { Fail "missing: $RelativePath" }
}
function Require-Token([string]$RelativePath, [string]$Token) {
    $Path = Join-Path $Root $RelativePath
    if ((Test-Path $Path -PathType Leaf) -and ((Get-Content -Raw -Encoding UTF8 $Path).Contains($Token))) {
        Pass "token: $RelativePath :: $Token"
    } else {
        Fail "missing token: $RelativePath :: $Token"
    }
}
function Require-AbsentToken([string]$RelativePath, [string]$Token) {
    $Path = Join-Path $Root $RelativePath
    if ((Test-Path $Path -PathType Leaf) -and -not (Get-Content -Raw -Encoding UTF8 $Path).Contains($Token)) {
        Pass "absent token: $RelativePath :: $Token"
    } else {
        Fail "unexpected token: $RelativePath :: $Token"
    }
}

$RequiredFiles = @(
    "AGENTS.md", "CLAUDE.md", "CONSTITUTION.md",
    ".claude/skills/_shared/ai-review-protocol.md",
    ".claude/skills/_shared/architecture-profile-protocol.md",
    ".claude/skills/sdd-context/SKILL.md", ".claude/skills/sdd-spec/SKILL.md",
    ".claude/skills/sdd-plan/SKILL.md", ".claude/skills/sdd-tasks/SKILL.md",
    ".claude/skills/sdd-update/SKILL.md", ".claude/skills/add-execute/SKILL.md", ".claude/skills/sdd-dispatch/SKILL.md",
    ".claude/skills/sdd-trace/SKILL.md", ".claude/skills/sdd-sync/SKILL.md",
    ".claude/skills/sdd-review/SKILL.md", ".claude/skills/git-commit/SKILL.md",
    ".claude/skills/git-pr/SKILL.md", ".claude/skills/git-validate/SKILL.md",
    ".sdd/architecture-profile.md", ".sdd/shared_context.md", ".sdd/mcp-config.yaml",
    ".sdd/constraints/safety.md", "docs/sdd-add-quickstart.md", "docs/sdd-add-guide.md",
    "docs/sdd-add-field-guide.md", "docs/sdd-add-scenario-playbook.md",
    "docs/architecture-profile-guide.md", "docs/multi-agent-orchestration-guide.md",
    "scripts/adopt.sh", "scripts/adopt.ps1", "scripts/update.sh", "scripts/update.ps1",
    "scripts/self-heal.sh", "scripts/template-smoke.sh", "scripts/template-smoke.ps1"
)
$RequiredFiles | ForEach-Object { Require-File $_ }

$TokenChecks = @(
    @(".claude/skills/_shared/ai-review-protocol.md", "## AI Agent Recommendation"),
    @(".claude/skills/_shared/ai-review-protocol.md", "## Human Final Review"),
    @(".claude/skills/_shared/ai-review-protocol.md", "## Methodology Profile"),
    @(".claude/skills/_shared/ai-review-protocol.md", "## Intent Packet"),
    @(".claude/skills/_shared/ai-review-protocol.md", "## Action Record"),
    @(".claude/skills/_shared/architecture-profile-protocol.md", "Resolve technology binding theo thứ tự"),
    @(".claude/skills/_shared/architecture-profile-protocol.md", "Methodology Profile"),
    @(".claude/skills/sdd-context/SKILL.md", "Intent Packet"),
    @(".claude/skills/_shared/ai-review-protocol.md", "## Describe-back record"),
    @(".claude/skills/sdd-context/SKILL.md", "Describe-back record"),
    @(".claude/skills/sdd-spec/SKILL.md", "SKIP | SKETCH | DETAILED | FORMAL"),
    @(".claude/skills/sdd-spec/SKILL.md", "Adversarial quality pass"),
    @(".claude/skills/sdd-tasks/SKILL.md", "Estimated effort"),
    @(".claude/skills/sdd-tasks/SKILL.md", "about four hours"),
    @(".claude/skills/add-execute/SKILL.md", "Validation route"),
    @(".claude/skills/add-execute/SKILL.md", "Post-code Human review"),
    @(".claude/skills/sdd-review/SKILL.md", "Post-code review và completion"),
    @(".claude/skills/git-validate/SKILL.md", "### 4. Post-code review"),
    @("docs/sdd-add-quickstart.md", "Bước 8 — Review sau code khi cần"),
    @(".claude/skills/sdd-init/SKILL.md", "--project-ownership=solo|team"),
    @(".claude/skills/sdd-init/SKILL.md", "--agent-execution=direct|orchestrated"),
    @(".claude/skills/sdd-spec/SKILL.md", "## Feature Lock"),
    @(".claude/skills/sdd-plan/SKILL.md", "## Consistency Map"),
    @(".claude/skills/sdd-tasks/SKILL.md", "Scope category"),
    @(".claude/skills/sdd-update/SKILL.md", "## Change Impact Record"),
    @(".claude/skills/add-execute/SKILL.md", "Atomic session"),
    @(".claude/skills/add-execute/SKILL.md", "Human checkpoint"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "Claude Code"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "Agent"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "TaskCreate"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "AUDIT EVIDENCE REFERENCE"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "--resume"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "Dispatch Record"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "RETRY_PENDING"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "Project Ownership"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "Agent Execution"),
    @('.claude/skills/sdd-dispatch/SKILL.md', '`direct` is not a bypass.'),
    @(".claude/skills/sdd-dispatch/SKILL.md", "Runtime identity evidence"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "Runtime enforcement evidence"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "maximum 5"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "policy-only; host evidence is"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "VERIFYING -> COMPLETED | RETRY_PENDING | BLOCKED | ESCALATED"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "ESCALATED -> PLANNED"),
    @(".claude/skills/sdd-resume/SKILL.md", "RETRY_PENDING retry-only"),
    @("docs/multi-agent-orchestration-guide.md", "VERIFYING -> COMPLETED | RETRY_PENDING | BLOCKED | ESCALATED"),
    @("docs/multi-agent-orchestration-guide.md", "ESCALATED -> PLANNED"),
    @("docs/multi-agent-orchestration-guide.md", "[--resume]"),
    @(".sdd/mcp-config.yaml", "claude_code_dispatch"),
    @(".sdd/mcp-config.yaml", "UNVERIFIED"),
    @(".sdd/shared_context.md", "task ID"),
    @(".sdd/shared_context.md", "audit evidence reference"),
    @("docs/multi-agent-orchestration-guide.md", "task_id"),
    @("docs/multi-agent-orchestration-guide.md", "audit_evidence_reference"),
    @('.claude/skills/sdd-trace/SKILL.md', 'contract `DRIFT`'),
    @(".claude/skills/sdd-sync/SKILL.md", "--feature=<feature-slug>"),
    @('.claude/skills/sdd-sync/SKILL.md', 'checkpoint persisted đã `APPROVED`'),
    @(".claude/skills/sdd-review/SKILL.md", ".sdd/architecture-profile.md"),
    @(".sdd/mcp-config.yaml", "global_denied:"), @(".sdd/mcp-config.yaml", "audit:"),
    @(".sdd/mcp-config.yaml", "frozen_contract_version"),
    @(".sdd/shared_context.md", "Frozen shared-contract record"),
    @(".sdd/constraints/safety.md", "AGT-S-06"),
    @("scripts/self-heal.sh", "--approved-evidence"),
    @("scripts/self-heal.sh", "review_count == 1"),
    @("scripts/self-heal.sh", "is_valid_timestamp"),
    @("scripts/self-heal.sh", "in_fence"),
    @("scripts/self-heal.sh", "fence_count >= fence_length"),
    @('scripts/self-heal.sh', 'sub(/\r$/, "", line)'),
    @("scripts/self-heal.sh", "Mutation: disabled by design"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "--team-size=solo|team"),
    @(".claude/skills/sdd-dispatch/SKILL.md", "Emit migration warning"),
    @(".claude/skills/git-commit/SKILL.md", "# Project Ownership: team|solo"),
    @(".claude/skills/git-pr/SKILL.md", "# Project Ownership: team|solo"),
    @(".claude/skills/git-validate/SKILL.md", "# Project Ownership: solo|team"),
    @("scripts/adopt.sh", "docs/sdd-add-scenario-playbook.md"),
    @("scripts/adopt.ps1", "docs\sdd-add-scenario-playbook.md"),
    @("scripts/update.sh", "scripts/template-smoke.ps1"),
    @("scripts/update.ps1", "scripts\template-smoke.ps1"),
    @('scripts/update.sh', '"$src_rel" != "CONSTITUTION.md"'),
    @('scripts/update.ps1', '$SrcRel -ne "CONSTITUTION.md"'),
    @('AGENTS.md', '`git push`, `npm publish` | Forbidden'),
    @('.sdd/constraints/safety.md', 'Agent không được `git push`'),
    @('.claude/skills/git-commit/SKILL.md', 'Agent không `git push`'),
    @('.claude/skills/git-pr/SKILL.md', 'Agent never pushes on behalf of a human.')
)
foreach ($Check in $TokenChecks) { Require-Token $Check[0] $Check[1] }
Require-Token ".claude/skills/sdd-dispatch/SKILL.md" "Project ownership does not change worker eligibility."
Require-Token ".claude/skills/sdd-dispatch/SKILL.md" "Shadow Plan, Action Record, material checkpoint"
Require-Token ".claude/skills/add-execute/SKILL.md" "--dispatch-record=<reference>"
Require-Token '.claude/skills/add-execute/SKILL.md' 'Thiếu, trùng hoặc malformed canonical header là `BLOCKED`'
Require-Token ".claude/skills/add-execute/SKILL.md" "Governance resolution"
Require-Token ".claude/skills/add-execute/SKILL.md" "áp dụng đúng override đã record"
Require-Token ".claude/skills/add-execute/SKILL.md" "--dispatch-grant=<grant-id>"
Require-Token ".claude/skills/add-execute/SKILL.md" "--dispatch-consumer=<consumer-ref>"
Require-Token '.claude/skills/add-execute/SKILL.md' 'mismatched consumer, cross-feature, cross-task, cross-record hoặc replay là `BLOCKED`'
Require-Token "docs/sdd-add-quickstart.md" "--dispatch-grant=<grant-id>"
Require-Token "docs/sdd-add-quickstart.md" "--dispatch-consumer=<consumer-ref>"
Require-Token "docs/sdd-add-field-guide.md" "--dispatch-consumer=<consumer-ref>"
Require-Token ".claude/skills/sdd-dispatch/SKILL.md" "Task execution grants"
Require-Token ".claude/skills/sdd-dispatch/SKILL.md" "consumption state=UNCONSUMED|CONSUMED"
Require-Token ".claude/skills/sdd-dispatch/SKILL.md" "GRANT STATE: DISPATCHED"
Require-Token ".claude/skills/sdd-dispatch/SKILL.md" "DISPATCH GRANT ID: <grant-id>"
Require-Token ".claude/skills/sdd-dispatch/SKILL.md" "CONSUMER: <dispatcher-issued opaque consumer reference"
Require-Token "docs/multi-agent-orchestration-guide.md" "consumer=<dispatcher-issued opaque consumer reference"
Require-Token ".claude/skills/_shared/ai-review-protocol.md" "Task execution eligibility is controlled by the matching task execution grant"
Require-Token ".claude/skills/sdd-resume/SKILL.md" "consumed hoặc non-eligible grant"
Require-Token ".sdd/shared_context.md" "Worker trả consumer và consumption evidence"
Require-Token ".claude/skills/sdd-dispatch/SKILL.md" "host-controlled atomic claim"
Require-Token ".claude/skills/add-execute/SKILL.md" "Markdown grant state không atomic"
Require-Token ".claude/skills/_shared/ai-review-protocol.md" "Markdown grant state is cooperative evidence only"
Require-Token ".claude/skills/sdd-dispatch/SKILL.md" "do not claim host-level replay prevention"
Require-Token '.claude/skills/sdd-dispatch/SKILL.md' '--team-size` cannot be combined'
Require-Token '.claude/skills/sdd-dispatch/SKILL.md' 'alias with either canonical header is `BLOCKED`'
Require-Token ".sdd/shared_context.md" 'có một trong hai canonical header, `--team-size` là `BLOCKED`'
Require-Token '.claude/skills/sdd-dispatch/SKILL.md' 'coexist là `BLOCKED`'
Require-Token ".claude/skills/git-commit/SKILL.md" "không fallback legacy"
Require-Token ".claude/skills/git-pr/SKILL.md" "never fallback legacy"
Require-Token ".claude/skills/git-validate/SKILL.md" "never fallback legacy"
Require-Token ".sdd/constraints/safety.md" "Human collaborator được project ủy quyền"
Require-Token '.claude/skills/git-validate/SKILL.md' '`Agent Execution` does not affect delivery validation.'
Require-AbsentToken ".claude/skills/sdd-dispatch/SKILL.md" "solo-bypass"

function Require-ValidHeader(
    [string]$RelativePath,
    [string]$Header,
    [string]$Values,
    [string]$Label
) {
    $Path = Join-Path $Root $RelativePath
    if (-not (Test-Path $Path -PathType Leaf)) {
        Fail "missing $Label source: $RelativePath"
        return
    }

    $Content = Get-Content -Raw -Encoding UTF8 $Path
    $Headers = [regex]::Matches($Content, "(?m)^# $([regex]::Escape($Header)):.*\r?$")
    $ValidHeaders = [regex]::Matches($Content, "(?m)^# $([regex]::Escape($Header)): ($Values)\r?$")
    if ($Headers.Count -eq 1 -and $ValidHeaders.Count -eq 1) {
        Pass "valid ${Label}: $RelativePath"
    } else {
        Fail ("invalid {0}: {1} (require exactly one # {2}: {3})" -f $Label, $RelativePath, $Header, $Values)
    }
}
Require-ValidHeader ".sdd/shared_context.md" "Project Ownership" "solo|team" "project ownership"
Require-ValidHeader ".sdd/shared_context.md" "Agent Execution" "direct|orchestrated" "agent execution"

Get-ChildItem -Path $Root -Recurse -File -Filter "*.md" | Where-Object {
    $_.FullName -notlike "$Root\.git\*" -and $_.FullName -notlike "$Root\.claude\worktrees\*"
} | ForEach-Object {
    $Markdown = $_.FullName
    $Directory = Split-Path -Parent $Markdown
    $Content = Get-Content -Raw $Markdown
    [regex]::Matches($Content, '\[[^\]]+\]\(([^)]+)\)') | ForEach-Object {
        $Target = $_.Groups[1].Value.Split('#')[0]
        if ([string]::IsNullOrWhiteSpace($Target) -or $Target -match '^(https?://|mailto:|#)') { return }
        if (-not (Test-Path (Join-Path $Directory $Target))) {
            $Relative = $Markdown.Substring($Root.Length).TrimStart('\','/')
            Fail "broken Markdown link: $Relative -> $Target"
        }
    }
}

if ($script:Failures -gt 0) {
    Write-Host "TEMPLATE SMOKE: FAIL ($($script:Failures) finding(s))" -ForegroundColor Red
    exit 1
}
Write-Host "TEMPLATE SMOKE: PASS" -ForegroundColor Green
