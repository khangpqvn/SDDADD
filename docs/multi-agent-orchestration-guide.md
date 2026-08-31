# Hướng dẫn điều phối nhiều Agent
# Version: 1.2.0

Dùng hướng dẫn này khi làm việc theo team trong Claude Code. `/sdd-dispatch` điều phối worker; `/add-execute` vẫn là contract thực thi atomic của từng worker. Nếu chỉ có một người làm, xem [Solo mode](#solo-mode).

## Khi nào nên dùng team mode?

Chỉ dispatch khi các task đã được duyệt, phụ thuộc đã hoàn tất và mỗi worker có ranh giới file độc quyền. Nếu task dùng chung file, shared contract, còn thiếu evidence hoặc cần quyết định mới, xử lý tuần tự hoặc để `BLOCKED`.

## Vai trò và ownership

| Vai trò | Trách nhiệm chính | Quy tắc ownership |
| :--- | :--- | :--- |
| Human Director | Quyết định business/risk và durable approval | Sở hữu Human decision cuối cùng. |
| Lead | Dispatch, integration và phân xử shared contract | Là dispatcher duy nhất; giữ shared artifact trừ khi explicit delegated. |
| Sub-agent | Một task atomic đã được duyệt | Chỉ sửa file boundary đã dispatch. |
| Tester | Bằng chứng verification | Không sửa implementation ngoài test scope được giao. |

Không để hai Agent sửa cùng file song song. Lead giữ file dùng chung hoặc tách task trước khi dispatch. Worker có thể yêu cầu đổi contract, nhưng chỉ owner hoặc Lead được áp dụng thay đổi đó.

## Lệnh dispatch và kiểm tra trước khi chạy

```text
/sdd-dispatch --feature=<slug> [--batch=<batch-id>] [--task=<T001,T002>] [--team-size=solo|team] [--retry] [--resume]
```

Trước dispatch, Lead phải đọc Context đã approved, Spec đã lock, Plan/Tasks đã approved, Architecture Profile, frozen contract record, handoff state, reviews và `.sdd/mcp-config.yaml`.

Mỗi task được chọn phải có đầy đủ:

```text
- task_id
- frozen_contract_version
- ownership_and_file_boundary
- selected_profile_bindings
- exact_approved_commands
- allowed_action_and_checkpoint
- audit_evidence_reference
```

Làm theo thứ tự:

1. Kiểm tra dependency đã complete, metadata đầy đủ, command/binding đã approved.
2. Kiểm tra contract owner/version còn khớp và file boundary không overlap.
3. Chọn batch type phù hợp.
4. Với material/cross-contract work, lưu batch-specific Human Final Review trước mutation.
5. Chỉ sau đó mới gọi `/sdd-dispatch`.

`--retry` chỉ dùng cho `RETRY_PENDING`. `--resume` chỉ dùng cho `RUNNING` bị gián đoạn, `BLOCKED` đã giải quyết evidence, hoặc `ESCALATED` có Human disposition. Missing evidence, drift, overlap, unapproved command, scope expansion, policy/security issue hoặc material decision mới đều là `BLOCKED`.

## Chọn batch type

| Batch type | Dùng khi | Cách chạy worker |
| :--- | :--- | :--- |
| `single-owned` | Một task độc lập | Một worker. |
| `parallel-owned` | Các task độc lập, boundary độc quyền và không overlap | Chạy worker đồng thời. |
| `sequential-handoff` | Có dependency, shared file/contract, retry hoặc cần integration theo thứ tự | Chạy từng task. |
| `blocked` | Thiếu evidence hoặc scope không tương thích | Không tạo worker. |

Artifact approval hiện có luôn bắt buộc. Ngoài ra phải có batch-specific Human Final Review được lưu trước mutation khi batch có material state change, shared/public contract, cross-contract work, hoặc thay đổi dispatch task set, boundary, frozen contract, exact command hay checkpoint. Lưu review tại `.sdd/reviews/dispatch-<feature>-<batch>.md`; chat approval chung không hợp lệ.

## Lifecycle và bằng chứng dispatch

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

Lead thêm `## Dispatch Record — <dispatch-id>` dưới `## Current Handoff State` trong `TASKS.md` của feature. Record phải ghi batch/task IDs, state, boundaries, frozen contracts, profile/commands, checkpoint, runtime identity/enforcement evidence, optional host task mirror, workers, attempts, Action Records trả về, integration result, blocker và sync-back decision.

Task marker vẫn là nguồn chuẩn:

- `[ ]`: chưa dispatch.
- `[/]`: đang dispatched, running, verifying hoặc retrying.
- `[x]`: chỉ sau exact verification, Action Record, checkpoint bắt buộc và sync-back đều đạt.

## Claude Code runtime mapping

Lead chỉ dùng Claude Code `Agent` tool khi công cụ đó quan sát được trong host hiện tại. Mỗi worker nhận immutable task, role, DoD/REQ, exact boundary, frozen contract, approved profile/commands, checkpoint, policy, prohibition và stop condition.

Worker hoàn thành phải trả về Action-Record-compatible changed paths, exact command/result, requirement coverage, blocker và sync-back decision.

`TaskCreate`, `TaskGet`, `TaskList` và `TaskUpdate` chỉ là session mirror tùy chọn. Chúng không tạo approval, contract ownership hoặc completion; khi host không có phải ghi `UNAVAILABLE`.

`.sdd/mcp-config.yaml` là policy specification. Nó `does not prove host enforcement`; YAML không tự chứng minh host đang thực thi policy. Runtime identity và enforcement chỉ được ghi `VERIFIED` từ bằng chứng quan sát trực tiếp tại host; nếu không thì ghi `UNVERIFIED`. Không yêu cầu quyền rộng hơn hoặc tuyên bố YAML tự enforce.

## Retry và integration

Chỉ dùng `/sdd-dispatch --retry` khi lỗi là implementation defect nằm trong task boundary, frozen contract, profile binding, exact command và checkpoint **không đổi**.

1. Retry đúng task thất bại, chạy tuần tự.
2. Thêm attempt vào Dispatch Record.
3. Chạy lại đúng exact approved command.

Không retry khi có Spec/profile/command/checkpoint/contract/ownership/security/policy/dependency/runtime gap, host launch/permission uncertainty hoặc material action mới. Sau maximum 5 lỗi liên tiếp, đặt `ESCALATED`, giữ `[/]`, tạo dispatch review report và yêu cầu Human disposition.

`RUNNING` bị gián đoạn hoặc `BLOCKED` đã có evidence dùng `--resume`, không dùng `--retry`: Lead đóng record cũ, revalidate, rồi tạo record `PLANNED` mới. `ESCALATED` cần explicit Human recovery decision; thay đổi immutable input cần batch approval mới.

Sau khi worker trả về, Lead kiểm tra boundary, Action Record, command result và contract compatibility. Shared work và integration luôn tuần tự. Chạy `/sdd-trace --feature=<slug> --diff` và `/sdd-sync --feature=<slug> --reason="..."` khi trigger hiện có áp dụng. Dừng nếu còn conflict.

## Handoff và resume

`/sdd-handoff` lưu active dispatch ID/state, attempts, workers, runtime evidence, pending approval và exact resume operation. `/sdd-resume` dùng `--retry` chỉ cho `RETRY_PENDING`; record `RUNNING` bị gián đoạn, `BLOCKED` đã có evidence và `ESCALATED` có Human disposition cần Lead revalidate rồi dùng `--resume`.

Không được giả định Agent reference cũ, task mirror hoặc host permission vẫn tồn tại.

## Solo mode

```text
/sdd-dispatch --feature=<slug> --team-size=solo
```

Lệnh này ghi `solo-bypass`, không tạo worker và quay về `/add-execute` thông thường. Solo vẫn giữ Shadow Plan, Action Record, Architecture Profile, review/checkpoint và no-push rules.

```text
/git-validate --scope=commit
/git-commit --message="<conventional message>"
```

Human sau đó chạy `git push -u origin <head>`.

## Checklist trước khi dispatch

- [ ] Tất cả artifact prerequisite đã approved và Spec đã lock.
- [ ] Task có `task_id`, frozen contract, boundary, binding, command, checkpoint và audit evidence.
- [ ] Không có ownership overlap hoặc contract drift.
- [ ] Batch type khớp dependency và integration risk.
- [ ] Batch cần approval đã có Human Final Review được lưu.
- [ ] Runtime evidence được ghi trung thực là `VERIFIED` hoặc `UNVERIFIED`.
- [ ] Lead biết điều kiện phải dừng thay vì retry hoặc mở rộng scope.
