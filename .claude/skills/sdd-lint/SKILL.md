---
name: sdd-lint
description: Lint và kiểm định cú pháp EARS, SemVer và điều kiện biên trong SPEC.md
user-invocable: true
---

# SDD Spec Linter (`/sdd-lint`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`), EARS keywords, `REQ-XXX` identifiers, file paths, and CLI commands are language-invariant.

Dùng để lint và kiểm định `.sdd/features/{feature-slug}/SPEC.md`, phát hiện requirement mơ hồ, vi phạm EARS hoặc thiếu edge case trước khi Human Director hoặc Tech Lead review Spec.

## Tham số

- `--feature=<feature-slug>`: Feature slug cần lint.

## Quy trình kiểm tra

1. **Cú pháp EARS**
   - Kiểm tra mọi Functional Requirement thuộc một trong năm mẫu EARS:
     - **Ubiquitous**: `The <system> SHALL <action>`
     - **Event-driven**: `WHEN <trigger>, the <system> SHALL <action>`
     - **State-driven**: `WHILE <in state>, the <system> SHALL <action>`
     - **Optional**: `WHERE <feature is included>, the <system> SHALL <action>`
     - **Unwanted**: `IF <error/invalid condition>, THEN the <system> SHALL <action>`
   - Cảnh báo cụm từ mơ hồ như “nhanh chóng”, “giao diện đẹp”, “xử lý linh hoạt”, “nếu cần thiết”.
2. **Unwanted Behavior coverage**
   - Mỗi happy path (`WHEN`) cần ít nhất một `IF ... THEN ...` cho lỗi tương ứng, như timeout, duplicate, invalid input hoặc unauthorized.
3. **REQ và metadata**
   - Kiểm tra `REQ-XXX` duy nhất/liên tục, header có status và SemVer hợp lệ.
4. **Báo cáo**
   - Liệt kê warning/error cùng dòng liên quan và đề xuất câu EARS chuẩn hóa.

## AI Recommendation và Human Final Review

Sau lint, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm error, warning, EARS correction đề xuất, edge-case gap và residual risk. Lưu trong feature `SPEC.md` hoặc `.sdd/reviews/lint-<slug>.md` với `PENDING HUMAN REVIEW`. Human Director quyết định có chấp thuận correction hay không; lint failure vẫn bị block đến khi được khắc phục hoặc disposition rõ ràng. Agent không tự approve Spec.
