---
name: sdd-sync
description: Tự động đồng bộ Master Feature Registry (.sdd/README.md) và Shared API Contracts (.sdd/shared_context.md)
user-invocable: true
---

# Skill: SDD Registry Sync (`/sdd-sync`)

Sử dụng skill này để quét và tự động cập nhật Master Feature Registry (`.sdd/README.md`) cũng như Shared API/State Contracts (`.sdd/shared_context.md`) sau khi các feature thay đổi.

## Tham số
- Không yêu cầu tham số bắt buộc.

## Quy trình Thực hiện (3 Bước)

1. **Quét Danh mục Feature trong `.sdd/features/`**:
   - Quét tất cả thư mục feature trong `.sdd/features/`.
   - Đọc header của từng `SPEC.md` để lấy thông tin: Status (`DRAFT` / `APPROVED & LOCKED`), SemVer Version, Số lượng `REQ-XXX`.

2. **Cập nhật Master Feature Registry (`.sdd/README.md`)**:
   - Tự động dựng bảng danh mục toàn bộ features kèm đường dẫn, phiên bản hiện tại và trạng thái.

3. **Tổng hợp Shared Contracts (`.sdd/shared_context.md`)**:
   - Trích xuất các DTOs, API Endpoints, Event Schemas và State Definitions dùng chung giữa các feature.
   - Cập nhật vào `.sdd/shared_context.md` để các feature khác tham chiếu mà không gây đứt gãy hợp đồng tích hợp.
