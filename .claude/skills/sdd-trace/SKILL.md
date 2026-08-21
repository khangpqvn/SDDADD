---
name: sdd-trace
description: Truy vết và phân tích tác động thay đổi yêu cầu nghiệp vụ (Requirement Traceability & Impact Analysis) từ SPEC -> PLAN -> TASKS -> CODE -> TEST
user-invocable: true
---

# Skill: SDD Requirement Traceability & Impact Analysis (`/sdd-trace`)

Sử dụng skill này để **truy vết nguồn gốc (Traceability)** của một hoặc toàn bộ yêu cầu nghiệp vụ (`REQ-XXX`), hoặc **Phân tích tác động (Impact Analysis)** khi có sự thay đổi yêu cầu trong file `.sdd/features/{slug}/SPEC.md`.

## Tham số
- `--feature=<feature-slug>`: Tên định danh feature.
- `--req=<REQ-XXX>`: (Tùy chọn) Mã yêu cầu cụ thể cần truy vết (e.g. `REQ-001`). Nếu không truyền, skill sẽ kiểm tra toàn bộ các `REQ-XXX` trong feature.
- `--diff`: (Tùy chọn) Phân tích tác động thay đổi giữa phiên bản Spec mới và Code/Test hiện tại.

---

## Các công việc Skill thực hiện tự động (4 Bước)

### 1. Trích xuất Ma trận Truy vết (Requirement Traceability Matrix - RTM)
Skill tự động quét và lập bản đồ liên kết 5 tầng cho yêu cầu:
1. **Spec Layer**: Đọc yêu cầu `[REQ-XXX]` trong `.sdd/features/{slug}/SPEC.md`.
2. **Plan Layer**: Kiểm tra thành phần kiến trúc xử lý `REQ-XXX` trong `.sdd/features/{slug}/PLAN.md`.
3. **Task Layer**: Kiểm tra các atomic tasks liên quan trong `.sdd/features/{slug}/TASKS.md`.
4. **Code Layer**: Quét toàn bộ file trong `src/` tìm JSDoc tag `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
5. **Test Layer**: Quét toàn bộ test cases trong `tests/` kiểm thử cho `@ears REQ-XXX`.

### 2. Phân tích Tác động khi Yêu cầu Thay đổi (Requirement Impact Analysis)
Khi truyền `--diff` hoặc khi file `SPEC.md` vừa được tăng phiên bản (SemVer Bump):
- Liệt kê chính xác danh sách file code (`src/...`), phương thức, và test cases (`tests/...`) bị ảnh hưởng trực tiếp bởi sự thay đổi của `REQ-XXX`.
- Cảnh báo các vạch đứt gãy (Broken Traces): Code/Test cũ chưa cập nhật theo Spec mới.

### 3. Phát hiện Lỗ hổng & Code Mồ Côi (Gap & Orphan Detection)
- **Untraced Requirements (Yêu cầu thiếu Code/Test)**: Yêu cầu có trong Spec nhưng chưa được cài đặt trong `src/` hoặc chưa có Test.
- **Orphan Code (Code mồ côi)**: Hàm/phương thức nghiệp vụ trong `src/usecase/` thiếu tag `@ears` hoặc trích dẫn tới một `REQ-XXX` không tồn tại trong Spec.

### 4. Xuất Báo cáo Ma trận Truy vết (Traceability Report)
In báo cáo ma trận dạng bảng hiển thị rõ trạng thái phủ (Coverage Status):

| Requirement ID | Spec Version | Plan Component | Task ID | Code Location (@ears) | Test Status | Coverage |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `REQ-001` | v1.0.1 | `RegisterUserUseCase` | `T001`, `T002` | `src/usecase/register-user.ts:25` | PASS (2 tests) | 🟢 100% COVERED |
| `REQ-002` | v1.0.1 | `SendOtpService` | `T003` | `src/usecase/send-otp.ts:14` | NO TEST | 🟡 MISSING TEST |
| `REQ-003` | v1.1.0 (MODIFIED)| `RateLimiter` | `T005` | Outdated logic in `src/shared/limiter.ts` | FAIL | 🔴 IMPL OUTDATED |

---

## AI Recommendation & Human Final Review

After producing a traceability or impact report, generate the canonical recommendation from `.claude/skills/_shared/ai-review-protocol.md` with coverage gaps, broken traces, severity, remediation options, and residual risk. Persist it in the feature artifact or `.sdd/reviews/trace-<slug>.md` with `PENDING HUMAN REVIEW`. The Human Director decides whether to accept the disposition or require remediation; unresolved broken traces remain blocked. The Agent must not mark coverage approved by itself.