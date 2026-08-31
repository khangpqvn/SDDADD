# Bắt đầu nhanh SDD + ADD
# Version: 1.1.0

Đây là bài thực hành đầu tiên cho Starter Template SDD + ADD. Làm theo từng bước; dừng tại mọi điểm cần Human review. Command contract chi tiết nằm trong `.claude/skills/`.

## Trước khi bắt đầu

Bạn cần một repository Git và một feature slug, ví dụ `feat-user-register`. Chưa cần chọn framework hay database để viết Context/Spec.

```text
Human quyết định WHAT, WHY, boundaries và risk
Agent đề xuất HOW, thực thi trong scope đã duyệt, rồi ghi evidence
```

Agent không tự approve, không suy approval từ chat, không `git push`, không deploy, và không tự quyết material state change.

## Bản đồ hành trình

```text
CONTEXT → SPEC → PLAN → TASKS → execute → verify → sync
```

| Artifact | Bạn ghi gì vào đó? | Khi nào dừng? |
| :--- | :--- | :--- |
| `CONTEXT.md` | Intent Packet: WHAT, WHY, Definition of Done, boundaries, exclusions, decision owner. | Gửi Human review trước Spec. |
| `SPEC.md` | EARS requirements, Methodology Profile, Feature Lock, acceptance và out-of-scope. | Cần `APPROVED & LOCKED` trước technical execution. |
| `PLAN.md` | `REQ-XXX` mapping, data flow, profile evidence, state-change và consistency impact. | Human review trước Tasks. |
| `TASKS.md` | Atomic task, ownership, file boundary, exact command, checkpoint và sync-back. | Human review trước execute. |

`Feature Lock` chỉ khóa behavior/contract của feature hoặc sprint đang làm. Muốn đổi artifact đã approved, dùng `/sdd-update` rồi review lại.

## Hai cổng bắt buộc trước technical execution

Trước khi tạo Plan/Tasks kỹ thuật hoặc chạy code, xác nhận cả hai:

1. `SPEC.md` là `APPROVED & LOCKED`.
2. `.sdd/architecture-profile.md` có binding liên quan và exact verification command đã `APPROVED`.

Context và Spec có thể technology-neutral. Nếu Plan/Tasks cần framework, database, ORM/query layer, validation hoặc command chưa được chọn/evidenced, dừng và xử lý Architecture Profile trước.

## Bài thực hành: feature đầu tiên

### Bước 1: Khởi tạo project và Context

```text
/sdd-init --project-name="my-project"
/sdd-context --feature=feat-user-register
```

Mở `CONTEXT.md` vừa tạo. Điền kết quả người dùng quan sát được, lý do, Definition of Done, phạm vi không làm và người chịu trách nhiệm quyết định.

**Dừng:** Yêu cầu Human review Context. Không chuyển sang Spec chỉ vì chat đã đồng ý.

### Bước 2: Viết Spec và khóa behavior

```text
/sdd-review --feature=feat-user-register --artifact=context --status=APPROVED \
  --decision="Intent is ready for specification." --reviewer="<human reviewer>" \
  --follow-up="/sdd-spec --feature=feat-user-register"
/sdd-spec --feature=feat-user-register
```

Ghi requirement bằng EARS, tiêu chí chấp nhận, lỗi cần xử lý và out-of-scope. Sau đó để Human review và lock Spec.

**Kết quả mong đợi:** Bạn biết chính xác behavior cần làm và điều gì chưa làm. Nếu có requirement mới, dùng `/sdd-update`; không vá code trước.

### Bước 3: Chọn kỹ thuật có evidence

Mở `.sdd/architecture-profile.md`. Ghi binding và exact command cho technical behavior của feature, rồi gửi Human review. Xem [Hướng dẫn Hồ sơ kiến trúc](./architecture-profile-guide.md) nếu chưa rõ evidence cần gì.

**Dừng:** Không có command/binding `APPROVED` thì không tạo Plan kỹ thuật.

### Bước 4: Lập Plan, review rồi mới tạo Tasks

```text
/sdd-plan --feature=feat-user-register
```

Gửi `PLAN.md` để Human review. Chỉ chạy bước tiếp theo sau khi Plan là `APPROVED`.

```text
/sdd-tasks --feature=feat-user-register
```

Gửi `TASKS.md` để Human review. Chỉ execution sau khi Tasks là `APPROVED`.

### Bước 5: Thực thi, xác minh và đồng bộ

Nếu làm một mình:

```text
/add-execute --feature=feat-user-register
```

Nếu làm theo team mode:

```text
/sdd-dispatch --feature=feat-user-register
```

Sau execution, chạy các command đã được Architecture Profile duyệt:

```text
/sdd-lint --feature=feat-user-register
/sdd-audit --feature=feat-user-register
/sdd-trace --feature=feat-user-register
/sdd-sync --feature=feat-user-register --reason="feature delivery"
```

Mỗi task cần Shadow Plan và Action Record. Nếu dispatch team, đọc [hướng dẫn điều phối](./multi-agent-orchestration-guide.md). Không gọi `/sdd-dispatch` khi `TASKS.md` chưa được review.

## Khi nào cần checkpoint trước action?

Human checkpoint được lưu bền vững bắt buộc trước:

- shared/public contract;
- persistence schema hoặc business-data mutation;
- permission, security, dependency hoặc runtime configuration;
- external hoặc irreversible side effect.

Task low-risk/read-only vẫn cần evidence, nhưng baseline không yêu cầu checkpoint. Dùng `/add-execute --strict-checkpoint` nếu dự án muốn checkpoint cho mọi task.

## Khi test hoặc CI thất bại

| Nguyên nhân | Làm gì ngay? |
| :--- | :--- |
| Code trái Spec rõ ràng | Sửa trong approved task scope, rồi chạy lại exact command. |
| Requirement/edge case chưa có trong Spec | Dừng; `/sdd-update --artifact=spec`, review và lock lại. |
| Binding hoặc command thiếu/sai | Dừng; cập nhật/review Architecture Profile. |
| Material/high-risk mutation | Dừng; lấy checkpoint persisted trước action. |

Không thêm test filter, skip hoặc mock chỉ để biến failure thành success.

## Solo mode

```text
/sdd-init --project-name="my-project" --team-size=solo
```

Solo chỉ giảm Pull Request overhead. Human Developer vẫn review durable decision. Sau validation và commit, Human tự chạy:

```bash
git push -u origin <head>
```

Agent có thể validate hoặc commit khi Human yêu cầu, nhưng không push.

## Self-heal: chỉ thu thập evidence

`self-heal.sh` không sửa source. Nó chỉ chạy exact approved command của task có Human Final Review `APPROVED`, rồi ghi evidence cho `implementation-defect` đã được scope:

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

Script block Spec gap, profile gap, contract, schema/data, security/config và external/irreversible scope. `--max-attempts=1` nghĩa là command chỉ chạy một lần; script không tự repair.

## Đọc tiếp

- [Hướng dẫn vận hành đầy đủ](./sdd-add-guide.md)
- [Tra cứu nhanh](./sdd-add-field-guide.md)
- [Sổ tay tình huống](./sdd-add-scenario-playbook.md)
- [Hướng dẫn Hồ sơ kiến trúc](./architecture-profile-guide.md)
- [Hướng dẫn điều phối nhiều Agent](./multi-agent-orchestration-guide.md)
