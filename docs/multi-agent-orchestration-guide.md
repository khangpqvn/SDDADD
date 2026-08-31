# Multi-Agent Orchestration Guide
# Version: 1.2.0

Use this guide for contract-first team work in Claude Code. `/sdd-dispatch` coordinates workers; `/add-execute` remains their atomic execution contract. Solo mode is at the end.

## Roles and ownership

| Role | Primary responsibility | Ownership rule |
| :--- | :--- | :--- |
| Human Director | Business/risk decision and durable approval | Owns final Human decisions. |
| Lead | Dispatch, integration and shared-contract arbitration | Sole dispatcher; owns shared artifacts unless explicitly delegated. |
| Sub-agent | Approved atomic task | Edits only dispatched file boundary. |
| Tester | Verification evidence | Does not modify implementation outside assigned test scope. |

No two agents edit the same file in parallel. The Lead retains a shared file or splits work before dispatch. Workers may request a contract change but only its owner or Lead may apply it.

## Command and preflight

```text
/sdd-dispatch --feature=<slug> [--batch=<batch-id>] [--task=<T001,T002>] [--team-size=solo|team] [--retry] [--resume]
```

Before dispatch, Lead reads approved Context, locked Spec, approved Plan/Tasks, Architecture Profile, frozen contract records, handoff state, reviews and `.sdd/mcp-config.yaml`. Every selected task must have all of:

```text
- task_id
- frozen_contract_version
- ownership_and_file_boundary
- selected_profile_bindings
- exact_approved_commands
- allowed_action_and_checkpoint
- audit_evidence_reference
```

Task dependencies must be complete, task metadata must be present, commands/bindings must be approved, contracts must match current owner/version, and selected file boundaries must not overlap. `--retry` is only for `RETRY_PENDING`; `--resume` is only for interrupted `RUNNING`, evidence-resolved `BLOCKED`, or Human-dispositioned `ESCALATED` work. Missing evidence, drift, overlap, unapproved command, scope expansion, policy/security issue or new material decision is `BLOCKED`.

## Batch types and approval

| Batch type | Use | Worker execution |
| :--- | :--- | :--- |
| `single-owned` | One independent task | One worker. |
| `parallel-owned` | Independent tasks with exclusive, non-overlapping boundaries | Concurrent workers. |
| `sequential-handoff` | Dependency, shared file/contract, retry or integration order | One task at a time. |
| `blocked` | Missing evidence or incompatible scope | No worker. |

Existing artifact approvals are always required. A persisted batch-specific Human Final Review is additionally required before mutation for material state change, shared/public contract or cross-contract work, and whenever dispatch task set, boundary, frozen contract, exact command or checkpoint changes. Store that review in `.sdd/reviews/dispatch-<feature>-<batch>.md`; generic chat approval is not valid.

## Dispatch lifecycle and evidence

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

Lead appends `## Dispatch Record — <dispatch-id>` below `## Current Handoff State` in feature `TASKS.md`. It records batch/task IDs, state, boundaries, frozen contracts, profile/commands, checkpoint, runtime identity/enforcement evidence, optional host task mirror, workers, attempts, returned Action Records, integration result, blocker and sync-back decision.

Task markers remain authoritative: `[ ]` before dispatch, `[/]` while dispatched/running/verifying/retrying, and `[x]` only after exact verification, Action Record, required checkpoint and sync-back all pass.

## Claude Code runtime mapping

The Lead uses the Claude Code `Agent` tool only when it is observable in the current host. Every worker receives immutable task, role, DoD/REQ, exact boundary, frozen contract, approved profile/commands, checkpoint, policy, prohibition and stop-condition fields. A completion response must return Action-Record-compatible changed paths, exact command/result, requirement coverage, blocker and sync-back decision.

`TaskCreate`, `TaskGet`, `TaskList` and `TaskUpdate` are optional session mirrors. They never establish approval, contract ownership or completion and must be recorded `UNAVAILABLE` when absent.

`.sdd/mcp-config.yaml` is a policy specification. It does not prove host enforcement. Runtime identity and enforcement evidence must be marked `VERIFIED` only from observed host evidence; otherwise record `UNVERIFIED`. Do not request broader permissions or claim enforcement from YAML.

## Retry and integration

Automatic retry applies only to an implementation defect inside the unchanged approved task boundary, frozen contract, profile binding, exact command and checkpoint. Retry only the failed task, serially, append an attempt to its Dispatch Record and rerun its exact approved command.

Never retry a Spec/profile/command/checkpoint/contract/ownership/security/policy/dependency/runtime gap, host launch/permission uncertainty or new material action. At five consecutive failures, set `ESCALATED`, retain `[/]`, create a dispatch review report and require Human disposition. An interrupted `RUNNING` task or evidence-resolved `BLOCKED` task uses `--resume`, not `--retry`: Lead closes its old record and creates a new `PLANNED` record after revalidation. `ESCALATED` requires an explicit Human recovery decision before the same route; immutable-input changes require new batch approval.

After workers return, Lead validates boundaries, Action Records, command results and contract compatibility. Shared work and integration remain sequential. Run `/sdd-trace --feature=<slug> --diff` and `/sdd-sync --feature=<slug> --reason="..."` when their existing triggers apply. Stop on unresolved conflict.

## Handoff and resume

`/sdd-handoff` preserves active dispatch ID/state, attempts, workers, runtime evidence, pending approval and exact resume operation. `/sdd-resume` uses `--retry` only for `RETRY_PENDING`; interrupted `RUNNING`, evidence-resolved `BLOCKED`, and Human-dispositioned `ESCALATED` records require Lead revalidation then `--resume`. It never assumes an old Agent reference, task mirror or host permission still exists.

## Solo mode

```text
/sdd-dispatch --feature=<slug> --team-size=solo
```

This records `solo-bypass`, creates no worker and routes to the normal `/add-execute` process. Solo retains Shadow Plan, Action Record, Architecture Profile, review/checkpoint and no-push rules.

```text
/git-validate --scope=commit
/git-commit --message="<conventional message>"
```

Human then runs `git push -u origin <head>`.
