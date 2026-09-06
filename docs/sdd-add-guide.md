# Hướng dẫn vận hành SDD + ADD

Dùng trang này để hiểu artifact, ownership và gate. Khi cần thao tác tuần tự, đọc [Bắt đầu nhanh](./sdd-add-quickstart.md). Command contract nằm trong `.claude/skills/`.

## Ownership và execution

`.sdd/shared_context.md` tách `Project Ownership` khỏi `Agent Execution`. `solo` là một Human project owner; `team` là nhiều Human collaborator. `direct` chạy task trong Agent hiện tại; `orchestrated` cho phép dispatcher dùng worker. Hai trục không suy ra nhau. Direct execution vẫn giữ toàn bộ gate; ownership chỉ quyết định review eligibility và delivery policy.

## Vai trò

| Vai trò | Quyền và trách nhiệm |
| :--- | :--- |
| Human reviewer có thẩm quyền | Theo `Project Ownership`: sole owner của `solo` hoặc collaborator được ủy quyền của `team`; quyết định business/risk và ghi durable approval. |
| Tech Lead | Review architecture, điều phối integration/shared contract khi repository giao thẩm quyền. |
| Agent | Đề xuất, thực thi scope hợp lệ, ghi evidence; không self-approve/push/deploy. |
| Tester | Cung cấp verification evidence trong test boundary được giao. |

## Artifact và gate

| Artifact | Mục đích | Điều kiện đi tiếp |
| :--- | :--- | :--- |
| `CONTEXT.md` | Intent, glossary, constraints, Describe-back, question disposition | Human `APPROVED` trước Spec |
| `SPEC.md` | EARS, acceptance, errors, NFR, Feature Lock | `APPROVED & LOCKED` trước technical work |
| `PLAN.md` | REQ mapping, data flow, state/contract impact, consistency | Human `APPROVED` trước Tasks |
| `TASKS.md` | Atomic work, owner, command, checkpoint, sizing, review trigger | Human `APPROVED` trước execute |
| `Action Record` | Execution/validation/sync evidence | Đủ evidence trước complete |
| Post-code review | Review delivery có source/test/contract/config/state impact | Human `APPROVED` trước Git `READY` |

`REVISE`, `REJECTED`, missing exact command, contract drift, missing checkpoint và stale review đều block affected action.

## Methodology và quality

`Methodology Profile` chọn `SKIP | SKETCH | DETAILED | FORMAL` theo risk/complexity. Đây là sizing recommendation, không bypass review/gate. Spec luôn xử lý ambiguity bằng Clarification-First; pre-mortem và domain walkthrough biến finding thành clarified rule, approved assumption, deferred item hoặc blocking decision.

## Architecture Profile

Thứ tự chọn binding:

```text
approved profile → clear repository evidence → explicit input → core-only baseline
```

Context/Spec có thể business-neutral. Plan, Tasks và execution dừng khi behavior cần binding/exact command chưa `APPROVED`. Methodology Profile không chọn technology thay Profile.

## Review semantics

Artifact và review report dùng canonical block trong `.claude/skills/_shared/ai-review-protocol.md`. `APPROVED` cần decision, reviewer, timestamp và follow-up. Solo owner duy nhất có thể persist review; team dùng Human collaborator được ủy quyền. Template không xác thực identity/membership thay host. Thay đổi intent, requirement, file boundary, exact command, checkpoint category hoặc shared-contract decision làm approval cũ mất hiệu lực.

Dùng `/sdd-review` để ghi decision. Post-code report nằm tại `.sdd/reviews/post-code-<feature>-<delivery-or-timestamp>.md`; docs-only không cần report này.

## Delivery evidence

Action Record phải liên kết scope, profile/exact command, checkpoint, changed/result, validation route, post-code review, blocker và sync-back. `/sdd-trace --diff` áp dụng khi requirement/code/test đổi. `/sdd-sync` áp dụng khi shared state/contract đổi. `/git-validate` chỉ `READY` khi gate applicable pass.

## Safety boundary

- Requirement thiếu: update/review Spec trước code.
- Material state change cần persisted checkpoint trước action.
- `self-heal.sh` chỉ chạy một exact approved command (`--max-attempts=1`) để thu thập evidence; không repair/retry.
- `.sdd/mcp-config.yaml` là policy, không chứng minh runtime enforcement.

## Reference

- [Tra cứu nhanh](./sdd-add-field-guide.md): tình huống → action.
- [Sổ tay tình huống](./sdd-add-scenario-playbook.md): recovery, handoff và delivery.
- [Hướng dẫn Hồ sơ kiến trúc](./architecture-profile-guide.md): binding/command.
- [Hướng dẫn điều phối nhiều Agent](./multi-agent-orchestration-guide.md): ownership/dispatch.
