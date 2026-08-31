# Multi-Agent Orchestration Guide
# Version: 1.1.0

Use this guide for contract-first multi-agent work. Solo mode is covered at the end.

## Roles and ownership

| Role | Primary responsibility | Ownership rule |
| :--- | :--- | :--- |
| Human Director | Business/risk decision and durable approval | Owns final Human decisions. |
| Lead | Dispatch, integration and shared-contract arbitration | Owns shared artifacts unless explicitly delegated. |
| Sub-agent | Approved atomic task | Edits only dispatched file boundary. |
| Tester | Verification evidence | Does not modify implementation outside assigned test scope. |

No two agents edit the same file in parallel. The Lead retains a shared file or splits work before dispatch.

## Preflight

Before dispatch, Lead reads approved Context, locked Spec, approved Plan/Tasks, Architecture Profile and frozen contract records. Each dispatch includes:

```text
- task_id
- frozen_contract_version
- ownership_and_file_boundary
- selected_profile_bindings
- exact_approved_commands
- allowed_action_and_checkpoint
- audit_evidence_reference
```

A sub-agent stops if a field is absent, profile evidence conflicts, ownership overlaps, contract drifts or work needs a new material decision.

## Dispatch lifecycle

```text
Lead validates task and contract
→ Human approves multi-agent Shadow Plan when required
→ independent owned tasks run
→ agents record Action Record/evidence
→ Lead validates compatibility and sync-back
→ trace, audit and delivery review
```

Parallel batches contain only independent tasks. A dependency or shared contract boundary creates a sequential handoff.

## Multi-Agent Shadow Plan

```text
MULTI-AGENT SHADOW PLAN — Feature: <slug>

INTENT AND DONE
- WHAT/DoD: <locked intent and requirements>
- Feature Lock boundary: <included and deferred work>

ARCHITECTURE PROFILE
- Version/status: <approved profile>
- Selected bindings/evidence: <only task-relevant values>
- Exact commands: <approved commands>

CONTRACT AND OWNERSHIP
- Contract/version/owner: <record or N/A>
- State-change category/checkpoint: <category and review evidence>
- Batch/owners/file boundaries: <non-overlapping work>
- Sync-back: </sdd-trace and /sdd-sync decision>
```

Scope or binding changes, missing evidence, contract drift and material action require a new plan/checkpoint before affected work continues.

## Shared contracts

`.sdd/shared_context.md` stores frozen records with contract ID/version/status, producer, consumers, owner, compatibility, linked requirements/tasks/evidence, last sync and unresolved decision.

- Only contract owner or Lead mutates a shared contract.
- A sub-agent reads contract before change and stops if it lacks ownership.
- Contract mutations require an Action Record and required Human checkpoint.
- Lead runs `/sdd-trace --feature=<slug> --diff` and `/sdd-sync --feature=<slug> --reason="..."` when contract/state changes.

## MCP policy

`.sdd/mcp-config.yaml` is a policy specification for dispatch/audit. Runtime host enforcement must map or enforce it separately; the YAML alone does not prove host enforcement.

Tool borrowing is exceptional and records task ID, temporary scope, justification, Lead action and outcome. It never bypasses Architecture Profile or checkpoint gates.

## Handoff and integration

Every agent reports file boundary, exact command/result, Action Record, residual blocker and sync-back decision. Lead verifies contract compatibility and ownership before the next batch. Integration stops on unresolved conflict rather than silently reconciling assumptions.

## Solo mode

```text
/sdd-init --project-name="<name>" --team-size=solo
```

A sole developer holds execution ownership but still follows Intent Packet, Feature Lock, Architecture Profile, Shadow Plan, Action Record and material-state checkpoint rules. Solo removes multi-agent dispatch and Pull Request overhead; it does not let Agent self-approve or push.

Solo delivery:

```text
/git-validate --scope=commit
/git-commit --message="<conventional message>"
```

Human then runs `git push -u origin <head>`.
