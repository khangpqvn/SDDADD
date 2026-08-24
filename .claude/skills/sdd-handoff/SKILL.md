---
name: sdd-handoff
description: Lưu trạng thái feature dở dang, cập nhật TASKS.md và tạo handoff report cho phiên sau
user-invocable: true
---

# SDD Handoff (`/sdd-handoff`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`), task status markers (`[x]`, `[/]`, `[ ]`), file paths, and CLI commands are language-invariant.

Dùng trước khi kết thúc phiên có feature chưa hoàn thành. Skill tổng hợp tiến độ, lưu điểm dừng và tạo handoff report cho phiên tiếp theo.

## Tham số

- `--feature=<feature-slug>`: Tùy chọn; feature đang thực hiện, ví dụ `feat-001-order-checkout`. Không truyền thì quét feature active trong `.sdd/features/`.

## Quy trình

1. Mở `.sdd/features/{feature-slug}/TASKS.md` và ghi đúng task status:
   - `[x]`: Hoàn thành; required exact verification command đã pass, hoặc `N/A` với lý do hợp lệ.
   - `[/]`: Đang thực hiện.
   - `[ ]`: Chưa thực hiện.
2. Ghi file vừa sửa, profile version, binding/evidence, exact command đã chạy/kết quả, method đang dở, blocker và open question.
3. Thêm/cập nhật `## Current Handoff State` cuối `TASKS.md`.
4. Xuất tóm tắt và hướng dẫn phiên sau:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Continue
   ```

   Sau đó dùng `/sdd-resume --feature={feature-slug}`.

## AI Recommendation và Human Final Review

Trước khi kết thúc phiên, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm task tiếp theo, evidence gap, blocker, open question và resume command. Lưu trong `TASKS.md` hoặc `.sdd/reviews/handoff-<slug>.md` với `PENDING HUMAN REVIEW`. Human Director xác nhận resume scope trước execution; Agent không tự đánh dấu handoff hoàn tất hoặc approve hành động tiếp theo.
