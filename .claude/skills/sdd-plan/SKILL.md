---
name: sdd-plan
description: Pha 2 SDD — tạo PLAN.md theo Clean Architecture, Architecture Profile, data flow và risk
user-invocable: true
---

# SDD Phase 2 — Architecture Planning (`/sdd-plan`)

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
5. Nêu Questions for Human Director, kiểm tra DoD và tạo recommendation.

## DoD

- [ ] Boundary và dependency direction rõ ràng.
- [ ] Component có trách nhiệm, layer và path cụ thể.
- [ ] Data flow chỉ dùng approved adapter.
- [ ] Có ít nhất ba risk và mitigation.
- [ ] Technical question/assumption được nêu hoặc đã approved.

## AI Recommendation và Human Final Review

Sau khi tạo/sửa `PLAN.md`, lưu canonical recommendation gồm architecture option, dependency direction, risk, mitigation, decision kỹ thuật mở và requirement bị ảnh hưởng. Human review giữ `PENDING`; task decomposition/execution cần `APPROVED`. Agent phải dừng, không self-approve.
