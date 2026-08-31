---
name: sdd-trace
description: Truy vết yêu cầu và phân tích tác động từ SPEC đến PLAN, TASKS, code, test và contract
user-invocable: true
---

# SDD Requirement Traceability & Impact Analysis (`/sdd-trace`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`, `COVERED`, `MISSING TEST`, `IMPL OUTDATED`, `STALE`, `DRIFT`), `REQ-XXX` identifiers, `@ears` references, file paths, and CLI commands are language-invariant.

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
3. **Consistency detection**
   - Báo Plan hoặc Tasks `STALE` khi chúng tham chiếu Spec version, requirement, Feature Lock hoặc component/data flow đã superseded.
   - Báo task `[x]` thiếu Action Record, required Human checkpoint, exact verification evidence hoặc required sync-back.
   - Báo shared contract `DRIFT` khi `.sdd/shared_context.md` thiếu contract ID/version/status/owner, producer/consumer, compatibility decision, hoặc không khớp Spec/Plan/Task evidence.
   - Báo review evidence stale khi artifact changed sau `APPROVED` nhưng chưa có recommendation/review mới.
4. **Gap và orphan detection**
   - Báo untraced requirement: có trong Spec nhưng thiếu Plan/task/code hoặc test.
   - Báo orphan code: business method ở `src/usecase/` thiếu `@ears` hoặc tham chiếu `REQ-XXX` không tồn tại.
5. **Báo cáo coverage và consistency**

| Requirement ID | Spec Version | Plan Component | Task ID | Code Location (@ears) | Test Status | Coverage/Consistency |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `REQ-001` | v1.0.1 | `RegisterUserUseCase` | `T001`, `T002` | `src/usecase/register-user.ts:25` | PASS (2 tests) | 100% COVERED |
| `REQ-002` | v1.0.1 | `SendOtpService` | `T003` | `src/usecase/send-otp.ts:14` | NO TEST | MISSING TEST |
| `REQ-003` | v1.1.0 (MODIFIED) | `RateLimiter` | `T005` | `src/shared/limiter.ts` | FAIL | IMPL OUTDATED |

Broken consistency block delivery của phần affected. Không tự sửa artifact, complete task hoặc approve coverage.

## AI Recommendation và Human Final Review

Sau report traceability/impact, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm coverage gap, stale artifact, missing execution/sync evidence, contract drift, severity, remediation option và residual risk. Lưu trong feature artifact hoặc `.sdd/reviews/trace-<slug>.md` với `PENDING HUMAN REVIEW`. Human Director quyết định disposition hoặc yêu cầu remediation; broken trace hoặc consistency chưa xử lý vẫn bị block. Agent không tự đánh dấu coverage `APPROVED`.
