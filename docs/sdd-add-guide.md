# Hướng dẫn vận hành SDD + ADD
# Version: 7.2.0

Tài liệu này giải thích toàn bộ quy trình cho Product Owner, Human Director, Tech Lead, Developer, QA và AI Agent. `.claude/skills/` giữ command contract; trang này giúp biết **khi nào** dùng command, cần chuẩn bị gì và khi nào phải dừng.

## 1. Mô hình vận hành

SDD quản lý intent, requirement, contract, risk, traceability và validation. ADD cho Agent thực thi trong boundary đã approved.

```text
CONTEXT → SPEC → PLAN → TASKS → execute → verify → sync
```

Human sở hữu business decision, risk acceptance và Human Final Review. Agent đề xuất, thực thi trong scope hợp lệ rồi ghi evidence. Chat acknowledgement không phải durable approval.

Agent không tự approve, không bypass quality gate, không suy đoán stack/command, không commit nếu chưa có Human request, và không `git push` hoặc deploy.

## 2. Bốn artifact của một feature

| Artifact | Nội dung bắt buộc | Gate để đi tiếp |
| :--- | :--- | :--- |
| `CONTEXT.md` | Intent Packet, Methodology Profile, glossary, constraints, question disposition | Human review trước Spec |
| `SPEC.md` | EARS, BDD/acceptance, errors, out-of-scope, SemVer, Feature Lock | `APPROVED & LOCKED` trước technical execution |
| `PLAN.md` | `REQ-XXX` mapping, data flow, risk, profile evidence, consistency map | Human review trước Tasks |
| `TASKS.md` | Atomic task, owner, file boundary, command, checkpoint, sync-back | Human review trước execute |

### Intent Packet: bắt đầu bằng kết quả cần đạt

```markdown
## Intent Packet
- WHAT: <observable outcome>
- WHY: <problem or value>
- Definition of Done: <verifiable conditions>
- Boundaries: <included behavior>
- Exclusions: <deferred behavior>
- Decision owner: <human role>
```

Intent phải technology-neutral. Mỗi câu hỏi trọng yếu phải được ghi là `resolved`, `approved assumption`, `deferred` hoặc `blocking decision`; nếu không, Context chưa được sang Spec.

### Methodology Profile: chọn độ sâu phù hợp rủi ro

```markdown
## Methodology Profile
- Depth: Sketch | Detailed | Formal
- Rationale: <risk and complexity>
- Risk posture: low | elevated | high
- High-risk review route: <durable route or N/A>
- Unresolved-decision owner: <human role>
```

High-risk review route bắt buộc cho dữ liệu nhạy cảm, tài chính/business-critical behavior, destructive/irreversible work, compliance, authorization, cross-system consistency và public/external contracts. Profile này chỉ điều chỉnh độ sâu review; không chọn công nghệ và không thay Architecture Profile evidence.

### Feature Lock: giữ phạm vi ổn định

Feature Lock khóa behavior và contract của feature/sprint hiện tại, không khóa các việc không liên quan. Mọi thay đổi dùng `/sdd-update`, làm invalid review bị ảnh hưởng và cần durable review mới.

## 3. Gate Hồ sơ kiến trúc

`.sdd/architecture-profile.md` được ưu tiên theo thứ tự:

```text
approved profile → clear repository evidence → explicit input → core-only baseline
```

Context/Spec có thể core-only và business-neutral. Plan, Tasks và execution phải dừng khi thiếu binding liên quan hoặc exact command. Không thay command thiếu bằng `npm`, `pnpm`, `yarn` hoặc placeholder.

**Người mới:** Trước Plan, mở profile và kiểm tra mỗi behavior kỹ thuật đã có evidence, `APPROVED` binding và command chạy được chưa. Xem [Hướng dẫn Hồ sơ kiến trúc](./architecture-profile-guide.md).

## 4. Human Final Review

Artifact dùng canonical block từ `.claude/skills/_shared/ai-review-protocol.md`. `APPROVED` cần decision, reviewer, timestamp và follow-up. `REVISE` và `REJECTED` block downstream work. Artifact đổi sau approval thì approval cũ không còn hiệu lực.

Dùng `/sdd-review` thay vì tự sửa status khi command hỗ trợ target. Architecture Profile là review target hợp lệ, nhưng review không thể hợp thức hóa binding hoặc command còn thiếu.

## 5. Thiết kế Plan và Tasks

Plan liên kết mọi implementation/data flow với `REQ-XXX`, phân loại state change, nêu shared-contract impact và owner của trace/sync.

Mỗi task phải có:

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

Task không được âm thầm nhận thêm phần nằm trong Feature Lock exclusions.

## 6. Thực thi và bằng chứng

Mỗi task bắt đầu bằng Shadow Plan: Intent/DoD, scope/file boundary, profile version/binding/evidence, exact command, state-change category, checkpoint, contract/version, risk và sync-back decision.

### Thay đổi trạng thái trọng yếu

Cần persisted Human checkpoint **trước action** cho:

- shared/public contract;
- persistence schema hoặc business-data mutation;
- permission, security, dependency hoặc runtime configuration;
- external hoặc irreversible side effect.

Task read-only/low-risk vẫn cần Shadow Plan và Action Record, nhưng baseline không bắt checkpoint. `/add-execute --strict-checkpoint` là opt-in để yêu cầu checkpoint cho mọi task.

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

Task chỉ complete khi checkpoint, verification và sync-back evidence áp dụng đều tồn tại.

## 7. Khi thất bại: phân loại trước khi sửa

| Classification | Action bắt buộc |
| :--- | :--- |
| Implementation defect | Chỉ repair trong approved task/file boundary; chạy lại exact command. |
| Spec gap | Dừng, `/sdd-update --artifact=spec`, review/lock, rồi update downstream work. |
| Profile/configuration gap | Dừng, update/review profile; không suy ra adapter hoặc command. |
| Prohibited/high-risk mutation | Dừng; lấy Human checkpoint và route cần thiết. |

Dùng `/sdd-trace --feature=<slug> --diff` khi requirement/code/test đổi. Dùng `/sdd-sync --feature=<slug> --reason="..."` khi shared contract hoặc state đổi.

## 8. Shared contract và nhiều Agent

`.sdd/shared_context.md` giữ frozen record: ID/version/status, producer, consumers, owner, compatibility, linked requirements/tasks/evidence, last sync và unresolved decision.

Chỉ contract owner hoặc Lead được mutate shared contract. Mỗi dispatch phải có task ID, frozen contract version, ownership/file boundary, selected profile binding, exact command, allowed action/checkpoint và audit evidence. Contract drift hoặc ownership overlap block công việc bị ảnh hưởng.

`.sdd/mcp-config.yaml` là dispatch/audit policy specification; runtime host enforcement phải được cấu hình riêng. Team dùng `/sdd-dispatch --feature=<slug>` để tạo Dispatch Record và gọi Claude Code `Agent` worker đang quan sát được; `/add-execute` vẫn là atomic worker procedure. Material/cross-contract batch cần batch-specific persisted Human approval.

## 9. Handoff và resume

`/sdd-handoff` ghi Intent/DoD, active contract version, approved boundary, checkpoint, exact command/result, blocker và next decision vào `Current Handoff State` cùng Action Record.

`/sdd-resume` chỉ đề xuất execution khi review, profile, command, contract ownership và checkpoint bắt buộc hợp lệ. Legacy high-risk feature cần Human disposition thay vì automatic invalidation.

## 10. Self-heal

`self-heal.sh` là opt-in evidence collection, không phải automated repair:

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

Script từ chối unapproved/malformed command và mọi non-implementation scope. Nó không sửa source, self-approve, commit, push, deploy hoặc tuyên bố `claude --print` đã repair.

## 11. Delivery

1. Verify exact command output, Action Records, audit, trace và sync evidence.
2. `/git-validate --scope=commit` phải trả `READY`.
3. Agent chỉ commit khi Human yêu cầu.
4. Human chạy `git push -u origin <head>`.
5. Team flow chạy `/git-validate --scope=pr --strict`; Agent chỉ tạo PR khi remote branch tồn tại và Human xác nhận outward-facing content. Solo bỏ PR overhead.

## 12. Checklist hoàn thành

- [ ] Intent, Methodology Profile và Feature Lock khớp delivered scope.
- [ ] Artifact/review bắt buộc còn hợp lệ.
- [ ] Profile có approved binding và exact command liên quan.
- [ ] Mỗi task complete có verification, Action Record, checkpoint/sync-back bắt buộc.
- [ ] Trace không có consistency bị vỡ.
- [ ] Shared contract owner/version/compatibility đã sync khi áp dụng.
- [ ] Git validation là `READY`.
