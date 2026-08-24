---
name: sdd-trace
description: Truy vết yêu cầu và phân tích tác động từ SPEC đến PLAN, TASKS, code và test
user-invocable: true
---

# SDD Requirement Traceability & Impact Analysis (`/sdd-trace`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`, `COVERED`, `MISSING TEST`, `IMPL OUTDATED`), `REQ-XXX` identifiers, `@ears` references, file paths, and CLI commands are language-invariant.

Dùng để truy vết một/toàn bộ requirement `REQ-XXX`, hoặc phân tích tác động khi `.sdd/features/{slug}/SPEC.md` thay đổi.

## Tham số

- `--feature=<feature-slug>`: Feature identifier.
- `--req=<REQ-XXX>`: Tùy chọn; requirement cần truy vết, ví dụ `REQ-001`. Không truyền thì kiểm tra tất cả requirement trong feature.
- `--diff`: Tùy chọn; phân tích tác động giữa Spec mới và code/test hiện tại.

## Quy trình

1. **Requirement Traceability Matrix (RTM)**
   - Đọc `REQ-XXX` trong `SPEC.md`, component trong `PLAN.md`, atomic task trong `TASKS.md`, `@ears` trong `src/` và test liên quan trong `tests/`.
2. **Requirement Impact Analysis**
   - Khi dùng `--diff` hoặc Spec tăng SemVer, liệt kê code, method và test bị ảnh hưởng trực tiếp; cảnh báo broken trace.
3. **Gap và orphan detection**
   - Báo untraced requirement: có trong Spec nhưng thiếu code hoặc test.
   - Báo orphan code: business method ở `src/usecase/` thiếu `@ears` hoặc tham chiếu `REQ-XXX` không tồn tại.
4. **Báo cáo coverage**

| Requirement ID | Spec Version | Plan Component | Task ID | Code Location (@ears) | Test Status | Coverage |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `REQ-001` | v1.0.1 | `RegisterUserUseCase` | `T001`, `T002` | `src/usecase/register-user.ts:25` | PASS (2 tests) | 100% COVERED |
| `REQ-002` | v1.0.1 | `SendOtpService` | `T003` | `src/usecase/send-otp.ts:14` | NO TEST | MISSING TEST |
| `REQ-003` | v1.1.0 (MODIFIED) | `RateLimiter` | `T005` | `src/shared/limiter.ts` | FAIL | IMPL OUTDATED |

## AI Recommendation và Human Final Review

Sau report traceability/impact, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm coverage gap, broken trace, severity, remediation option và residual risk. Lưu trong feature artifact hoặc `.sdd/reviews/trace-<slug>.md` với `PENDING HUMAN REVIEW`. Human Director quyết định disposition hoặc yêu cầu remediation; broken trace chưa xử lý vẫn bị block. Agent không tự đánh dấu coverage `APPROVED`.
