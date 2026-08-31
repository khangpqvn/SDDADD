---
name: sdd-dispatch
description: Điều phối task team theo Claude Code Agent với ownership, checkpoint, evidence và bounded retry
user-invocable: true
---

# Safe Claude Code Multi-Agent Dispatch (`/sdd-dispatch`)

**Output language:** Mirror the invoking prompt. Canonical tokens, paths and commands remain language-invariant.

Dùng skill này để điều phối team-mode task đã approved. `/add-execute` vẫn là quy trình atomic của worker. Dispatcher dùng Claude Code `Agent` tool khi runtime hiện diện; không tạo runtime service, không tự cấp quyền, không commit hoặc `git push`.

## Parameters

- `--feature=<feature-slug>`: Required feature identifier.
- `--batch=<batch-id>`: Optional batch identifier. Default is the selected task set.
- `--task=<T001,T002>`: Optional ordered task IDs. Omit only to select the next eligible batch.
- `--team-size=solo|team`: Optional invocation override. Default comes from `.sdd/shared_context.md`.
- `--retry`: Resume only an eligible `RETRY_PENDING` task.
- `--resume`: Lead recovery for an interrupted `RUNNING`, resolved `BLOCKED`, or Human-dispositioned `ESCALATED` task; it is not a retry.

## Preconditions

Read [AI Review Protocol](../_shared/ai-review-protocol.md), [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md), `AGENTS.md`, `CONSTITUTION.md`, constraints, `.sdd/mcp-config.yaml`, `.sdd/shared_context.md`, and the feature `CONTEXT.md`, `SPEC.md`, `PLAN.md`, `TASKS.md`, reviews and handoff state.

`TASKS.md` must already have Human Final Review `APPROVED`. For every selected task, require:

1. task marker is `[ ]`, or `[/]` only with `--retry` for an active `RETRY_PENDING` record or `--resume` for interrupted `RUNNING`, resolved `BLOCKED`, or Human-dispositioned `ESCALATED` record;
2. dependencies are `[x]`;
3. Intent/DoD, layer/file boundary, owner/dependencies, profile binding/exact command, scope category, checkpoint, contract/sync-back and high-risk route exist;
4. relevant profile binding and exact verification command are approved or explicitly `N/A` with valid reason;
5. contract version and owner match the frozen record;
6. boundaries do not overlap inside a parallel batch;
7. worker has no shared artifact or contract mutation unless it is the Lead/owner and a sequential handoff is selected.

Any missing evidence, contract drift, overlap, unapproved command, scope expansion, package/configuration change, policy violation or new material decision is `BLOCKED`. Do not infer a command, path, role or enforcement capability.

## Batch classification and approval

- `single-owned`: one independent task without shared-contract impact.
- `parallel-owned`: two or more independent tasks with non-overlapping exclusive boundaries and no shared-contract mutation.
- `sequential-handoff`: dependency, shared file, contract producer/consumer ordering, retry or integration dependency.
- `blocked`: a failed precondition.

A batch requires a durable batch-specific Human Final Review before any worker mutation when it includes a material state change, shared/public contract, cross-contract work, or a changed task set, boundary, frozen version, exact command or checkpoint. Store it at `.sdd/reviews/dispatch-<feature>-<batch>.md` using the canonical recommendation/review block. A generic chat approval is invalid.

## Dispatch Record

Append this record under `## Current Handoff State` in the feature `TASKS.md`. It is durable evidence; host task IDs and Agent references are supplemental only.

```markdown
## Dispatch Record — D-<feature>-<batch>-A<attempt>
- Feature / batch / tasks: <slug; batch; ordered task IDs>
- Dispatcher: Claude Code `/sdd-dispatch`
- Dispatch mode: team | solo-bypass
- Batch type: single-owned | parallel-owned | sequential-handoff | blocked
- State: PLANNED | AWAITING_APPROVAL | READY | DISPATCHED | RUNNING | VERIFYING | RETRY_PENDING | COMPLETED | BLOCKED | ESCALATED
- Dependency and ownership check: <pass/fail evidence>
- Frozen contracts: <ID/version/owner or N/A>
- Approved scope and file boundaries: <task-owned paths>
- Profile bindings and exact commands: <approved evidence>
- State-change category: <none or categories>
- Human checkpoint: <review reference or N/A>
- Runtime identity evidence: VERIFIED | UNVERIFIED; <observed Agent/session evidence>
- Runtime enforcement evidence: VERIFIED | UNVERIFIED; <observed host evidence or absence>
- Host task-tracking evidence: AVAILABLE | UNAVAILABLE | NOT_USED; <optional Task evidence>
- Worker references: <Agent references or unavailable>
- Attempt and retry count: <attempt; consecutive failures; maximum 5>
- Worker results: <paths, Action Record, exact command/result>
- Integration validation: <boundary/contract/verification result>
- Residual blocker: <none or blocker>
- Sync-back decision: </sdd-trace, /sdd-sync, or N/A>
```

State transitions are:

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

Use `[ ]` before dispatch, `[/]` from `DISPATCHED` through `VERIFYING` or retry, and `[x]` only after `COMPLETED`, exact verification and required sync-back.

## Claude Code worker contract

Use the current Claude Code `Agent` tool only after observing that it is available. `TaskCreate`, `TaskGet`, `TaskList` and `TaskUpdate` may mirror status when available; their absence must be recorded as `UNAVAILABLE`, not bypassed with an invented tool. `.sdd/mcp-config.yaml` is a policy specification and does not prove host enforcement.

Each worker prompt must contain this immutable packet:

```text
DISPATCH ID: <id>
ROLE: <approved role>
TASK: <ID, title, Intent/DoD and REQ references>
OWNED FILE BOUNDARY: <exact paths only>
FROZEN CONTRACT: <ID/version/owner or N/A>
PROFILE EVIDENCE: <approved binding/version>
ALLOWED COMMANDS: <exact approved commands only>
STATE-CHANGE CATEGORY: <none/categories>
CHECKPOINT: <review reference or N/A>
AUDIT EVIDENCE REFERENCE: <Dispatch Record/review/action evidence>
POLICY STATUS: policy-only; host evidence is <VERIFIED|UNVERIFIED>
PROHIBITIONS: no out-of-boundary edits, package/config/contract changes, self-approval, commit or push.
STOP CONDITIONS: drift, scope conflict, missing command/checkpoint, policy/security issue, retry ineligibility.
RETURN: Action Record-compatible result, changed paths, command/result, requirement coverage, residual blocker and sync-back decision.
```

A prose completion claim without every return field is incomplete. Parallel workers are only allowed for `parallel-owned`; shared work, retries and integration validation are sequential. Lead alone creates/updates optional host task mirrors and integrates results.

## Retry and escalation

Retry only an implementation defect within the original task boundary when scope, boundary, frozen contract, binding, exact command and checkpoint are unchanged. Retry the failed task serially, append another attempt to its Dispatch Record and rerun only its approved command.

Never retry automatically for a Spec gap, profile/configuration gap, missing/revised/rejected checkpoint, shared-contract drift, ownership conflict, security/policy issue, dependency/runtime change, Agent launch/permission uncertainty, or any material action. Do not use retry to request broader permissions.

`RUNNING` interrupted by a session or worker loss, and `BLOCKED` after its evidence gap is resolved, require Lead revalidation with `--resume`; Lead closes the old record as `BLOCKED` and creates a new `PLANNED` Dispatch Record. If immutable inputs changed, a new applicable batch approval is required. `--resume` never reuses an old worker reference without observing it in the current host.

After five consecutive failures, set `ESCALATED`, retain `[/]`, create `.sdd/reviews/dispatch-<feature>-<batch>.md`, and require Human disposition under `AGT-S-02`. Only after that review explicitly authorizes recovery may Lead use `--resume`, close the escalated record and create a new `PLANNED` Dispatch Record; changed scope, boundary, frozen version, command or checkpoint requires a new batch approval.

## Solo mode

`--team-size=solo` records `solo-bypass`, creates no worker and preserves normal `/add-execute` Shadow Plan, Action Record, review, profile, checkpoint, commit and push restrictions.

## Completion and sync-back

Lead validates every returned boundary, Action Record, exact command/result, frozen-contract compatibility and required `/sdd-trace` or `/sdd-sync` decision. Stop integration on unresolved conflict. Refresh a recommendation when dispatch scope changes; Agent never approves a dispatch, task or contract.
