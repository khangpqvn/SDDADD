# SDD + ADD Scenario Playbook

Quy trình thao tác theo tình huống. Các command contract là nguồn chuẩn; tài liệu này chỉ điều hướng.

## 1. Greenfield core-only

1. Chạy `/sdd-init --project-name="<name>"`.
2. Review `.sdd/architecture-profile.md` và bootstrap recommendation.
3. Tạo `/sdd-context --feature=<slug>`; ghi Intent Packet và Methodology Profile.
4. Review Context, rồi tạo/làm review/lock Spec.
5. Chỉ khi feature cần kỹ thuật: chọn binding cùng exact command trong profile và review profile.
6. Tạo Plan, Tasks và thực thi theo lifecycle.

Không tạo adapter hoặc dùng command giả định trong core-only baseline.

## 2. Brownfield adoption

1. Chạy `scripts/adopt.sh <target>` hoặc `scripts/adopt.ps1 -TargetPath <target>`.
2. Trong repository đích chạy `/sdd-adopt`.
3. Đối chiếu manifest, CI, source và configuration với Architecture Profile.
4. Mâu thuẫn là `PENDING HUMAN REVIEW`, không phải inference.
5. Review adoption scope trước feature work.

`adopt` không overwrite file hiện hữu nếu không explicit force.

## 3. Standard feature

1. `/sdd-context --feature=<slug>` tạo Intent Packet, unresolved decision disposition và Methodology Profile.
2. Human approves Context.
3. `/sdd-spec --feature=<slug>` tạo EARS, acceptance, error behavior, Feature Lock và out-of-scope.
4. Human approves/locks Spec.
5. `/sdd-plan` maps requirements, profile binding, consistency and state-change impact.
6. Human approves Plan.
7. `/sdd-tasks` creates atomic ownership, checkpoint and sync-back records.
8. Human approves Tasks.
9. `/add-execute` runs each approved task with Shadow Plan and Action Record.
10. `/sdd-lint`, `/sdd-audit`, `/sdd-trace`, `/sdd-sync` produce delivery evidence.

## 4. Requirement, contract or plan change

```text
/sdd-update --feature=<slug> --artifact=<context|spec|plan|tasks> --reason="..."
```

1. Record Change Impact: changed intent/requirement/assumption, Feature Lock impact, material category, invalidated downstream artifacts, trace/test/sync and review follow-up.
2. Context change affecting intent, actor, boundary, constraint or risk explicitly decides whether a Spec revision is required.
3. Spec change evaluates Plan and Tasks before resuming.
4. Review new recommendation; old review is invalid.
5. Use `/sdd-trace --feature=<slug> --diff`; sync shared contract when applicable.

## 5. Test or CI failure

1. Preserve exact command and output.
2. Classify the failure.
   - Implementation defect: repair only inside approved task/file boundary.
   - Spec gap: update/review Spec.
   - Profile/configuration gap: update/review profile.
   - Material/high-risk mutation: require checkpoint before action.
3. Re-run the exact approved command.
4. Refresh Action Record, trace and sync decisions.

Do not add a test filter, skip or mock solely to turn a failure into success.

## 6. Material state change

Before shared/public contract, schema/business-data, permission/security/dependency/runtime configuration, or external/irreversible action:

1. Classify it in Plan/Task/Shadow Plan.
2. Identify contract owner and recovery/rollback information where applicable.
3. Persist the Human checkpoint using review evidence.
4. Execute only the approved action/file boundary.
5. Record result and required trace/sync in Action Record.

## 7. Shared contract and multi-agent dispatch

1. Lead reads frozen contract in `.sdd/shared_context.md`.
2. Dispatch includes task ID, frozen contract version, ownership/file boundary, selected profile bindings, exact commands, allowed action/checkpoint and audit evidence reference.
3. Run parallel work only with non-overlapping ownership.
4. Contract owner or Lead is the only actor that mutates shared contract.
5. Any contract drift, overlap, evidence mismatch or new material decision stops the affected task.
6. After integration, Lead validates compatibility, then trace/sync.

`.sdd/mcp-config.yaml` is a policy specification. Runtime host enforcement must be configured separately; the file itself does not prove enforcement.

## 8. Handoff and resume

### Handoff

```text
/sdd-handoff --feature=<slug>
```

Ensure `Current Handoff State` records Intent/DoD, approved scope, active contract version, profile binding, exact command/result, checkpoint, next decision/command, blockers and Action Record.

### Resume

```text
/sdd-resume --feature=<slug>
```

Resume blocks when required binding, review, checkpoint, contract ownership or exact command is missing. Legacy high-risk work requires Human disposition rather than automatic invalidation.

## 9. Self-heal evidence collection

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

The script is opt-in and evidence-only. It rejects non-implementation scope and never applies a repair, commit, push, deploy, approval or external action.

## 10. Delivery

1. Verify intended diff and evidence.
2. Run `/git-validate --scope=commit`.
3. On `READY`, Agent may create a commit only when Human requests it.
4. Human runs `git push -u origin <head>`.
5. Team delivery then runs strict remote validation and may create a PR after Human confirms its content. Solo skips PR overhead.

## 11. Constitution change

Use `/sdd-rfc`. Do not edit `CONSTITUTION.md` directly after template release. An approved RFC is required before constitutional governance changes.
