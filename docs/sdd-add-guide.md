# Hướng dẫn vận hành SDD + ADD
# Version: 7.2.0

Tài liệu vận hành đầy đủ cho Product Owner, Human Director, Tech Lead, Developer, QA và AI Agent. Các skill trong `.claude/skills/` là command contract; tài liệu này mô tả workflow và decision cần có.

## 1. Mô hình vận hành

SDD quản lý intent, requirement, contract, risk, traceability và validation. ADD cho Agent thực thi trong boundary đã approved.

```text
CONTEXT → SPEC → PLAN → TASKS → execute → verify → sync
```

Agent đề xuất và ghi evidence. Human sở hữu business decision, risk acceptance và Human Final Review. Chat acknowledgement không phải durable approval.

Agent không tự approve, không bypass quality gate, không suy đoán stack/command, không commit nếu chưa có Human request, và không `git push` hoặc deploy.

## 2. Artifact contract

| Artifact | Nội dung bắt buộc | Gate |
| :--- | :--- | :--- |
| `CONTEXT.md` | Intent Packet, Methodology Profile, glossary, constraints, question disposition | Human review trước Spec |
| `SPEC.md` | EARS, BDD/acceptance, errors, out-of-scope, SemVer, Feature Lock | `APPROVED & LOCKED` trước technical execution |
| `PLAN.md` | `REQ-XXX` mapping, data flow, risk, profile evidence, consistency map | Human review trước Tasks |
| `TASKS.md` | atomic task, owner, file boundary, command, checkpoint, sync-back | Human review trước execute |

### Intent Packet

```markdown
## Intent Packet
- WHAT: <observable outcome>
- WHY: <problem or value>
- Definition of Done: <verifiable conditions>
- Boundaries: <included behavior>
- Exclusions: <deferred behavior>
- Decision owner: <human role>
```

Intent is technology-neutral. A material question is `resolved`, an `approved assumption`, `deferred`, or a `blocking decision`; otherwise Context cannot advance.

### Methodology Profile

```markdown
## Methodology Profile
- Depth: Sketch | Detailed | Formal
- Rationale: <risk and complexity>
- Risk posture: low | elevated | high
- High-risk review route: <durable route or N/A>
- Unresolved-decision owner: <human role>
```

High-risk review route is required for sensitive data, financial/business-critical behavior, destructive/irreversible work, compliance, authorization, cross-system consistency and public/external contracts. It calibrates review depth only; it never chooses technology or bypasses profile evidence.

### Feature Lock

Feature Lock freezes behavior and contract within the current feature/sprint only. Deferred work remains explicit. A change uses `/sdd-update`, invalidates affected review and requires new durable review.

## 3. Architecture Profile gate

`.sdd/architecture-profile.md` precedence:

```text
approved profile → clear repository evidence → explicit input → core-only baseline
```

Context/Spec may be core-only and business-neutral. Plan, Tasks and execution stop if a relevant binding or exact command is missing. Do not replace missing command with `npm`, `pnpm`, `yarn` or a placeholder.

## 4. Human Final Review

Artifacts use the canonical blocks from `.claude/skills/_shared/ai-review-protocol.md`. `APPROVED` requires decision, reviewer, timestamp and follow-up. `REVISE` and `REJECTED` block downstream work. Artifact change after approval invalidates that approval.

Use `/sdd-review` instead of manual status edits when command target is supported. Architecture Profile is a valid review target, but review cannot make a missing binding or command valid.

## 5. Plan and task design

Plan maps every implementation/data flow to `REQ-XXX`, classifies state change, identifies shared-contract impact and records trace/sync ownership.

Each task contains:

```markdown
### T00X — <title>
- Intent reference: <WHAT/DoD and REQ-XXX>
- Input and expected outcome: <verifiable state>
- Layer and file boundary: <owned paths>
- Owner and dependencies: <owner; blockedBy or none>
- Profile binding and exact verification command: <approved evidence>
- Scope category: none | <material category>
- Human checkpoint: required | N/A; <evidence>
- Shared contract and sync-back: <responsibility; trace/sync decision>
- High-risk review route: <route or N/A>
```

Tasks cannot silently absorb Feature Lock exclusions.

## 6. Execute and evidence

Every task starts with a Shadow Plan containing Intent/DoD, scope/file boundary, profile version/binding/evidence, exact command, state-change category, checkpoint, contract/version, risk and sync-back decision.

### Material state change

Persisted Human checkpoint is required **before action** for:

- shared/public contract;
- persistence schema or business-data mutation;
- permission, security, dependency or runtime configuration;
- external or irreversible side effect.

Read-only/low-risk task still needs Shadow Plan and Action Record, but baseline does not require a checkpoint. `/add-execute --strict-checkpoint` is opt-in for every task.

### Action Record

```markdown
## Action Record — <task-id>
- Actor: <human or agent role>
- Approved scope and file boundary: <paths and intent>
- Profile binding and exact commands: <approved evidence>
- State-change category: <none or categories>
- Human checkpoint: <review reference or N/A>
- Actions and result: <change/run and outcome>
- Residual blocker: <none or blocker>
- Sync-back decision: <affected artifacts; trace/sync decision>
```

Task completion requires checkpoint, verification and sync-back evidence when applicable.

## 7. Failure classification

| Classification | Required action |
| :--- | :--- |
| Implementation defect | Repair only in approved task/file boundary; rerun exact command. |
| Spec gap | Stop, `/sdd-update --artifact=spec`, review/lock, update downstream work. |
| Profile/configuration gap | Stop, update/review profile; do not infer an adapter or command. |
| Prohibited/high-risk mutation | Stop; get required Human checkpoint and route. |

Use `/sdd-trace --feature=<slug> --diff` for requirement/code/test changes. Use `/sdd-sync --feature=<slug> --reason="..."` for shared contract or state changes.

## 8. Shared contract and multi-agent work

`.sdd/shared_context.md` holds frozen records: ID/version/status, producer, consumers, owner, compatibility, linked requirements/tasks/evidence, last sync and unresolved decision.

Only contract owner or Lead mutates a shared contract. Every dispatch includes task ID, frozen contract version, ownership/file boundary, selected profile binding, exact command, allowed action/checkpoint and audit evidence. Contract drift or overlapping ownership blocks affected work.

`.sdd/mcp-config.yaml` is a dispatch/audit policy specification; runtime host enforcement must be configured separately.

## 9. Handoff and resume

`/sdd-handoff` records Intent/DoD, active contract version, approved boundary, checkpoint, exact command/result, blocker and next decision in `Current Handoff State` with Action Record.

`/sdd-resume` restores this data and proposes execution only when review, profile, command, contract ownership and required checkpoint are valid. Legacy high-risk features need Human disposition rather than automatic invalidation.

## 10. Self-heal

`self-heal.sh` is opt-in evidence collection, not an automated repair mechanism:

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

It rejects unapproved/malformed commands and every non-implementation scope. It never edits source, self-approves, commits, pushes, deploys or claims that `claude --print` applied a repair.

## 11. Delivery

1. Verify exact command output, Action Records, audit, trace and sync evidence.
2. `/git-validate --scope=commit` must return `READY`.
3. Agent commits only when Human requests it.
4. Human runs `git push -u origin <head>`.
5. Team flow then runs `/git-validate --scope=pr --strict`; Agent may create a PR only after remote branch exists and Human confirms outward-facing content. Solo skips PR overhead.

## 12. Completion checklist

- [ ] Intent, Methodology Profile and Feature Lock match the delivered scope.
- [ ] Required artifacts/reviews are valid.
- [ ] Profile has relevant approved bindings and exact commands.
- [ ] Every complete task has verification, Action Record and required checkpoint/sync-back.
- [ ] Trace has no affected broken consistency.
- [ ] Shared contract owner/version/compatibility are synchronized when applicable.
- [ ] Git validation is `READY`.
