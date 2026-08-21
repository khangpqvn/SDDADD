---
name: sdd-audit
description: Kiểm tra tuân thủ các quy tắc chất lượng 3 tầng trong CONSTITUTION.md (Hard Rules, Arch Constraints, Eng Standards)
user-invocable: true
---

# Skill: SDD Audit (`/sdd-audit`)

Sử dụng skill này để kiểm định toàn bộ mã nguồn và đặc tả đối chiếu với Hiến pháp dự án (`CONSTITUTION.md`) trước khi commit hoặc tạo Pull Request.

## Tham số
- `--feature=<feature-slug>`: (Tùy chọn) Kiểm tra phạm vi 1 feature. Nếu không truyền, kiểm tra toàn bộ repository.

## Quy trình Kiểm định 3 Tầng (3-Layer Quality Audit)

### Tầng 1: Hard Rules Verification (Bắt Buộc PASS 100%)
- **SEC-01 (Secrets Check)**: Quét toàn bộ `src/`, `config/`, `.env` tìm API keys (`sk-*`), private keys, passwords hoặc plaintext credentials.
- **SEC-02 (Auth Check)**: Kiểm tra 100% router/controller endpoints thay đổi trạng thái (POST, PUT, PATCH, DELETE) đã bọc Middleware Auth chưa.
- **DATA-01 (Soft Delete Check)**: Quét SQL statements hoặc ORM calls trong `infra/` / `usecase/` xem có dùng câu lệnh hard-delete (`DELETE FROM`) vi phạm quy định không.

### Tầng 2: Architectural Constraints Verification
- **ARCH-01 (Clean Arch Boundaries)**: Kiểm tra hướng phụ thuộc dependency (`infra` -> `interface` -> `usecase` -> `domain`). Cấm `interface` gọi trực tiếp `infra` (DB), cấm `domain` import thư viện ngoài.
- **ARCH-02 (Async Ops Check)**: Kiểm tra các tác vụ nặng/lâu có được đẩy qua Message Queue không.

### Tầng 3: Engineering Standards Verification
- **ENG-01 (EARS Tagging Traceability)**: Tính tỷ lệ phủ JSDoc tag `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX` trên các method nghiệp vụ trong `src/usecase/`.
- **ENG-02 (Unified Error Response)**: Kiểm tra các exception handler xem có trả về đúng cấu trúc JSON chuẩn `{ error_code, message, request_id, timestamp }` không.

## Đưa ra Kết quả Audit
Xuất bảng báo cáo Compliance Report:
- ❌ **FAILED (Blocker)**: Các lỗi vi phạm Layer 1 (Cần fix ngay lập tức).
- ⚠️ **WARNING**: Các vi phạm Layer 2/3 (Cần giải trình hoặc giải quyết).
- ✅ **PASSED**: Danh sách quy tắc đã tuân thủ.
