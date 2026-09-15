# Hướng dẫn Agent execution và worker orchestration

Dùng tài liệu này khi thực thi task hoặc feature đã approved. `Project Ownership` và `Agent Execution` là hai trục độc lập trong `.sdd/shared_context.md`.

- `Project Ownership: solo`: một Human project owner; họ vẫn có thể dùng worker orchestration.
- `Project Ownership: team`: nhiều Human collaborator; họ vẫn có thể direct execution.
- `Agent Execution: direct`: `/add-execute` thực thi trong session hiện tại.
- `Agent Execution: orchestrated`: `/add-execute` chỉ điều phối worker khi Claude Code `Agent` capability đã được quan sát.

## Public command duy nhất

```text
/add-execute --feature=<slug> --task=<T001> [--strict-checkpoint]
/add-execute --feature=<slug> --all [--strict-checkpoint]
/add-execute --feature=<slug> --task=<T001> --retry [--strict-checkpoint]
/add-execute --feature=<slug> --task=<T001> --resume [--strict-checkpoint]
```

`--feature` bắt buộc. Chọn đúng một `--task` hoặc `--all`; `--retry` và `--resume` loại trừ nhau, bắt buộc có `--task` và không dùng với `--all`.

Không truyền `--agent-execution`, `--project-ownership`, `--team-size`, `--dispatch-record`, `--dispatch-grant` hoặc `--dispatch-consumer`. `/add-execute` tự resolve persisted governance, preflight và cấp execution evidence nội bộ. Historical Dispatch Record là immutable evidence, không authorize execution mới.

## Chọn route tự động

| Persisted route | Khi `/add-execute` có thể chạy | Gate vẫn giữ |
| :--- | :--- | :--- |
| `direct` | Luôn dùng session hiện tại sau preflight hợp lệ. | Shadow Plan, Execution/Action Record, profile, checkpoint, exact command, validation và integration. |
| `orchestrated` | Chỉ khi runtime Claude Code `Agent` capability đã observed. | Toàn bộ gate của direct, thêm immutable worker packet, observed runtime evidence và integration validation. |

Runtime worker unavailable với `orchestrated` là `BLOCKED`; không fallback sang `direct`. `Project Ownership` không chọn route.

## Preconditions và selection

`/add-execute` đọc AI Review Protocol, Architecture Profile Protocol, `AGENTS.md`, `CONSTITUTION.md`, constraints, `.sdd/mcp-config.yaml`, `.sdd/shared_context.md`, feature artifact/reviews và handoff state.

Trước execution, `TASKS.md` phải có `Human Final Review: APPROVED`. Mỗi task cần marker/dependency hợp lệ, approved intent/file boundary/profile binding/exact command/checkpoint, frozen-contract owner/version và authorized shared-contract handling.

- `--task` chỉ preflight task chỉ định.
- `--all` tạo snapshot task chưa complete và eligible theo thứ tự khai báo trong `TASKS.md`; preflight toàn snapshot trước grant, worker hoặc action.
- `--all` dừng ngay tại blocker, Human gate, drift, sequential failure hoặc cancellation evidence; không thêm task mới eligible sau snapshot.
- `parallel-owned` chỉ dành cho task non-overlapping, không dependency và không shared-contract mutation. Shared work, retry, integration và dependency handoff luôn tuần tự.

Missing evidence, drift, overlap, unapproved command, scope expansion, package/config change, policy violation hoặc material decision mới là `BLOCKED`.

## Execution Record và grant lifecycle

`/add-execute` append `Execution Record` dưới `## Current Handoff State` trong `TASKS.md`. Record giữ ownership/execution resolution, ordered selection, classification, immutable inputs, runtime/claim evidence, integration state và one append-only task execution grant per task attempt.

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

Chỉ matching grant `DISPATCHED`/`UNCONSUMED` được bắt đầu. `/add-execute` cấp opaque consumer reference, đối chiếu task/feature/route/immutable input/consumer rồi persist `RUNNING`/`CONSUMED` **trước** Shadow Plan, command, edit hoặc action. Consumed, missing, cross-feature, cross-task, cross-record, stale consumer hoặc stale claim là `BLOCKED`; không reset/reuse grant.

Markdown grant và consumer reference là cooperative evidence, không atomic lock giữa session. Host-level replay prevention chỉ được claim khi observed host-controlled atomic claim bind feature/task/grant/route/consumer. Khi claim không tồn tại, ghi runtime enforcement `UNVERIFIED`.

## Immutable worker packet

Với `orchestrated` route và observed runtime capability, `/add-execute` cung cấp cho từng worker packet immutable:

```text
EXECUTION ID: <id>
FEATURE: <feature-slug>
TASK ID: <T00X>
EXECUTION GRANT ID: <grant-id>
GRANT ATTEMPT: <n>
GRANT STATE: DISPATCHED
CONSUMPTION STATE: UNCONSUMED
CONSUMER: <execution-issued opaque consumer reference>
TASK: <ID, title, Intent/DoD and REQ references>
OWNED FILE BOUNDARY: <exact paths only>
FROZEN CONTRACT: <ID/version/owner or N/A>
PROFILE EVIDENCE: <approved binding/version>
ALLOWED COMMANDS: <exact approved commands only>
STATE-CHANGE CATEGORY: <none/categories>
CHECKPOINT: <review reference or N/A>
AUDIT EVIDENCE REFERENCE: <Execution Record/review/action evidence>
HOST EXECUTION-CLAIM EVIDENCE: <matching claim or UNVERIFIED>
PROHIBITIONS: no out-of-boundary edits, package/config/contract changes, self-approval, commit or push.
STOP CONDITIONS: drift, scope conflict, missing command/checkpoint, policy/security issue, retry ineligibility.
```

Worker đối chiếu packet với Execution Record trước consumption và trả changed paths, Action-Record-compatible evidence, command/result, requirement coverage, consumer/consumption evidence, blocker và sync-back decision. Coordinator xác minh boundary, contract compatibility, validation và integration trước completion.

## Retry, resume và delivery

`--retry` chỉ dùng cho named `RETRY_PENDING` implementation defect khi task boundary, frozen contract, profile binding, exact command và checkpoint không đổi. `/add-execute` retire grant consumed và cấp attempt mới; không reuse/reset grant cũ.

`--resume` chỉ dùng cho named interrupted `RUNNING`, resolved `BLOCKED` hoặc Human-dispositioned `ESCALATED` task sau revalidation và close/retire stale evidence. Resume không phải retry. Gap về Spec/profile/command/checkpoint/contract/ownership/security/policy/dependency/runtime là `BLOCKED`, không retryable. Sau 5 consecutive failures, giữ `[/]`, set `ESCALATED`, persist execution review report và yêu cầu Human disposition.

Integration và shared work luôn tuần tự. Sau delivery, chạy exact approved command; route lint/audit/trace/sync theo trigger và tạo post-code review khi cần. Delivery flow theo `Project Ownership`; Agent không `git push` trong mọi route.

## Handoff

`/sdd-handoff` lưu execution state/evidence/next operation. `/sdd-resume` revalidate context trước khi gợi ý public `/add-execute` command. Không giả định worker identity, task mirror, permission hoặc grant của session cũ vẫn hợp lệ.
