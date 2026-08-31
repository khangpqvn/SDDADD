# SDD + ADD Field Guide
# Version: 1.1.0

Thẻ thao tác nhanh. Contract chi tiết nằm trong `.claude/skills/`.

## Quy tắc bất biến

1. Agent đề xuất; Human ghi decision persisted bằng `/sdd-review`.
2. `PENDING`, `REVISE`, `REJECTED`, profile `BLOCKED`, missing command, contract drift hoặc missing checkpoint đều block affected action.
3. Context/Spec được technology-neutral; Plan/Tasks/execute không suy đoán tech binding hay command.
4. Test fail vì Spec thiếu rule: dùng `/sdd-update`, không vá behavior trước.
5. Mỗi task có Shadow Plan và Action Record.
6. Agent không `git push` trong solo hoặc team mode.

## Scenario → action

| Tình huống | Action |
| :--- | :--- |
| Greenfield chưa chọn stack | `/sdd-init` → Context/Spec business-neutral → review profile trước Plan. |
| Brownfield | `scripts/adopt.*` → `/sdd-adopt` → review profile evidence. |
| Feature mới | `/sdd-context` → `/sdd-spec` → review/lock → Plan → Tasks → execute. |
| Requirement/contract đổi | `/sdd-update --artifact=<context|spec|plan|tasks> --reason="..."`. |
| Test/CI fail | Phân loại implementation defect, Spec gap, profile/config gap hoặc material mutation. |
| Session dừng | `/sdd-handoff --feature=<slug>`. |
| Session tiếp tục | `/sdd-resume --feature=<slug>`. |
| Shared contract đổi | Owner/Lead cập nhật `.sdd/shared_context.md` → `/sdd-trace` → `/sdd-sync`. |
| Nhiều Agent | Dispatch contract-first, ownership không chồng lấn, Lead giữ shared artifact. |
| Git delivery | `/git-validate --scope=commit` → `READY` → Human-requested `/git-commit`. |

## Feature lifecycle

```text
/sdd-context --feature=<slug>
/sdd-review ... --artifact=context --status=APPROVED
/sdd-spec --feature=<slug>
/sdd-lint --feature=<slug>
/sdd-review ... --artifact=spec --status=APPROVED
/sdd-plan --feature=<slug>
/sdd-review ... --artifact=plan --status=APPROVED
/sdd-tasks --feature=<slug>
/sdd-review ... --artifact=tasks --status=APPROVED
/add-execute --feature=<slug>
/sdd-lint --feature=<slug>
/sdd-audit --feature=<slug>
/sdd-trace --feature=<slug>
/sdd-sync --feature=<slug> --reason="..."
```

## Task record minimum

```markdown
### T00X — <title>
- Intent reference: <WHAT/DoD and REQ-XXX>
- Input and expected outcome: <verifiable state>
- Layer and file boundary: <owned paths>
- Owner and dependencies: <owner; blockedBy or none>
- Profile binding and exact verification command: <approved evidence>
- Scope category: none | <material category>
- Human checkpoint: required | N/A; <evidence>
- Shared contract and sync-back: <owner/version; trace/sync decision>
- High-risk review route: <route or N/A>
```

## Material state change

| Category | Before action |
| :--- | :--- |
| Shared/public contract | Persisted Human checkpoint; contract owner/Lead controls mutation. |
| Schema/business-data mutation | Persisted Human checkpoint and approved recovery/rollback route. |
| Permission/security/dependency/runtime config | Persisted Human checkpoint. |
| External/irreversible side effect | Persisted Human checkpoint. |
| None | Shadow Plan and Action Record still required. |

## Self-heal

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

It runs an approved command and writes evidence only. It does not edit, self-approve, commit, push, deploy or execute a high-risk repair.

## Delivery

### Solo

```text
/git-validate --scope=commit
/git-commit --message="<conventional message>"
```

When validation and commit are complete, Human runs `git push -u origin <head>`. No Pull Request is required by solo mode.

### Team

```text
/git-validate --scope=commit
/git-commit --message="<conventional message>"
# Human pushes the branch
/git-validate --scope=pr --strict
/git-pr
```

Agent may create a Pull Request only after the remote branch exists, strict validation is `READY`, and Human confirms outward-facing content.

## Blocker table

| Blocker | Do not | Do |
| :--- | :--- | :--- |
| Missing binding/command | Guess package/command | Add evidence, get profile review, regenerate downstream work. |
| Spec gap | Patch code | `/sdd-update --artifact=spec`, review, lock, then resume. |
| Contract drift | Continue dispatch | Stop; contract owner/Lead resolves and syncs. |
| Material mutation without checkpoint | Execute | Persist Human checkpoint first. |
| Completed task lacks Action Record | Mark `[x]` | Record command/result, checkpoint and sync-back. |
| Git not `READY` | Commit/PR | Resolve validation evidence. |
