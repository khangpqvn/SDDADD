---
name: sdd-handoff
description: Lưu trạng thái phiên làm việc dở dang, cập nhật TASKS.md và tạo Handoff Report cho phiên tiếp theo
user-invocable: true
---

# Skill: SDD Handoff (`/sdd-handoff`)

Sử dụng skill này khi cần kết thúc phiên làm việc dở dang. Skill sẽ tự động tổng hợp tiến độ, đóng bằng trạng thái công việc và tạo báo cáo Handoff cho phiên tiếp theo.

## Tham số
- `--feature=<feature-slug>`: (Tùy chọn) Feature slug đang thực hiện (e.g., `feat-001-order-checkout`). Nếu không truyền, skill sẽ tự động quét feature đang active trong `.sdd/features/`.

## Các bước thực hiện (4 Bước)

1. **Quét & Cập nhật Trạng thái Tasks**:
   - Mở file `.sdd/features/{feature-slug}/TASKS.md`.
   - Đánh dấu chính xác trạng thái từng Task:
     - `[x]` : Task đã hoàn thành và đã pass test.
     - `[/]` : Task đang thực hiện dở dang.
     - `[ ]` : Task chưa thực hiện.

2. **Ghi nhận Ngữ cảnh dở dang (In-Progress Context)**:
   - Liệt kê các file vừa chỉnh sửa trong phiên (`src/`, `tests/`).
   - Ghi nhận hàm/method đang viết dở và kết quả test mới nhất.
   - Ghi nhận các rào cản, câu hỏi mở hoặc blocker (nếu có).

3. **Cập nhật `.sdd/features/{feature-slug}/TASKS.md`**:
   - Thêm phần `## Current Handoff State` vào cuối file `TASKS.md` chứa thông tin tóm tắt điểm dừng.

4. **Báo cáo Handoff & Lệnh Resume**:
   - Xuất tóm tắt trạng thái phiên ra terminal.
   - Hiển thị hướng dẫn khởi động phiên tiếp theo:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Continue
     ```
     Sau đó gõ `/sdd-resume --feature={feature-slug}`.
