# Tra cứu nhanh SDD + ADD
# Version: 1.1.0

Dùng trang này khi đang làm việc và cần chọn bước tiếp theo. Contract chi tiết của từng command nằm trong `.claude/skills/`.

## Sáu quy tắc không được bỏ qua

1. Agent đề xuất; Human ghi decision persisted bằng `/sdd-review`.
2. `PENDING`, `REVISE`, `REJECTED`, profile `BLOCKED`, missing command, contract drift hoặc missing checkpoint đều block affected action.
3. Context/Spec có thể technology-neutral; Plan/Tasks/execute không suy đoán tech binding hay command.
4. Test fail vì Spec thiếu rule: dùng `/sdd-update`, không vá behavior trước.
5. Mỗi task có Shadow Plan và Action Record.
6. Agent không `git push` trong solo hoặc team mode.

## Chọn tình huống rồi làm theo

| Tình huống | Action ngay | Dừng khi |
| :--- | :--- | :--- |
| Greenfield chưa chọn stack | `/sdd-init` → Context/Spec business-neutral → review profile trước Plan. | Feature cần technical binding/command chưa approved. |
| Brownfield | `scripts/adopt.*` → `/sdd-adopt` → review profile evidence. | Evidence mâu thuẫn hoặc thiếu. |
| Feature mới | `/sdd-context` → `/sdd-spec` → review/lock → Plan → Tasks → execute. | Artifact cần review chưa `APPROVED`. |
| Requirement/contract đổi | `/sdd-update --artifact=<context|spec|plan|tasks> --reason="..."`. | Downstream review chưa làm lại. |
| Test/CI fail | Phân loại implementation defect, Spec gap, profile/config gap hoặc material mutation. | Chưa có exact command/evidence hoặc scope không còn hợp lệ. |
| Session dừng | `/sdd-handoff --feature=<slug>`. | Handoff chưa ghi next decision/command. |
| Session tiếp tục | `/sdd-resume --feature=<slug>`. | Review, binding, command, contract hoặc checkpoint thiếu. |
| Shared contract đổi | Owner/Lead cập nhật `.sdd/shared_context.md` → `/sdd-trace` → `/sdd-sync`. | Contract owner/version chưa khớp. |
| Nhiều Agent | `/sdd-dispatch --feature=<slug>`; Dispatch Record, ownership không chồng lấn, Lead giữ shared artifact. | File boundary overlap hoặc missing evidence. |
| Parallel-owned batch | `/sdd-dispatch --feature=<slug> --batch=<id> --task=<T001,T002>` sau preflight và approval applicable. | Task không độc lập. |
| Retry eligible task | `/sdd-dispatch --feature=<slug> --task=<T001> --retry`; chỉ `RETRY_PENDING` implementation defect trong immutable boundary. | Input/scope/command/checkpoint đổi. |
| Interrupted/blocked/escalated task | Lead revalidates rồi `/sdd-dispatch --feature=<slug> --task=<T001> --resume`. | Escalated work chưa có explicit Human recovery decision. |
| Material/cross-contract batch | Tạo `.sdd/reviews/dispatch-<feature>-<batch>.md`, Human review `APPROVED`, rồi dispatch. | Chưa có persisted approval. |
| Solo dispatch request | `/sdd-dispatch --feature=<slug> --team-size=solo`; solo-bypass, không spawn worker. | Artifact gate chưa đạt. |
| Git delivery | `/git-validate --scope=commit` → `READY` → Human-requested `/git-commit`. | Validation không `READY`. |

## Chuỗi lệnh một feature

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

## Task record

Không chép lại schema task tại đây vì `.claude/skills/sdd-tasks/SKILL.md` là nguồn chuẩn và thay đổi cùng command contract. Trước khi Human review `TASKS.md`, dùng schema do `/sdd-tasks` tạo; tối thiểu kiểm tra task có ownership/file boundary, approved profile binding và exact verification command, checkpoint, dependency, shared-contract/sync-back và `Dispatch readiness` khi team dispatch.

## Thay đổi trạng thái trọng yếu

| Category | Trước action |
| :--- | :--- |
| Shared/public contract | Persisted Human checkpoint; contract owner/Lead controls mutation. |
| Schema/business-data mutation | Persisted Human checkpoint và approved recovery/rollback route. |
| Permission/security/dependency/runtime config | Persisted Human checkpoint. |
| External/irreversible side effect | Persisted Human checkpoint. |
| None | Shadow Plan và Action Record vẫn bắt buộc. |

## Self-heal

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

Script chỉ chạy approved command và ghi evidence. Nó không edit, self-approve, commit, push, deploy hoặc repair high-risk scope.

## Delivery

### Solo

```text
/git-validate --scope=commit
/git-commit --message="<conventional message>"
```

Validation và commit xong, Human chạy `git push -u origin <head>`. Solo mode không yêu cầu Pull Request.

### Team

```text
/git-validate --scope=commit
/git-commit --message="<conventional message>"
# Human pushes the branch
/git-validate --scope=pr --strict
/git-pr
```

Agent chỉ tạo Pull Request sau khi remote branch tồn tại, strict validation là `READY`, và Human xác nhận nội dung outward-facing.

## Bảng xử lý blocker

| Blocker | Không làm | Làm đúng |
| :--- | :--- | :--- |
| Missing binding/command | Guess package/command | Add evidence, get profile review, regenerate downstream work. |
| Spec gap | Patch code | `/sdd-update --artifact=spec`, review, lock, rồi resume. |
| Contract drift | Continue dispatch | Stop; contract owner/Lead resolves and syncs. |
| Material mutation without checkpoint | Execute | Persist Human checkpoint trước. |
| Completed task lacks Action Record | Mark `[x]` | Record command/result, checkpoint và sync-back. |
| Git not `READY` | Commit/PR | Resolve validation evidence. |
