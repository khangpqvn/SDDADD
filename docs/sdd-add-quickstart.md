# SDD + ADD Quickstart
# Version: 1.1.0

Điểm vào cho Starter Template SDD + ADD.

## Mental model

```text
Human quyết định WHAT, WHY, boundaries và risk
Agent đề xuất HOW, thực thi trong scope đã duyệt, rồi ghi evidence
```

Agent không tự approve, không suy approval từ chat, không `git push`, không deploy, và không tự quyết material state change.

## Lifecycle

```text
CONTEXT → SPEC → PLAN → TASKS → execute → verify → sync
```

| Artifact | Contract chính |
| :--- | :--- |
| `CONTEXT.md` | Intent Packet: WHAT, WHY, Definition of Done, boundaries, exclusions, decision owner. |
| `SPEC.md` | EARS requirements, Methodology Profile, Feature Lock, acceptance và out-of-scope. |
| `PLAN.md` | `REQ-XXX` mapping, data flow, profile evidence, state-change và consistency impact. |
| `TASKS.md` | Atomic task, ownership, file boundary, exact command, checkpoint và sync-back. |

`Feature Lock` chỉ khóa behavior/contract của feature hoặc sprint. Nó không khóa công việc không liên quan trong project. Dùng `/sdd-update` để thay đổi artifact đã approved.

## Hai gate trước technical execution

1. `SPEC.md` phải `APPROVED & LOCKED`.
2. `.sdd/architecture-profile.md` phải có binding liên quan và exact verification command đã `APPROVED`.

Context và Spec có thể technology-neutral. Plan, Tasks và execution dừng nếu cần framework, database, ORM/query layer, validation hoặc command chưa được chọn/evidenced.

## First feature

```text
/sdd-init --project-name="my-project"
/sdd-context --feature=feat-user-register
/sdd-review --feature=feat-user-register --artifact=context --status=APPROVED \
  --decision="Intent is ready for specification." --reviewer="<human reviewer>" \
  --follow-up="/sdd-spec --feature=feat-user-register"
/sdd-spec --feature=feat-user-register
```

Sau khi review/lock Spec và approve Architecture Profile:

```text
/sdd-plan --feature=feat-user-register
/sdd-tasks --feature=feat-user-register
/sdd-dispatch --feature=feat-user-register # team mode; /add-execute remains atomic worker execution
/sdd-lint --feature=feat-user-register
/sdd-audit --feature=feat-user-register
/sdd-trace --feature=feat-user-register
/sdd-sync --feature=feat-user-register --reason="feature delivery"
```

## Checkpoint theo rủi ro

Mỗi task có Shadow Plan và Action Record. Checkpoint Human persisted chỉ bắt buộc trước:

- shared/public contract;
- persistence schema hoặc business-data mutation;
- permission, security, dependency hoặc runtime configuration;
- external hoặc irreversible side effect.

Low-risk/read-only task vẫn cần evidence nhưng không cần checkpoint mặc định. Project có thể chọn `/add-execute --strict-checkpoint` để yêu cầu checkpoint cho mọi task.

## Khi test fail

| Cause | Action |
| :--- | :--- |
| Code trái Spec rõ ràng | Sửa trong approved task scope, rồi chạy lại exact command. |
| Requirement hoặc edge case chưa nằm trong Spec | Dừng; `/sdd-update --artifact=spec`, review và lock lại. |
| Binding hoặc command thiếu/sai | Dừng; cập nhật/review Architecture Profile. |
| Material/high-risk mutation | Dừng; lấy checkpoint persisted trước action. |

## Solo mode

```text
/sdd-init --project-name="my-project" --team-size=solo
```

Solo chỉ giảm Pull Request overhead. Human Developer vẫn review durable decision và tự chạy:

```bash
git push -u origin <head>
```

Agent có thể validate hoặc commit khi Human yêu cầu, nhưng không push.

## Self-heal: evidence-only

`self-heal.sh` không sửa source. Nó chỉ chạy exact approved command được ghi trong Architecture Profile và task có Human Final Review `APPROVED`, rồi ghi evidence cho `implementation-defect` đã được scope:

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

Script block Spec gap, profile gap, contract, schema/data, security/config và external/irreversible scope. `--max-attempts=1` xác nhận script chỉ chạy command đúng một lần; script không thực hiện automated repair.

## Đọc tiếp

- [Hướng dẫn vận hành đầy đủ](./sdd-add-guide.md)
- [Field guide](./sdd-add-field-guide.md)
- [Scenario playbook](./sdd-add-scenario-playbook.md)
- [Architecture Profile guide](./architecture-profile-guide.md)
- [Multi-Agent guide](./multi-agent-orchestration-guide.md)
