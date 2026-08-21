---
name: sdd-claude-edit
description: Quản lý và cập nhật file CLAUDE.md (Project Memory & Architecture DNA) một cách an toàn và có kiểm soát
user-invocable: true
---

# Skill: SDD Project Memory Editor (`/sdd-claude-edit`)

Sử dụng skill này khi cần cập nhật `CLAUDE.md` — nơi lưu trữ Bộ nhớ dự án (Project Memory), Kiến trúc cốt lõi (Architecture DNA), Tech Stack hoặc Quy chuẩn Naming Conventions.

## Tham số
- `--section=<tên-mục>`: (Tùy chọn) Section cần sửa (e.g. `tech-stack`, `naming-conventions`, `directory-anatomy`, `architecture-dna`).
- `--reason=<lý-do>`: Lý do cập nhật thông tin kiến trúc/bộ nhớ dự án.

## Quy trình Thực hiện (4 Bước)

1. **Đọc & Đánh giá `CLAUDE.md` hiện tại**:
   - Đọc phiên bản hiện tại của `CLAUDE.md`.
   - Kiểm tra xem thay đổi có vi phạm các quy tắc cứng trong `CONSTITUTION.md` không.

2. **Cập nhật Nội dung Kiến trúc / Bộ nhớ**:
   - Thêm/Sửa thông tin Tech Stack, Naming Conventions, hoặc sơ đồ thư mục Clean Architecture.
   - Giữ nguyên cấu trúc chuẩn hóa gồm 4 phần chính:
     1. TL;DR & Purpose
     2. Architecture & Directory Anatomy
     3. Core Architectural Principles
     4. Engineering Conventions & Anti-Patterns

3. **Bump Version & Cập nhật Changelog**:
   - Bump version `CLAUDE.md` (e.g. `v1.0.0` ➔ `v1.0.1` hoặc `v1.1.0`).
   - Cập nhật mục Changelog ở cuối file với lý do thay đổi và người thực hiện.

4. **Kiểm tra Tính Đồng bộ**:
   - Đảm bảo các chỉ dẫn trong `CLAUDE.md` khớp với thực tế thư mục `src/` và các file skill trong `.claude/skills/`.

---

## AI Recommendation & Human Final Review

Before changing `CLAUDE.md`, generate the canonical recommendation from `.claude/skills/_shared/ai-review-protocol.md` covering architecture evidence, proposed memory change, alternatives, drift risk, and affected skills. Persist it in `.sdd/reviews/claude-edit.md` with `PENDING HUMAN REVIEW`. The Human Director/Tech Lead must approve before the edit; after editing, refresh the recommendation and do not self-approve the updated architecture memory.
