---
name: sdd-claude-edit
description: Cập nhật CLAUDE.md an toàn theo Architecture Profile và repository evidence
user-invocable: true
---

# SDD Project Memory Editor (`/sdd-claude-edit`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`), file paths, and CLI commands are language-invariant.

Dùng khi cập nhật `CLAUDE.md`, là bộ nhớ kiến trúc cho người đọc và phải phản chiếu Architecture Profile đã approved.

## Tham số

- `--section=<tên-mục>`: Tùy chọn; mục cần sửa, ví dụ `tech-stack`, `naming-conventions`, `directory-anatomy`, `architecture-dna`.
- `--reason=<lý-do>`: Lý do cập nhật kiến trúc hoặc project memory.

## Quy trình

1. Đọc `CLAUDE.md`, `CONSTITUTION.md`, `.sdd/architecture-profile.md`, constraint và evidence repository.
2. Tech stack/architecture binding chỉ được cập nhật trong profile theo [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md); không suy đoán framework, database, ORM/query layer, validation hoặc command từ prose.
3. Profile thay đổi: invalidate recommendation/Plan/Tasks bị ảnh hưởng, tạo `PENDING HUMAN REVIEW`, rồi chỉ phản chiếu binding đã `APPROVED` vào `CLAUDE.md`.
4. Không áp đặt section, version hoặc changelog không tồn tại. Giữ cấu trúc hiện hữu trừ khi Human-approved scope yêu cầu thay đổi.
5. Kiểm tra nội dung `CLAUDE.md` khớp source layout, skill và profile hiện tại.

## AI Recommendation và Human Final Review

Trước khi sửa `CLAUDE.md`, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm architecture evidence, memory change đề xuất, alternative, drift risk và affected skill. Lưu tại `.sdd/reviews/claude-edit.md` với `PENDING HUMAN REVIEW`. Human Director/Tech Lead phải `APPROVED` trước edit; sau edit refresh recommendation và không tự approve project memory mới.
