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
function Require-AbsentFile([string]$RelativePath) {
    if (-not (Test-Path (Join-Path $Root $RelativePath))) { Pass "absent: $RelativePath" }
    else { Fail "unexpected file: $RelativePath" }
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
function Require-Regex([string]$RelativePath, [string]$Pattern) {
    $Path = Join-Path $Root $RelativePath
    if ((Test-Path $Path -PathType Leaf) -and [regex]::IsMatch((Get-Content -Raw -Encoding UTF8 $Path), $Pattern, [Text.RegularExpressions.RegexOptions]::Multiline)) {
        Pass "regex: $RelativePath :: $Pattern"
    } else {
        Fail "missing regex: $RelativePath :: $Pattern"
    }
}
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

$RequiredFiles = @(
    "AGENTS.md", "CLAUDE.md", "CONSTITUTION.md", "README.md",
    ".claude/skills/_shared/ai-review-protocol.md",
    ".claude/skills/_shared/architecture-profile-protocol.md",
    ".claude/skills/add-execute/SKILL.md",
    ".claude/skills/sdd-context/SKILL.md", ".claude/skills/sdd-spec/SKILL.md",
    ".claude/skills/sdd-plan/SKILL.md", ".claude/skills/sdd-tasks/SKILL.md",
    ".claude/skills/sdd-resume/SKILL.md", ".claude/skills/sdd-handoff/SKILL.md",
    ".claude/skills/sdd-review/SKILL.md", ".claude/skills/sdd-sync/SKILL.md",
    ".claude/skills/git-commit/SKILL.md", ".claude/skills/git-pr/SKILL.md",
    ".claude/skills/git-validate/SKILL.md",
    ".sdd/architecture-profile.md", ".sdd/shared_context.md", ".sdd/mcp-config.yaml",
    ".sdd/constraints/safety.md", ".sdd/template-version.md",
    "docs/sdd-add-quickstart.md", "docs/sdd-add-guide.md", "docs/sdd-add-field-guide.md",
    "docs/sdd-add-scenario-playbook.md", "docs/architecture-profile-guide.md",
    "docs/multi-agent-orchestration-guide.md",
    "scripts/adopt.sh", "scripts/adopt.ps1", "scripts/update.sh", "scripts/update.ps1",
    "scripts/self-heal.sh", "scripts/template-smoke.sh", "scripts/template-smoke.ps1"
)
$RequiredFiles | ForEach-Object { Require-File $_ }
Require-AbsentFile ".claude/skills/sdd-dispatch/SKILL.md"

$TokenChecks = @(
    @(".claude/skills/_shared/ai-review-protocol.md", "## Execution Record"),
    @(".claude/skills/_shared/ai-review-protocol.md", 'Only `/add-execute` may allocate, revoke, retire or renew a grant.'),
    @(".claude/skills/_shared/ai-review-protocol.md", "Markdown grant state is cooperative evidence only"),
    @(".claude/skills/_shared/ai-review-protocol.md", "At five consecutive failures"),
    @(".claude/skills/add-execute/SKILL.md", "--feature=<feature-slug> --task=<T00X>"),
    @(".claude/skills/add-execute/SKILL.md", "--feature=<feature-slug> --all"),
    @(".claude/skills/add-execute/SKILL.md", "--retry"),
    @(".claude/skills/add-execute/SKILL.md", "--resume"),
    @(".claude/skills/add-execute/SKILL.md", 'Reject `--agent-execution`'),
    @(".claude/skills/add-execute/SKILL.md", "Execution Record"),
    @(".claude/skills/add-execute/SKILL.md", "worker packet immutable"),
    @(".claude/skills/add-execute/SKILL.md", "Sau 5 consecutive implementation failures"),
    @(".claude/skills/sdd-tasks/SKILL.md", 'Only `/add-execute` may issue'),
    @(".claude/skills/sdd-resume/SKILL.md", "--task=<task-id> --retry"),
    @(".claude/skills/sdd-handoff/SKILL.md", "Action/Execution Record"),
    @(".sdd/shared_context.md", "Agent Execution: orchestrated"),
    @(".sdd/mcp-config.yaml", "execution_packet:"),
    @(".sdd/mcp-config.yaml", "claude_code_execution:"),
    @(".sdd/constraints/safety.md", "Execution retry"),
    @("AGENTS.md", "# Version: 2.0.0"),
    @("AGENTS.md", 'Retire `/sdd-dispatch`'),
    @(".sdd/template-version.md", "template-version: 2.0.0"),
    @("docs/sdd-add-quickstart.md", "/add-execute --feature=feat-user-register --all"),
    @("scripts/adopt.sh", "retire_legacy_dispatch_skill"),
    @("scripts/adopt.ps1", "Retire-LegacyDispatchSkill"),
    @("scripts/update.sh", "retire_legacy_dispatch_skill"),
    @("scripts/update.ps1", "Retire-LegacyDispatchSkill"),
    @("AGENTS.md", '`git push`, `npm publish` | Forbidden'),
    @(".sdd/constraints/safety.md", "AGT-S-02"),
    @(".claude/skills/git-commit/SKILL.md", '`git push`'),
    @(".claude/skills/git-pr/SKILL.md", "Agent never pushes on behalf of a human.")
)
foreach ($Check in $TokenChecks) { Require-Token $Check[0] $Check[1] }
Require-Regex ".claude/skills/add-execute/SKILL.md" 'Runtime worker unavailable[^\r\n]*`BLOCKED`;[^\r\n]*fallback[^\r\n]*`direct`'
Require-Regex ".claude/skills/add-execute/SKILL.md" 'persist matching grant[^\r\n]*`RUNNING`/`CONSUMED`'
Require-Regex ".sdd/shared_context.md" 'unavailable[^\r\n]*`BLOCKED`,[^\r\n]*fallback sang direct'
Require-Regex "docs/multi-agent-orchestration-guide.md" 'Runtime worker unavailable[^\r\n]*`orchestrated`[^\r\n]*`BLOCKED`'
Require-AbsentToken ".claude/skills/add-execute/SKILL.md" "--dispatch-record=<reference>"
Require-AbsentToken ".claude/skills/add-execute/SKILL.md" "--dispatch-grant=<grant-id>"
Require-AbsentToken ".claude/skills/add-execute/SKILL.md" "--dispatch-consumer=<consumer-ref>"
Require-AbsentToken "docs/sdd-add-quickstart.md" "/sdd-dispatch --"
Require-AbsentToken "docs/sdd-add-field-guide.md" "/sdd-dispatch --"
Require-AbsentToken "docs/multi-agent-orchestration-guide.md" "/sdd-dispatch --"
Require-ValidHeader ".sdd/shared_context.md" "Project Ownership" "solo|team" "project ownership"
Require-ValidHeader ".sdd/shared_context.md" "Agent Execution" "direct|orchestrated" "agent execution"

$Skills = @(Get-ChildItem -Path (Join-Path $Root ".claude\skills") -Recurse -File -Filter "SKILL.md" | Where-Object {
    $_.FullName -notlike "*\.claude\skills\_shared\*"
})
foreach ($Skill in $Skills) {
    $Content = Get-Content -Raw -Encoding UTF8 $Skill.FullName
    $Count = [regex]::Matches($Content, '(?m)^## Completion output\r?$').Count
    $LastHeader = [regex]::Match($Content, '(?ms)^## Completion output\r?$.*\z')
    if ($Count -eq 1 -and $LastHeader.Success -and $LastHeader.Value.Trim().Length -gt '## Completion output'.Length) {
        $Relative = $Skill.FullName.Substring($Root.Length).TrimStart('\','/')
        Pass "terminal completion output: $Relative"
    } else {
        $Relative = $Skill.FullName.Substring($Root.Length).TrimStart('\','/')
        Fail "invalid completion output: $Relative"
    }
}
if ($Skills.Count -eq 26) { Pass "skill inventory: 26" } else { Fail "skill inventory: expected 26, found $($Skills.Count)" }

Get-ChildItem -Path $Root -Recurse -File -Filter "*.md" | Where-Object {
    $_.FullName -notlike "$Root\.git\*" -and $_.FullName -notlike "$Root\.claude\worktrees\*"
} | ForEach-Object {
    $Content = Get-Content -Raw -Encoding UTF8 $_.FullName
    if ($Content.Contains("/sdd-dispatch --")) {
        $Relative = $_.FullName.Substring($Root.Length).TrimStart('\','/')
        Fail "retired public route: $Relative"
    }
}

Get-ChildItem -Path $Root -Recurse -File -Filter "*.md" | Where-Object {
    $_.FullName -notlike "$Root\.git\*" -and $_.FullName -notlike "$Root\.claude\worktrees\*"
} | ForEach-Object {
    $Markdown = $_.FullName
    $Directory = Split-Path -Parent $Markdown
    $Content = Get-Content -Raw -Encoding UTF8 $Markdown
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
