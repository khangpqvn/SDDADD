# Hướng dẫn Agent execution và worker orchestration

Đọc tài liệu này khi `TASKS.md` đã được review và bạn cần chạy task hoặc snapshot feature. `Project Ownership` và `Agent Execution` là hai trục độc lập trong `.sdd/shared_context.md`.

- `Project Ownership: solo|team`: ai được review và delivery.
- `Agent Execution: direct|orchestrated`: task chạy trong session hiện tại hay qua worker.

## 1. Chỉ dùng một public entry point

```text
/add-execute --feature=<slug> --task=<T001>
/add-execute --feature=<slug> --all
/add-execute --feature=<slug> --task=<T001> --retry
/add-execute --feature=<slug> --task=<T001> --resume
```

`--feature` bắt buộc. Chọn đúng một `--task` hoặc `--all`. `--retry` và `--resume` chỉ dùng với `--task`, không dùng cùng nhau hoặc với `--all`.

Không truyền thủ công `--agent-execution`, `--project-ownership`, `--team-size`, `--dispatch-record`, `--dispatch-grant` hoặc `--dispatch-consumer`. Command tự đọc persisted governance và tạo execution evidence nội bộ.

## 2. Direct và orchestrated

| Route | Điều kiện | Hành vi và gate |
| :--- | :--- | :--- |
| `direct` | Preflight hợp lệ | Agent hiện tại thực thi; vẫn cần Shadow Plan, Execution/Action Record, Profile, checkpoint, exact command và validation. |
| `orchestrated` | Preflight hợp lệ và runtime Claude Code `Agent` capability đã observed | `/add-execute` tạo immutable worker packet; worker chỉ sửa boundary được giao; coordinator validate integration. |

Runtime worker unavailable với route `orchestrated` là `BLOCKED`; không fallback sang `direct`. Policy YAML, Markdown record hoặc consumer reference không tự chứng minh host enforcement; khi chưa quan sát được atomic host claim, ghi `UNVERIFIED`.

## 3. Preconditions và selection

Trước execution, `TASKS.md` phải có `Human Final Review: APPROVED`. Task phải có intent, REQ reference, file boundary, dependency, Profile binding, exact command, checkpoint category và shared-contract owner/version phù hợp.

- `--task` preflight task được chỉ định.
- `--all` chụp snapshot các task chưa complete và eligible theo thứ tự khai báo, rồi preflight toàn snapshot trước action.
- Snapshot dừng tại blocker, Human gate, drift, sequential failure hoặc cancellation; không tự thêm task mới eligible sau khi snapshot đã tạo.
- Task non-overlap, không dependency và không shared-contract mutation mới có thể chạy song song theo contract. Shared work, retry, integration và dependency handoff chạy tuần tự.

Missing evidence, overlap, scope expansion, unapproved command, policy violation hoặc material decision mới đều là `BLOCKED`.

## 4. Execution Record và grant

`/add-execute` append `Execution Record` trong `## Current Handoff State` của `TASKS.md`. Record mô tả route, selection, immutable inputs, runtime evidence, integration state và grant của từng attempt.

Grant chỉ hợp lệ khi matching task/feature/route/immutable input/consumer và ở trạng thái được phép. Grant phải được consume trước Shadow Plan, command, edit hoặc action:

```text
preflight
→ persist RUNNING/CONSUMED
→ Shadow Plan
→ checkpoint nếu cần
→ action trong boundary
→ exact approved command
→ Action Record và integration evidence
```

Grant missing, consumed, stale, cross-feature, cross-task, cross-record hoặc mismatched consumer là `BLOCKED`. Không reset hoặc reuse grant. Markdown record không phải atomic lock giữa các session; chỉ claim host-controlled đã observed mới được coi là enforcement.

## 5. Worker packet

Với route `orchestrated`, packet immutable phải đủ để worker biết:

- execution/feature/task/grant attempt;
- Intent/DoD và REQ references;
- owned file boundary;
- frozen contract owner/version hoặc `N/A`;
- Profile evidence và exact allowed command;
- state-change category và checkpoint;
- audit/evidence reference;
- prohibition và stop conditions.

Worker trả changed paths, command/result, requirement coverage, consumption evidence, blocker và sync-back decision. Coordinator xác minh boundary, contract compatibility, validation và integration trước completion.

## 6. State, retry và resume

Lifecycle chính:

```text
PLANNED → READY → DISPATCHED → RUNNING → VERIFYING → COMPLETED
```

Các nhánh `AWAITING_APPROVAL`, `BLOCKED`, `RETRY_PENDING` và `ESCALATED` phải theo transition được định nghĩa trong `SKILL.md`; không tự chuyển state để né gate.

- `--retry`: named task ở `RETRY_PENDING` do implementation defect, immutable inputs không đổi. Grant consumed được retire và attempt mới được cấp.
- `--resume`: named task bị interruption, `BLOCKED` đã resolve hoặc `ESCALATED` đã có Human disposition. Revalidate record, Profile, command, contract, checkpoint và runtime trước khi chạy.
- Spec/Profile/command/checkpoint/contract/ownership/security/dependency/runtime gap không phải retryable defect.
- Sau threshold failure của contract, giữ evidence, set `ESCALATED` và chờ Human disposition.

## 7. Handoff và delivery

Dùng `/sdd-handoff` khi session dừng và `/sdd-resume` khi tiếp tục. Không giả định worker identity, permission hoặc grant cũ còn hợp lệ.

Sau execution:

1. Chạy exact approved command.
2. Chạy lint/audit/trace/sync khi trigger áp dụng.
3. Tạo post-code review khi source/test/contract/config/schema/state thay đổi.
4. Chạy `/git-validate` trước commit.
5. Human xử lý commit/push theo `Project Ownership`; Agent không `git push`.

## Contract owner

Chi tiết preflight, transition, grant lifecycle và packet phải khớp `.claude/skills/add-execute/SKILL.md`. Tài liệu này chỉ giúp chọn route và nhận biết blocker; không thay thế skill contract.
