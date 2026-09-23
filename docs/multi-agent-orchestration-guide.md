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

## 8. Hai cách tổ chức nhiều Agent

| Kiểu | Cấu trúc | Phù hợp khi | Rủi ro chính |
| :--- | :--- | :--- | :--- |
| Vertical | Một coordinator giao việc cho worker, worker không nói chuyện với nhau | Task có dependency, cần integration một chỗ | Coordinator thành điểm nghẽn |
| Horizontal | Nhiều Agent ngang cấp làm phần độc lập | File boundary tách bạch, không shared contract mutation | Xung đột ghi và drift nếu boundary không rõ |

Route `orchestrated` trong template này là vertical: `/add-execute` giữ vai trò coordinator, tạo worker packet immutable và validate integration. Không có kênh worker-to-worker.

Điều kiện để chạy song song: task không overlap file, không dependency, không mutation shared contract. Việc dùng chung, retry, integration và dependency handoff luôn tuần tự.

## 9. Đồng bộ shared context

`.sdd/shared_context.md` là nơi duy nhất ghi state dùng chung. Quy tắc:

- Mỗi Agent chỉ ghi vào phần thuộc boundary của nó; không ghi chèn vào phần của Agent khác.
- Shared contract có owner và version. Worker nhận contract ở dạng frozen; muốn đổi thì dừng và để owner xử lý.
- Phát hiện lệch bằng `/sdd-trace`, hợp nhất lại bằng `/sdd-sync` sau khi owner đã quyết.
- Xung đột giữa hai Agent không được tự hòa giải bằng cách chọn một bên. Giữ evidence, đánh `BLOCKED`, đưa Human hoặc owner quyết định.

Markdown record không phải atomic lock giữa các session. Khi chưa quan sát được host-controlled claim, ghi `UNVERIFIED` thay vì coi là đã khóa.

## 10. Skill: định dạng và vòng đời

Mỗi slash command trong `.claude/skills/<name>/SKILL.md` là một contract đọc được bởi cả người và Agent. Một `SKILL.md` dùng được cần nêu rõ:

- khi nào skill được kích hoạt và khi nào không;
- input bắt buộc, input tùy chọn và input bị cấm;
- precondition phải đạt trước khi hành động;
- output và evidence để lại ở đâu;
- điều kiện dừng và trạng thái blocker.

Vòng đời một skill: đề xuất → viết contract → Human review → dùng → sửa khi contract đổi → retire khi không còn chủ. Skill bị retire phải được ghi trong changelog của `AGENTS.md` và loại khỏi `.claude/skills/`, để không ai còn gọi một command đã mất contract.

Trước khi tạo skill mới, kiểm tra skill hiện hữu đã phủ chưa. Thêm skill trùng chức năng làm tăng bề mặt cần bảo trì mà không thêm năng lực.

## 11. Hook và ranh giới tự sửa

Hook là điểm móc tự động quanh vòng thực thi: trước khi hành động, sau khi hành động, hoặc khi validation fail. Dùng hook cho kiểm tra dự đoán được và rủi ro thấp: format, lint, kiểm tra file bị cấm sửa, chạy test đã được duyệt.

Ranh giới của tự sửa trong template này rất hẹp:

- `scripts/self-heal.sh` chỉ chạy **một** exact approved command với `--max-attempts=1` để thu evidence cho `implementation-defect`.
- Script không sửa source, không repair, không retry, không self-approve, không commit, không push, không deploy.
- Vượt ngưỡng attempt của contract thì task phải `ESCALATED` và chờ Human disposition, không tự thử cách khác.
- Không hook nào được sửa governance file, tự ghi `APPROVED`, hay bỏ qua checkpoint.

Tự sửa vượt khỏi phạm vi dự đoán được là cách nhanh nhất tạo ra thay đổi không ai review.

## 12. Quyền tool cho từng Agent

`.sdd/mcp-config.yaml` khai báo policy truy cập tool và resource. Nguyên tắc vận hành:

- **Least privilege:** worker nhận đúng quyền cần cho boundary của nó, không nhận quyền của cả dự án.
- **Có thời hạn và ngân sách:** quyền nên hết hạn theo attempt và có giới hạn sử dụng, thay vì mở vô thời hạn.
- **Không cho mượn quyền:** một Agent không được nhờ Agent khác làm hộ việc mà quyền của nó không cho phép. Đây là cách vô hiệu hóa quyết định phân quyền của Human.
- **Evidence khi dùng tool rủi ro:** mỗi lần dùng phải để lại dấu trong Action Record để audit được.
- **Policy không phải enforcement:** `.sdd/mcp-config.yaml` là khai báo; nó không chứng minh host đang áp đặt giới hạn. Chưa có runtime evidence thì giữ `UNVERIFIED`.

Nguyên tắc chọn công cụ và ba mức riêng tư nằm trong [Hồ sơ kiến trúc](./architecture-profile-guide.md).

## Contract owner

Chi tiết preflight, transition, grant lifecycle và packet phải khớp `.claude/skills/add-execute/SKILL.md`. Tài liệu này chỉ giúp chọn route và nhận biết blocker; không thay thế skill contract.
