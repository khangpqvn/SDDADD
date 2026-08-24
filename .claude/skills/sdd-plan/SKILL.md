---
name: sdd-plan
description: Pha 2 SDD — tạo PLAN.md theo Clean Architecture, Architecture Profile, data flow và risk
user-invocable: true
---

# SDD Phase 2 — Architecture Planning (`/sdd-plan`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `PENDING`, `APPROVED`), file paths, and CLI commands are language-invariant.

Dùng `SPEC.md` và `CONSTITUTION.md` để tạo `.sdd/features/{feature-slug}/PLAN.md`.

## Tham số

- `--feature=<feature-slug>`: Feature identifier.

## Architecture Profile gate (BLOCKING)

Tuân thủ [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md).

1. Đọc profile, governance và repository evidence.
2. Chỉ dùng layout đã chọn: `domain/` → `usecase/` → `interface/` / `infra/` adapter.
3. Feature cần HTTP, persistence, validation, cache, async messaging hoặc runnable test/build command chưa `APPROVED` thì dừng; không sinh Plan adapter-specific.
4. Lưu `PENDING HUMAN REVIEW` recommendation nêu binding thiếu, evidence và exact follow-up.
5. Profile/evidence mâu thuẫn thì Human Director phải quyết định trước Plan.

## Các bước

1. Ghi Architecture Profile Reference, binding, evidence và command đã verified.
2. Xác định component, ownership và file path theo Clean Architecture.
3. Vẽ data flow: Client → approved interface adapter → usecase → port → approved infra adapter → store/service.
4. Đánh giá risk về security, concurrency, performance, migration và rollback.
5. Ghi **Questions for Human Director** — xem mục bên dưới.
6. Kiểm tra DoD và tạo recommendation.

## Questions for Human Director — bắt buộc trong PLAN.md

`PLAN.md` phải có section `## Questions for Human Director` liệt kê những điểm Spec còn mơ hồ mà planning phát hiện. Đây là giá trị cốt lõi của pha Plan: AI đọc Spec và báo cáo những gì nó phải assume để lập plan.

**Format từng câu hỏi:**

```markdown
### Q1: <Tên vấn đề ngắn gọn>
- **Điều chưa rõ**: <Spec nói gì (hoặc không nói gì) khiến plan phải assume>
- **Assumption hiện tại**: <Nếu không được clarify, plan sẽ dùng assumption này>
- **Ảnh hưởng nếu assumption sai**: <Component hoặc behavior nào bị thay đổi>
- **Câu hỏi cụ thể**: <Câu hỏi Yes/No hoặc cần giá trị cụ thể>
```

**Ví dụ:**

```markdown
### Q1: AggregateUpdateJob — queue mechanism
- Điều chưa rõ: Spec §3 chỉ nói "cập nhật trong 5 phút" nhưng không chỉ định queue/scheduler.
- Assumption hiện tại: Dùng in-process setTimeout (đơn giản nhất).
- Ảnh hưởng nếu sai: Phải đổi toàn bộ infra adapter và thêm Kafka/Redis binding.
- Câu hỏi: Dùng queue nào? Celery, Kafka, BullMQ hay in-process?
```

Nếu sau khi đọc Spec kỹ AI không có câu hỏi nào, phải **chủ động hỏi lại**: "Tôi đã assume những điều sau — chúng có đúng không?" rồi liệt kê assumption. Không có câu hỏi không có nghĩa Spec hoàn hảo; thường có nghĩa assumption ẩn chưa được surface.

## PLAN.md phải có

- **Architectural Approach** — pattern, design pattern, lý do chọn
- **Components** — tên, trách nhiệm, interface, file path theo layer
- **Data Flow** — user input → processing → storage → response
- **Dependencies** — thứ tự implement, external dep
- **Risks & Mitigations** — ít nhất 3 rủi ro kỹ thuật với mitigation
- **Questions for Human Director** — xem trên

## DoD

- [ ] Boundary và dependency direction rõ ràng.
- [ ] Component có trách nhiệm, layer và path cụ thể.
- [ ] Data flow chỉ dùng approved adapter.
- [ ] Có ít nhất ba risk và mitigation.
- [ ] Section "Questions for Human Director" có ít nhất 1 câu hỏi hoặc ghi rõ "Không có câu hỏi mở — assumption: [danh sách]".
- [ ] Technical question/assumption được nêu hoặc đã approved.

## AI Recommendation và Human Final Review

Sau khi tạo/sửa `PLAN.md`, lưu canonical recommendation gồm architecture option, dependency direction, risk, mitigation, decision kỹ thuật mở và requirement bị ảnh hưởng. Human review giữ `PENDING`; task decomposition/execution cần `APPROVED`. Agent phải dừng, không self-approve.
