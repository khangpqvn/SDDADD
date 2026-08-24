---
name: add-execute
description: Pha 4 & 5 ADD - Thực thi Code cho Task (.sdd/features/{feature-slug}/TASKS.md) kèm Self-Check CONSTITUTION.md, DoD Validation & nguyên tắc Fix the Spec
user-invocable: true
---

# Skill: ADD Phase 4 & 5 — Agentic Execution & Validation (`/add-execute`)

Sử dụng skill này để AI Agent đọc Task từ `.sdd/features/{feature-slug}/TASKS.md`, thực thi sinh Code, tự chạy Self-Check theo `CONSTITUTION.md` và tuân thủ nguyên tắc **Fix the Spec, not the Code**.

## Tham số
- `--feature=<feature-slug>`: Tên định danh feature.
- `--task=<task-id>`: (Tùy chọn) Mã Task cụ thể cần thực hiện (ví dụ: `T001`).

## Quy trình thực hiện (6 Bước)

1. **Đọc Ngữ cảnh & Cấu hình Agent**:
   - Đọc `AGENTS.md` (Persona, Scope, Tool Permissions) và `CONSTITUTION.md` (Hard Rules).
   - Đọc `.sdd/constraints/global.md`, `.sdd/constraints/business.md`, `.sdd/constraints/safety.md`.
   - Đọc Task cần làm trong `.sdd/features/{feature-slug}/TASKS.md`.

2. **SHADOW PLAN — Xuất kế hoạch trước khi thực thi** *(Slide 10.6.1)*:
   Trước mỗi task, Agent BẮT BUỘC xuất Shadow Plan theo format sau và CHỜ xác nhận:

   ```
   ╔══════════════════════════════════════════════════════╗
   ║  SHADOW PLAN — Task {T00X}: {Task Title}             ║
   ╠══════════════════════════════════════════════════════╣
   ║  📖 FILES TO READ:                                   ║
   ║    - {file-path-1}  (lý do đọc)                     ║
   ║    - {file-path-2}  (lý do đọc)                     ║
   ║                                                      ║
   ║  ✏️  FILES TO CREATE:                                ║
   ║    - {new-file-path}  (mục đích)                    ║
   ║                                                      ║
   ║  🔧 FILES TO MODIFY:                                 ║
   ║    - {existing-file}  (thay đổi gì)                 ║
   ║                                                      ║
   ║  ⚡ COMMANDS TO RUN:                                  ║
   ║    1. npm test -- --testPathPattern={spec}           ║
   ║    2. npm run lint                                   ║
   ║                                                      ║
   ║  ⚠️  RISKS:                                          ║
   ║    - {risk-1 nếu có}                                 ║
   ╚══════════════════════════════════════════════════════╝
   Proceed? [Human confirms before Agent executes]
   ```

   - Shadow Plan giúp Human Director kiểm soát rủi ro và tiết kiệm tokens bằng cách phát hiện sai sớm.
   - Nếu scope thay đổi so với Shadow Plan trong khi thực thi, dừng và xuất Shadow Plan mới.

3. **Lập Kế hoạch Thực thi (Plan-Act-Check)**:
   - Liệt kê các file sẽ tạo/sửa.
   - Viết code tuân thủ Clean Architecture (`CLAUDE.md`) và thêm JSDoc tag `@ears SPEC.md#REQ-XXX`.

4. **Chạy AI Agent Self-Check Protocol**:
   - Đối chiếu output với `CONSTITUTION.md` và `.sdd/constraints/`:

     - [ ] Zero hardcoded secrets? (`SEC-01`)
     - [ ] Có Auth & Idempotency Check? (`SEC-02`, `DATA-02`)
     - [ ] Có Soft-delete? (`DATA-01`)
     - [ ] Đã gắn tag `@ears` vào JSDoc? (`ENG-01`)

5. **Kiểm thử & Verification Gate (Chạy DoD Checklist)**:
   - Chạy lệnh test kiểm thử: `npm test` hoặc `npm run test:e2e`.
   - Kiểm tra DoD Checklist bên dưới.

6. **Xử lý Thất bại theo Nguyên tắc "Fix the Spec, NOT the Code"**:
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

---

## AI Recommendation & Human Final Review

Before execution, read the persisted review blocks and generate a recommendation covering implementation approach, impacted files, self-check evidence, test evidence, and any Spec gap. Persist it in the feature artifact or `.sdd/reviews/<review-slug>.md` with `PENDING HUMAN REVIEW`. Do not execute when the required Context, Spec, Plan, or Tasks review is not `APPROVED`; after execution, generate a completion recommendation. The Human Director reviews the result and decides `APPROVED`, `REVISE`, or `REJECTED`; the Agent cannot mark execution complete on its own.
