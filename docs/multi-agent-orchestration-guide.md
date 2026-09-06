# Hướng dẫn Agent execution và orchestration

Dùng tài liệu này khi chọn route thực thi. `Project Ownership` và `Agent Execution` là hai trục độc lập trong `.sdd/shared_context.md`.

- `Project Ownership: solo`: một Human project owner; họ vẫn có thể orchestrate nhiều Agent.
- `Project Ownership: team`: nhiều Human collaborator; họ vẫn có thể direct execution.
- `Agent Execution: direct`: Agent hiện tại thực thi task qua `/add-execute` với Dispatch Record và task execution grant hợp lệ.
- `Agent Execution: orchestrated`: `/sdd-dispatch` điều phối một hoặc nhiều worker với feature- và task-bound grant.

```text
/sdd-dispatch --feature=<slug> [--batch=<batch-id>] [--task=<T001,T002>] \
  [--project-ownership=solo|team] [--agent-execution=direct|orchestrated] [--retry] [--resume]
```

`--team-size=solo|team` là composite alias deprecated trong một transition release: `solo` map thành `solo/direct`, `team` map thành `team/orchestrated`. Alias không biểu diễn được solo/orchestrated hoặc team/direct, phải báo migration warning và không tự rewrite shared context. Alias chỉ hợp lệ khi cả hai canonical header vắng mặt; có một canonical header cùng `--team-size` là `BLOCKED`. Khi canonical headers vắng mặt, chỉ một legacy source hợp lệ được dùng: header `# Collaboration Mode` hoặc alias `--team-size`; duplicate, malformed hoặc coexist là `BLOCKED`.

## Chọn route

| Route | Dùng khi | Gate vẫn giữ |
| :--- | :--- | :--- |
| `direct` | Một task atomic cần Agent hiện tại thực thi. | Shadow Plan, Action Record, profile, checkpoint, exact command, validation; matching `DISPATCHED`/`UNCONSUMED` grant được consume trước action. |
| `orchestrated` | Một hoặc nhiều task độc lập có boundary rõ; parallel chỉ khi không overlap. | Toàn bộ gate của direct, thêm immutable packet, Dispatch Record, feature/task grant, runtime evidence và integration validation. |

Direct không phải bypass. Orchestrated dùng được cho solo owner và team.

## Điều kiện orchestration

Chỉ dispatch khi Spec lock, Plan/Tasks approved, dependency complete, mỗi worker có file boundary độc quyền và exact command/checkpoint rõ. Shared file/contract, overlap, missing evidence hoặc decision mới phải tuần tự hoặc `BLOCKED`.

## Human ownership và Agent roles

| Vai trò | Trách nhiệm |
| :--- | :--- |
| Human project owner/collaborator | Business/risk decision, durable approval và delivery theo ownership mode; team collaborator cần được project ủy quyền để persist review. |
| Contract owner | Shared-contract mutation và compatibility decision. |
| Dispatcher/Lead Agent | Dispatch, integration và ownership arbitration trong orchestrated execution. |
| Worker Agent | Một task atomic trong boundary được giao. |
| Tester Agent | Verification evidence trong test boundary. |

Solo owner duy nhất có thể persist Human Final Review. Trong team, một Human collaborator được ủy quyền persist review. Agent không self-approve; template không tự xác thực human identity/membership.

## Packet và batch

Mỗi worker packet cần:

```text
- feature
- task_id
- dispatch_grant_id
- grant_attempt
- grant_state=DISPATCHED
- consumption_state=UNCONSUMED
- consumer=<dispatcher-issued opaque consumer reference; must match Dispatch Record and --dispatch-consumer>
- frozen_contract_version
- ownership_and_file_boundary
- selected_profile_bindings
- exact_approved_commands
- allowed_action_and_checkpoint
- audit_evidence_reference
```

| Batch type | Dùng khi |
| :--- | :--- |
| `single-owned` | Một task độc lập. |
| `parallel-owned` | Boundary độc quyền, không dependency/overlap/shared mutation. |
| `sequential-handoff` | Dependency, shared file/contract, retry hoặc integration. |
| `blocked` | Thiếu evidence hoặc scope không tương thích. |

Material/cross-contract batch cần persisted Human Final Review trước mutation.

## Lifecycle

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

Dispatcher ghi Dispatch Record chứa `Project ownership`, `Agent execution`, feature và one task execution grant per selected task. Dispatcher cấp opaque consumer reference trước handoff; `/add-execute` match reference trước consumption. Markdown grant là cooperative evidence, không tự serialize concurrent session hay host-enforce replay prevention khi runtime enforcement là `UNVERIFIED`; opaque reference không chứng minh host đã ngăn replay. Nếu host có execution claim observed, claim phải bind feature/task/grant/route/consumer; stale hoặc mismatch là `BLOCKED`. Chỉ matching grant `DISPATCHED`/`UNCONSUMED` được bắt đầu; `/add-execute` consume thành `RUNNING`/`CONSUMED` trước Shadow Plan hoặc action trong cả `direct` và `orchestrated`. Retry retire grant consumed và dispatcher issue grant mới sau immutable retry check. Worker trả changed paths, Action-Record-compatible evidence, command/result, requirement coverage, consumer/consumption evidence, blocker và sync-back. Task chỉ `[x]` khi evidence/checkpoint/sync-back đạt.

## Runtime, retry và delivery

Chỉ dùng Claude Code `Agent` khi tool quan sát được. `.sdd/mcp-config.yaml` là policy specification; it `does not prove host enforcement`. Runtime identity/enforcement chỉ `VERIFIED` với observed host evidence; nếu không là `UNVERIFIED`.

`--retry` chỉ cho `RETRY_PENDING` implementation defect trong immutable boundary/contract/profile/command/checkpoint. Gap về Spec/profile/command/checkpoint/contract/ownership/security/policy/runtime là `BLOCKED`. Sau maximum 5 lỗi liên tiếp: `ESCALATED`, cần Human disposition.

Integration và shared work luôn tuần tự. Sau delivery dùng exact command, lint/audit/trace/sync theo trigger và post-code review khi cần. Delivery flow theo `Project Ownership`: solo dùng Human-owned direct delivery, team dùng PR/review. Agent không `git push` trong mọi route.

## Handoff

`/sdd-handoff` lưu execution state/evidence/next operation, gồm active task grant và consumption evidence. `/sdd-resume` revalidate grant trước `--resume`; consumed hoặc non-eligible grant không được route trực tiếp qua `/add-execute`. Không giả định worker identity, task mirror hoặc permission cũ còn tồn tại.
