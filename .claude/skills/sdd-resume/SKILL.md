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
2. Đọc `CONTEXT.md`, `SPEC.md`, Architecture Profile theo [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md), `PLAN.md`, `TASKS.md`, `.sdd/shared_context.md` và `## Current Handoff State` nếu có.
3. Báo feature, task đã xong/tổng số, task tiếp theo, Intent/DoD, approved scope/file boundary, active contract version, profile version/binding, state-change category/checkpoint, exact command, review state, exact next decision/command và unresolved blocker.
4. Với legacy high-risk feature thiếu metadata, dừng và yêu cầu Human disposition: chấp nhận evidence hiện tại hoặc yêu cầu targeted update. Không retroactively invalidate artifact chỉ vì format cũ.
5. Chỉ đề xuất `/add-execute --feature={feature-slug}` khi task scope, required binding, exact verification command, review state, required checkpoint và contract ownership đều hợp lệ.
6. Nếu profile binding/review/checkpoint còn `PENDING`, contract drift, hoặc blocker chưa resolve, báo blocker theo protocol; không đề xuất execution command suy đoán.

## AI Recommendation và Human Final Review

Sau khi khôi phục context, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm task tiếp theo, active contract version, approved scope, pending checkpoint, evidence gap, unresolved blocker và exact resume command. Lưu trong `TASKS.md` hoặc `.sdd/reviews/resume-<slug>.md` với `PENDING HUMAN REVIEW`. Không gọi `/add-execute` trước khi Human Director ghi `APPROVED` khi checkpoint required; Agent không tự approve resume scope.
