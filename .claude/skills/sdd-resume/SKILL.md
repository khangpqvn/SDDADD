---
name: sdd-resume
description: Khôi phục ngữ cảnh feature dở dang từ TASKS.md, SPEC.md và Architecture Profile
user-invocable: true
---

# SDD Resume (`/sdd-resume`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `PENDING`, `APPROVED`, `BLOCKED`), file paths, and CLI commands are language-invariant.

Dùng khi bắt đầu phiên mới để quét task dở dang và nạp lại feature context.

## Tham số

- `--feature=<feature-slug>`: Tùy chọn; feature cần tiếp tục. Không truyền thì quét `.sdd/features/` tìm `TASKS.md` có `[/]` hoặc task `[ ]` đầu tiên.

## Quy trình

1. Quét feature/task dở dang trong `.sdd/features/`.
2. Đọc `CONTEXT.md`, `SPEC.md`, Architecture Profile theo [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md), `PLAN.md`, `TASKS.md` và `## Current Handoff State` nếu có.
3. Báo feature, task đã xong/tổng số, task tiếp theo, file cần sửa, profile version, binding, exact command, review state và blocker.
4. Chỉ đề xuất `/add-execute --feature={feature-slug}` khi task scope, required binding, exact verification command và Human Final Review đều `APPROVED`.
5. Nếu profile binding/review còn `PENDING`, báo blocker theo protocol và đề xuất Human decision thích hợp; không đề xuất execution command suy đoán.

## AI Recommendation và Human Final Review

Sau khi khôi phục context, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm task tiếp theo, evidence gap, pending approval và resume command đề xuất. Lưu trong `TASKS.md` hoặc `.sdd/reviews/resume-<slug>.md` với `PENDING HUMAN REVIEW`. Không gọi `/add-execute` trước khi Human Director ghi `APPROVED`; Agent không tự approve resume scope.
