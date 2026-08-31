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
   - `[x]`: Hoàn thành; required exact verification command đã pass, hoặc `N/A` với lý do hợp lệ; Action Record, checkpoint và sync-back cần thiết đã có.
   - `[/]`: Đang thực hiện.
   - `[ ]`: Chưa thực hiện.
2. Ghi feature/task đang dở, profile version/binding evidence, active contract version, approved scope/file boundary, state-change checkpoint, exact command đã chạy/kết quả, method đang dở, blocker và open question.
3. Thêm/cập nhật `## Current Handoff State` cuối `TASKS.md` với Action Record theo [AI Review Protocol](../_shared/ai-review-protocol.md), exact next decision/command và sync-back state.
4. Handoff ngay khi scope expansion, blocker, contract drift hoặc decision mới xuất hiện; không tiếp tục absorb unrelated cleanup.
5. Xuất tóm tắt và hướng dẫn phiên sau:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Continue
   ```

   Sau đó dùng `/sdd-resume --feature={feature-slug}`.

## AI Recommendation và Human Final Review

Trước khi kết thúc phiên, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm task tiếp theo, active contract version, approved scope, pending checkpoint, evidence gap, blocker, exact next decision/command và resume command. Lưu trong `TASKS.md` hoặc `.sdd/reviews/handoff-<slug>.md` với `PENDING HUMAN REVIEW`. Human Director xác nhận resume scope trước material state change hoặc strict-checkpoint task; Agent không tự đánh dấu handoff hoàn tất hoặc approve hành động tiếp theo.
