---
name: sdd-rfc
description: Quản lý RFC để sửa CONSTITUTION.md hoặc thay đổi kiến trúc lớn
user-invocable: true
---

# SDD RFC Manager (`/sdd-rfc`)

Dùng khi cần đề xuất thay đổi/bổ sung quy tắc trong `CONSTITUTION.md` thuộc Layer 1 Hard Rules hoặc Layer 2 Architectural Constraints sau khi template đã phát hành. Một explicit Human authorization cho một đợt phát hành template không tạo quyền mặc định cho Agent sửa Constitution.

## Tham số

- `--title=<short-title>`: Tiêu đề ngắn, ví dụ `soft-delete-policy` hoặc `jwt-expiry-standard`.
- `--approve=<rfc-number>`: Chỉ Tech Lead/Human Director được dùng để phê duyệt RFC và đồng bộ Constitution.

## Quy trình

1. **Tạo RFC**
   - Không truyền `--approve`: tạo `.sdd/rfcs/RFC-XXX-<title>.md`, đánh số liên tục `RFC-001`, `RFC-002`, ... và status ban đầu `PROPOSED`.
2. **Điền template RFC**
   - Bắt buộc có `Motivation`, `Proposed Change`, `Risk Assessment` và `Migration Plan`.
   - Quy tắc mới dùng code `SEC-XX`, `DATA-XX`, `ARCH-XX` hoặc `ENG-XX` khi phù hợp.
3. **Phê duyệt và đồng bộ**
   - Chỉ RFC đã `APPROVED` bởi Tech Lead/Human Director mới được đồng bộ vào `CONSTITUTION.md`.
   - Bump patch/minor version của Constitution theo semantic impact.

## AI Recommendation và Human Final Review

Sau khi soạn hoặc đánh giá RFC, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm motivation, alternative, security/architecture impact, migration risk và disposition đề xuất. Lưu trong RFC hoặc `.sdd/reviews/rfc-<number>.md` với `PENDING HUMAN REVIEW`. Chỉ Tech Lead/Human Director được ủy quyền có thể approve RFC và thay đổi Constitution; Agent không tự approve.
