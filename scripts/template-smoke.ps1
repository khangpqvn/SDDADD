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

$RequiredFiles = @(
    "AGENTS.md", "CLAUDE.md", "CONSTITUTION.md",
    ".claude/skills/_shared/ai-review-protocol.md",
    ".claude/skills/_shared/architecture-profile-protocol.md",
    ".claude/skills/sdd-context/SKILL.md", ".claude/skills/sdd-spec/SKILL.md",
    ".claude/skills/sdd-plan/SKILL.md", ".claude/skills/sdd-tasks/SKILL.md",
    ".claude/skills/sdd-update/SKILL.md", ".claude/skills/add-execute/SKILL.md",
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
    @(".claude/skills/sdd-init/SKILL.md", "# Collaboration Mode: solo|team"),
    @(".claude/skills/sdd-spec/SKILL.md", "## Feature Lock"),
    @(".claude/skills/sdd-plan/SKILL.md", "## Consistency Map"),
    @(".claude/skills/sdd-tasks/SKILL.md", "Scope category"),
    @(".claude/skills/sdd-update/SKILL.md", "## Change Impact Record"),
    @(".claude/skills/add-execute/SKILL.md", "Atomic session"),
    @(".claude/skills/add-execute/SKILL.md", "Human checkpoint"),
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
    @(".claude/skills/git-commit/SKILL.md", "# Collaboration Mode: team|solo"),
    @(".claude/skills/git-pr/SKILL.md", "# Collaboration Mode: team|solo"),
    @(".claude/skills/git-validate/SKILL.md", "# Collaboration Mode: team|solo"),
    @("scripts/adopt.sh", "docs/sdd-add-scenario-playbook.md"),
    @("scripts/adopt.ps1", "docs\sdd-add-scenario-playbook.md"),
    @("scripts/update.sh", "scripts/template-smoke.ps1"),
    @("scripts/update.ps1", "scripts\template-smoke.ps1"),
    @('scripts/update.sh', '"$src_rel" != "CONSTITUTION.md"'),
    @('scripts/update.ps1', '$SrcRel -ne "CONSTITUTION.md"'),
    @('AGENTS.md', '`git push`, `npm publish` | Forbidden'),
    @('.sdd/constraints/safety.md', 'Agent không được `git push`'),
    @('.claude/skills/git-commit/SKILL.md', 'Agent không `git push`'),
    @('.claude/skills/git-pr/SKILL.md', 'Agent không chạy `git push`')
)
foreach ($Check in $TokenChecks) { Require-Token $Check[0] $Check[1] }

function Require-ValidCollaborationMode([string]$RelativePath) {
    $Path = Join-Path $Root $RelativePath
    if (-not (Test-Path $Path -PathType Leaf)) {
        Fail "missing collaboration mode source: $RelativePath"
        return
    }

    $Headers = [regex]::Matches((Get-Content -Raw -Encoding UTF8 $Path), '(?m)^# Collaboration Mode:.*\r?$')
    $ValidHeaders = [regex]::Matches((Get-Content -Raw -Encoding UTF8 $Path), '(?m)^# Collaboration Mode: (solo|team)\r?$')
    if ($Headers.Count -eq 1 -and $ValidHeaders.Count -eq 1) {
        Pass "valid collaboration mode: $RelativePath"
    } else {
        Fail "invalid collaboration mode: $RelativePath (require exactly one # Collaboration Mode: solo|team)"
    }
}
Require-ValidCollaborationMode ".sdd/shared_context.md"

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
