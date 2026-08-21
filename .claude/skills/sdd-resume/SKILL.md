---
name: sdd-resume
description: Tự động khôi phục ngữ cảnh làm việc dở dang từ TASKS.md và SPEC.md khi bắt đầu phiên mới
user-invocable: true
---

# Skill: SDD Resume (`/sdd-resume`)

Sử dụng skill này ngay khi khởi động phiên làm việc mới để tự động quét trạng thái dở dang và nạp lại ngữ cảnh làm việc.

## Tham số
- `--feature=<feature-slug>`: (Tùy chọn) Feature slug cần tiếp tục. Nếu không truyền, skill tự động quét `.sdd/features/` tìm feature có task dở dang (`[/]`).

## Các bước thực hiện (4 Bước)

1. **Quét Trạng thái Dở dang**:
   - Kiểm tra thư mục `.sdd/features/`.
   - Tìm file `TASKS.md` có chứa task mang trạng thái `[/]` hoặc task `[ ]` đầu tiên chưa làm.

2. **Tải Ngữ cảnh Feature**:
   - Đọc `.sdd/features/{feature-slug}/CONTEXT.md` để nắm bài toán.
   - Đọc `.sdd/features/{feature-slug}/SPEC.md` để nắm yêu cầu EARS.
   - Đọc section `## Current Handoff State` trong `TASKS.md` (nếu có).

3. **Báo cáo Ngữ cảnh Khôi phục**:
   - Tóm tắt cho người dùng:
     - Feature đang làm: `{feature-slug}`
     - Task đã xong: X/Y tasks
     - Task tiếp theo cần làm: `T00X - [Mô tả]`
     - File cần tiếp tục chỉnh sửa.

4. **Đề xuất Bước Tiếp theo**:
   - Đưa ra gợi ý chạy ngay lệnh thực thi:
     ```bash
     /add-execute --feature={feature-slug}
     ```
