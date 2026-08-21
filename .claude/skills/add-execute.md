---
name: add-execute
description: Pha 4 & 5 ADD - Thực thi Code cho Task (.sdd/features/{feature-slug}/TASKS.md) kèm Self-Check CONSTITUTION.md, DoD Validation & nguyên tắc Fix the Spec
---

# Skill: ADD Phase 4 & 5 — Agentic Execution & Validation (`/add-execute`)

Sử dụng skill này để AI Agent đọc Task từ `.sdd/features/{feature-slug}/TASKS.md`, thực thi sinh Code, tự chạy Self-Check theo `CONSTITUTION.md` và tuân thủ nguyên tắc **Fix the Spec, not the Code**.

## Tham số
- `--feature=<feature-slug>`: Tên định danh feature.
- `--task=<task-id>`: (Tùy chọn) Mã Task cụ thể cần thực hiện (ví dụ: `T001`).

## Quy trình thực hiện (5 Bước)

1. **Đọc Ngữ cảnh & Cấu hình Agent**:
   - Đọc `AGENTS.md` (Persona, Scope, Tool Permissions) và `CONSTITUTION.md` (Hard Rules).
   - Đọc Task cần làm trong `.sdd/features/{feature-slug}/TASKS.md`.

2. **Lập Kế hoạch Thực thi (Plan-Act-Check)**:
   - Liệt kê các file sẽ tạo/sửa.
   - Viết code tuân thủ Clean Architecture (`CLAUDE.md`) và thêm JSDoc tag `@ears SPEC.md#REQ-XXX`.

3. **Chạy AI Agent Self-Check Protocol**:
   - Đối chiếu output với `CONSTITUTION.md`:
     - [ ] Zero hardcoded secrets? (`SEC-01`)
     - [ ] Có Auth & Idempotency Check? (`SEC-02`, `DATA-02`)
     - [ ] Có Soft-delete? (`DATA-01`)
     - [ ] Đã gắn tag `@ears` vào JSDoc? (`ENG-01`)

4. **Kiểm thử & Verification Gate (Chạy DoD Checklist)**:
   - Chạy lệnh test kiểm thử: `npm test` hoặc `npm run test:e2e`.
   - Kiểm tra DoD Checklist bên dưới.

5. **Xử lý Thất bại theo Nguyên tắc "Fix the Spec, NOT the Code"**:
   - Nếu Test FAIL do thiếu thông tin nghiệp vụ hoặc trường hợp biên:
     1. **KHÔNG** vá code trực tiếp.
     2. Đưa đề xuất cập nhật file `.sdd/features/{feature-slug}/SPEC.md` và bump patch version spec.
     3. Sau khi Spec mới được duyệt ➔ Re-generate Code từ Spec mới.

---

## 📋 CHECKPOINT CHECKLIST (Definition of Done — Pha 4 & 5)
- [ ] 100% Unit Tests & Integration Tests báo GREEN.
- [ ] Tỷ lệ khớp Code ↔ Spec đạt 100% (Accretion drift = 0).
- [ ] Tất cả các lỗi phát hiện khi test đều được xử lý theo nguyên tắc **Fix the Spec, NOT the Code**.
- [ ] AI Agent Self-Check Protocol hoàn thành 100% không vi phạm `CONSTITUTION.md`.
- [ ] Commit message trích dẫn rõ phiên bản Spec: `feat(scope): message per spec/feature/{slug}/v1.0.0`.
