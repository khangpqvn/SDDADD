---
name: sdd-rfc
description: Quản lý quy trình đề xuất (RFC) để sửa đổi Hiến pháp dự án (CONSTITUTION.md) hoặc thay đổi kiến trúc lớn
user-invocable: true
---

# Skill: SDD RFC Manager (`/sdd-rfc`)

Sử dụng skill này khi cần đề xuất thay đổi hoặc bổ sung một quy tắc trong Hiến pháp hệ thống (`CONSTITUTION.md`) ở Layer 1 (Hard Rules) hoặc Layer 2 (Architectural Constraints).

## Tham số
- `--title=<short-title>`: Tiêu đề ngắn gọn cho RFC (e.g., `soft-delete-policy` hoặc `jwt-expiry-standard`).
- `--approve=<rfc-number>`: (Chỉ dành cho Tech Lead) Phê duyệt RFC và tự động đồng bộ vào `CONSTITUTION.md`.

## Quy trình Thực hiện (3 Bước)

### 1. Tạo File Đề xuất RFC Mới
Nếu không truyền `--approve`, skill sẽ tạo file đề xuất tại `.sdd/rfcs/RFC-XXX-<title>.md`:
- Đánh số RFC tăng dần (`RFC-001`, `RFC-002`, ...).
- Trạng thái ban đầu: `PROPOSED`.

### 2. Điền Nội dung theo Template chuẩn RFC
File RFC tạo ra chứa các mục bắt buộc:
- **Motivation**: Lý do cần thay đổi quy tắc hiện tại.
- **Proposed Change**: Quy tắc mới (Mã hóa `SEC-XX`, `DATA-XX`, `ARCH-XX` hoặc `ENG-XX`).
- **Risk Assessment**: Đánh giá tác động đến các feature hiện có.
- **Migration Plan**: Kế hoạch đồng bộ code cũ theo quy tắc mới.

### 3. Phê duyệt & Cập nhật Hiến pháp (`--approve`)
Khi Tech Lead duyệt RFC:
- Chuyển trạng thái RFC sang `APPROVED`.
- Tự động cập nhật quy tắc mới vào file `CONSTITUTION.md`.
- Bump patch/minor version của `CONSTITUTION.md`.

---

## AI Recommendation & Human Final Review

After drafting or evaluating an RFC, generate the canonical recommendation from `.claude/skills/_shared/ai-review-protocol.md` with motivation, alternatives, security/architecture impact, migration risk, and proposed disposition. Persist it in the RFC or `.sdd/reviews/rfc-<number>.md` with `PENDING HUMAN REVIEW`. Only the authorized Tech Lead/Human Director may approve the RFC and Constitution change; the Agent must not self-approve.