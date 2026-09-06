---
name: sdd-dispatch
description: Điều phối Agent worker theo ownership, checkpoint, evidence và bounded retry
user-invocable: true
---

# Safe Claude Code Agent Dispatch (`/sdd-dispatch`)

**Output language:** Mirror the invoking prompt. Canonical tokens, paths and commands remain language-invariant.

Dùng skill này để thực thi task đã approved theo hai trục độc lập: `Project Ownership` (Human accountability) và `Agent Execution` (direct hoặc orchestrated). `/add-execute` vẫn là quy trình atomic. Không tạo runtime service, không tự cấp quyền, không commit hoặc `git push`.

## Parameters

- `--feature=<feature-slug>`: Required feature identifier.
- `--batch=<batch-id>`: Optional batch identifier; default is selected task set.
- `--task=<T001,T002>`: Optional ordered task IDs; omit only to select next eligible batch.
- `--project-ownership=solo|team`: Optional Human governance override.
- `--agent-execution=direct|orchestrated`: Optional execution override.
- `--team-size=solo|team`: Deprecated composite alias for one transition release. `solo` maps to `--project-ownership=solo --agent-execution=direct`; `team` maps to `--project-ownership=team --agent-execution=orchestrated`. Emit migration warning.
- `--retry`: Resume only an eligible `RETRY_PENDING` task.
- `--resume`: Recover an interrupted `RUNNING`, resolved `BLOCKED`, or Human-dispositioned `ESCALATED` task; never a retry.

## Resolve the two axes

1. Read `.sdd/shared_context.md`. Use canonical settings only when exactly one valid `# Project Ownership: solo|team` header and exactly one valid `# Agent Execution: direct|orchestrated` header exist; canonical flags override only their matching axis.
2. Chỉ khi cả hai canonical header vắng mặt, dùng đúng một nguồn legacy hợp lệ: đúng một `# Collaboration Mode: solo|team` hoặc đúng một `--team-size=solo|team`. Header legacy thiếu, trùng hoặc malformed; alias lặp, malformed; hoặc header và alias coexist là `BLOCKED`. Source hợp lệ map theo documented composite pair, phải báo migration warning và không tự rewrite persisted governance.
3. Missing, duplicate or malformed canonical headers are `BLOCKED`; never fall back to legacy. `--team-size` cannot be combined with `--project-ownership` or `--agent-execution`; the conflict is `BLOCKED`. A `--team-size` alias with either canonical header is `BLOCKED`, because aliases resolve only when both canonical headers are absent. A `canonical` Dispatch Record must not contain a legacy alias. A legacy header coexisting with a valid canonical pair is ignored for resolution and recorded for migration cleanup.
4. `solo` means one Human project owner; `team` means multiple Human collaborators. `direct` means the current Agent executes; `orchestrated` means this dispatcher may launch observed Claude Code `Agent` workers. Do not infer either axis from the other.

## Preconditions

Read [AI Review Protocol](../_shared/ai-review-protocol.md), [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md), `AGENTS.md`, `CONSTITUTION.md`, constraints, `.sdd/mcp-config.yaml`, `.sdd/shared_context.md`, and the feature `CONTEXT.md`, `SPEC.md`, `PLAN.md`, `TASKS.md`, reviews and handoff state.

`TASKS.md` must already have Human Final Review `APPROVED`. For every selected task, require a valid marker/dependency chain, approved task intent/file boundary/profile binding/exact command/checkpoint, matching frozen contract owner/version, no parallel boundary overlap and no unauthorized shared-contract mutation. Markdown state alone cannot serialize concurrent sessions; serialize dispatcher-owned routes and persist grant consumption before action. When an observed host provides an atomic one-time or lease claim bound to feature/task/grant/route/consumer, record it as `VERIFIED`; otherwise record runtime enforcement as `UNVERIFIED` and do not claim host-level replay prevention. Missing evidence, drift, overlap, unapproved command, scope expansion, package/config change, policy violation or new material decision is `BLOCKED`.

## Batch classification and approval

- `single-owned`: one independent task without shared-contract impact.
- `parallel-owned`: two or more independent tasks with exclusive non-overlapping boundaries and no shared-contract mutation.
- `sequential-handoff`: dependency, shared file, producer/consumer ordering, retry or integration dependency.
- `blocked`: failed precondition.

A material, cross-contract, changed-boundary, changed-command or changed-checkpoint batch needs durable batch-specific Human Final Review before mutation at `.sdd/reviews/dispatch-<feature>-<batch>.md`.

## Dispatch Record

Append under `## Current Handoff State` in feature `TASKS.md`:

```markdown
## Dispatch Record — D-<feature>-<batch>-A<attempt>
- Dispatcher: <Claude Code /sdd-dispatch or current Agent>
- Project ownership: solo | team
- Agent execution: direct | orchestrated
- Governance resolution: <canonical | legacy-header | legacy-alias>; invocation axis overrides: <none | project-ownership=<value> | agent-execution=<value> | both>
- Feature: <feature-slug>
- Batch/tasks/state: <batch, ordered task IDs; PLANNED | AWAITING_APPROVAL | READY | DISPATCHED | RUNNING | VERIFYING | RETRY_PENDING | COMPLETED | BLOCKED | ESCALATED>
- Task execution grants: <one append-only entry per selected task: task ID; grant ID; grant attempt; route=direct|orchestrated; task grant state=DISPATCHED|RUNNING|RETIRED|REVOKED; consumption state=UNCONSUMED|CONSUMED; dispatcher-issued opaque consumer reference; consumption evidence; terminal/retry evidence>
- Host execution-claim evidence: <host-controlled atomic claim reference or UNVERIFIED; matching feature/task/grant/route/consumer when available>
- Dependency and ownership check: <pass/fail evidence>
- Frozen contracts: <ID/version/owner or N/A>
- Approved scope and file boundaries: <task-owned paths>
- Profile bindings and exact commands: <approved evidence>
- State-change category: <none or categories>
- Human checkpoint: <review reference or N/A>
- Runtime identity evidence: VERIFIED | UNVERIFIED; <observed evidence>
- Runtime enforcement evidence: VERIFIED | UNVERIFIED; <observed evidence or absence>
- Host task-tracking evidence: AVAILABLE | UNAVAILABLE | NOT_USED; <optional Task evidence>
- Worker references: <Agent references, direct/no worker, or unavailable>
- Attempt and retry count: <attempt; consecutive failures; maximum 5>
- Worker results: <paths, Action Record, exact command/result>
- Integration validation: <boundary/contract/verification result>
- Residual blocker: <none or blocker>
- Sync-back decision: </sdd-trace, /sdd-sync, or N/A>
```

State transitions remain:

```text
PLANNED -> READY | AWAITING_APPROVAL | BLOCKED
AWAITING_APPROVAL -> READY | BLOCKED
READY -> DISPATCHED | BLOCKED
DISPATCHED -> RUNNING | BLOCKED
RUNNING -> VERIFYING | RETRY_PENDING | BLOCKED | ESCALATED
RETRY_PENDING -> DISPATCHED | BLOCKED
VERIFYING -> COMPLETED | RETRY_PENDING | BLOCKED | ESCALATED
BLOCKED -> PLANNED
ESCALATED -> PLANNED
```

Use `[ ]` before dispatch, `[/]` during execution/retry, and `[x]` only after required verification and sync-back. Allocate exactly one route-specific task execution grant per selected task only after preflight passes. A grant identifies its designated consumer through a dispatcher-issued opaque consumer reference: delivered as `--dispatch-consumer` for `direct`, or in the immutable worker packet for `orchestrated`. A grant is procedurally executable only when its task ID, feature, immutable inputs, route and designated consumer match, with `task grant state=DISPATCHED` and `consumption state=UNCONSUMED`; a matching observed host-controlled atomic claim adds host enforcement when available. The dispatcher alone may allocate, revoke, retire or renew grants. Retry retires the consumed grant and allocates a fresh grant only after immutable retry eligibility passes; `/add-execute` never resets consumption or grants a retry.

## Execution routes

### Direct

With `Agent Execution: direct`, complete the preflight and Dispatch Record, allocate one matching `DISPATCHED`/`UNCONSUMED` direct task execution grant with a dispatcher-issued opaque `consumer` reference, record observed host-controlled claim evidence when available, launch no worker, then invoke `/add-execute --feature=<feature> --task=<task> --dispatch-record=<reference> --dispatch-grant=<grant-id> --dispatch-consumer=<consumer-ref>`. `/add-execute` matches the preallocated consumer reference and any recorded claim, then consumes that grant before action. Shadow Plan, Action Record, material checkpoint, approved file boundary, exact command, validation and integration checks remain mandatory. `direct` is not a bypass.

### Orchestrated

With `Agent Execution: orchestrated`, use the current Claude Code `Agent` tool only after observing availability. `TaskCreate`, `TaskGet`, `TaskList` and `TaskUpdate` may mirror state when available; absence is `UNAVAILABLE`, not a bypass. Each worker prompt must contain an immutable packet:

```text
DISPATCH ID: <id>
FEATURE: <feature-slug>
ROLE: <approved role>
TASK ID: <T00X>
DISPATCH GRANT ID: <grant-id>
GRANT ATTEMPT: <n>
GRANT STATE: DISPATCHED
CONSUMPTION STATE: UNCONSUMED
CONSUMER: <dispatcher-issued opaque consumer reference; must match grant and any recorded host claim>
TASK: <ID, title, Intent/DoD and REQ references>
OWNED FILE BOUNDARY: <exact paths only>
FROZEN CONTRACT: <ID/version/owner or N/A>
PROFILE EVIDENCE: <approved binding/version>
ALLOWED COMMANDS: <exact approved commands only>
STATE-CHANGE CATEGORY: <none/categories>
CHECKPOINT: <review reference or N/A>
AUDIT EVIDENCE REFERENCE: <Dispatch Record/review/action evidence>
HOST EXECUTION-CLAIM EVIDENCE: <host-controlled claim reference; matching feature/task/grant/route/consumer; CLAIMED; lease/one-time evidence | UNVERIFIED>
POLICY STATUS: policy-only; host evidence is <VERIFIED|UNVERIFIED>
PROHIBITIONS: no out-of-boundary edits, package/config/contract changes, self-approval, commit or push.
STOP CONDITIONS: drift, scope conflict, missing command/checkpoint, policy/security issue, retry ineligibility.
RETURN: Action Record-compatible result, changed paths, command/result, requirement coverage, residual blocker and sync-back decision.
```

Worker verifies packet `DISPATCH ID`, `FEATURE`, `TASK ID`, grant ID/attempt/state/consumption, designated `CONSUMER`, any recorded host execution-claim evidence, frozen inputs and task boundary against the referenced Dispatch Record before `/add-execute`, then `/add-execute` verifies the consumer and consumes the matching grant before Shadow Plan or task action; stale or mismatched consumer or recorded claim is `BLOCKED`, while unavailable host claim remains `UNVERIFIED`. Parallel workers are only allowed for `parallel-owned`; shared work, retries and integration validation are sequential. Project ownership does not change worker eligibility.

## Retry, completion and sync-back

Retry only an implementation defect inside unchanged task boundary, frozen contract, binding, exact command and checkpoint. Never retry a Spec/profile/command/checkpoint/contract/ownership/security/policy/dependency/runtime gap. For an eligible retry, retire the consumed task grant and allocate a new grant ID/attempt; never reactivate consumed grant. After five consecutive failures, set `ESCALATED`, retain `[/]`, create the dispatch review report and require Human disposition. Revalidate before `--resume`; never reuse an old worker reference without observing it in the current host.

The contract owner validates returned boundaries, Action Record, exact command/result, frozen-contract compatibility and required `/sdd-trace` or `/sdd-sync` decision. Agent never approves a dispatch, task or contract.
