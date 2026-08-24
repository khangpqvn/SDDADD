---
name: sdd-spec
description: Pha 1 SDD — tạo SPEC.md với EARS, SemVer, BDD, error contract và DoD
user-invocable: true
---

# SDD Phase 1 — Specification (`/sdd-spec`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `PENDING`, `APPROVED`, `APPROVED & LOCKED`, `DRAFT`), EARS keywords (`WHEN`, `WHILE`, `WHERE`, `IF`, `THEN`, `SHALL`), file paths, and CLI commands are language-invariant.

Dùng `CONTEXT.md` và `CONSTITUTION.md` để tạo `.sdd/features/{feature-slug}/SPEC.md`.

## Tham số

- `--feature=<feature-slug>`: Feature identifier.
- `--bump=<major|minor|patch>`: Dùng khi cập nhật Spec.

## Architecture Profile preflight

Tuân thủ [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md).

- Đọc profile trước Context và Constitution.
- `SPEC.md` chỉ mô tả behavior, data contract, error và NFR; không sinh ORM decorator, framework schema, package hoặc CLI command chưa approved.
- Ghi profile version và binding feature cần dùng.
- Binding chưa resolve được phép trong Spec nhưng phải là planning blocker; `PLAN.md` dừng đến khi Human Director approve.

## Clarification-First — bắt buộc trước khi viết requirement

Trước khi draft requirement, AI phải liệt kê điểm chưa chắc chắn từ `CONTEXT.md` theo 3 loại:

1. **Business logic gaps** — Rule nào chưa xác định rõ? (ví dụ: "duplicate handling thế nào khi user submit hai lần?")
2. **Constraint kỹ thuật thiếu** — NFR nào chưa có giá trị cụ thể? (ví dụ: timeout, rate limit, response time)
3. **Edge case chưa đề cập** — Tình huống hiếm nhưng quan trọng? (ví dụ: "concurrent request từ cùng user?")

Với mỗi điểm, nêu: điều chưa chắc là gì — assumption sẽ dùng nếu phải chọn — ảnh hưởng của assumption đó. **Dừng và chờ Human Director confirm trước khi viết requirement.** Nếu được phép tiếp tục với assumption, ghi rõ assumption đó vào Spec.

## Spec Depth — chọn mức phù hợp trước khi viết

Dùng Risk × Complexity Matrix:

| | Complexity Thấp | Complexity Cao |
| :--- | :--- | :--- |
| **Risk Thấp** | **Sketch** — Functional Req + Acceptance Criteria | **Detailed** — Đủ 8 thành phần |
| **Risk Cao** | **Detailed** — Đủ 8 thành phần | **Formal** — 8 thành phần + State Diagram + formal verification |

- **Sketch**: CRUD đơn giản, không auth, không money, không PII. 3–5 requirement là đủ.
- **Detailed**: Feature có auth, payment, state machine, concurrent access, third-party.
- **Formal**: Core business logic, compliance-critical, data migration, irreversible operation.

Nêu depth đã chọn và lý do trong Spec header.

## 8 Thành phần Spec bắt buộc

Thiếu thành phần nào tạo "lỗ hổng context" — AI tự lấp bằng assumption không kiểm soát.

| # | Thành phần | Câu hỏi phải trả lời | Thiếu → AI làm gì? |
| :--- | :--- | :--- | :--- |
| 1 | **Context & Goal** | Tại sao feature tồn tại? Business problem là gì? | Code "đúng kỹ thuật" nhưng sai bài toán |
| 2 | **Actors & Roles** | Ai tương tác? Với quyền gì? | Bỏ qua phân quyền, code cho một loại user |
| 3 | **Functional Requirements** | Hệ thống làm gì? (EARS) | Implement theo hiểu biết default của model |
| 4 | **Non-functional Requirements** | Tốt đến mức nào? (latency, throughput, availability) | Performance/security theo best guess |
| 5 | **Data Model** | Dữ liệu có cấu trúc gì? | Tự thiết kế schema — thường không phù hợp |
| 6 | **Error Handling** | Khi sai thì làm gì? (Unwanted EARS) | Happy path only — production sẽ crash |
| 7 | **Acceptance Criteria** | Định nghĩa "xong" là gì? (BDD) | Tests yếu và thiếu |
| 8 | **Out of Scope** | Hệ thống KHÔNG làm gì? | "Nhiệt tình" thêm feature ngoài yêu cầu |

## EARS Notation — 5 patterns

Mọi Functional Requirement phải thuộc đúng một pattern:

- **Ubiquitous**: `The <system> SHALL <action>` — rule luôn đúng, không cần trigger
- **Event-driven**: `WHEN <trigger>, the <system> SHALL <action>` — phản ứng sự kiện
- **State-driven**: `WHILE <in state>, the <system> SHALL <action>` — hành vi trong trạng thái
- **Optional**: `WHERE <feature is included>, the <system> SHALL <action>` — feature flag
- **Unwanted**: `IF <invalid/error condition>, THEN the <system> SHALL <action>` — error path

Quy tắc: mỗi happy path (`WHEN`) cần ít nhất một `IF ... THEN ...` cho error tương ứng. Tránh từ mơ hồ: "nhanh chóng", "giao diện đẹp", "xử lý linh hoạt", "nếu cần thiết". Mọi NFR phải có giá trị đo được.

## Các bước

1. Đọc Context và Constitution.
2. Chạy Clarification-First; chờ Human Director xác nhận trước bước tiếp theo.
3. Xác định Spec Depth phù hợp (Sketch/Detailed/Formal).
4. Ghi SemVer và `Status: DRAFT`.
5. Viết đủ 8 thành phần theo depth đã chọn; Functional Requirement dùng EARS.
6. Kiểm tra DoD, cập nhật changelog và tạo recommendation.

## DoD

- [ ] Đã chạy Clarification-First; assumption được ghi rõ hoặc đã Human confirm.
- [ ] Spec Depth đã chọn và lý do đã ghi.
- [ ] Có đủ 8 thành phần: Context, Actors, Functional, NFR, Data, Error, Acceptance, Out of Scope.
- [ ] Mọi Functional Requirement dùng đúng EARS pattern.
- [ ] Mỗi happy path có ít nhất một Unwanted EARS tương ứng.
- [ ] Không có từ mơ hồ; NFR có giá trị cụ thể đo được.
- [ ] Open question quan trọng đã resolve hoặc nêu rõ với assumption.
- [ ] SemVer/changelog đúng và Human Final Review đã `APPROVED` trước lock.

## AI Recommendation và Human Final Review

Sau khi tạo/sửa `SPEC.md`, lưu canonical recommendation trong artifact, gồm requirement gap, EARS risk, edge case, Out of Scope và SemVer impact. Giữ `Human Final Review.Status: PENDING`; `/sdd-plan` bị block đến khi Human Director ghi `APPROVED`. Agent không được đặt `APPROVED & LOCKED` thay con người.
