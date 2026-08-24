---
name: sdd-agents-edit
description: Quản lý và cập nhật AGENTS.md: Agent Constitution, vai trò, phạm vi và ma trận quyền công cụ
user-invocable: true
---

# SDD Agent Constitution Editor (`/sdd-agents-edit`)

Dùng khi cần cập nhật `AGENTS.md`: vai trò, phạm vi, quyền công cụ, quy tắc bảo mật hoặc quy trình escalation của AI Agent.

## Tham số

- `--section=<tên-mục>`: Tùy chọn; mục cần sửa, ví dụ `persona`, `scope`, `tool-permissions`, `security`, `escalation`.
- `--reason=<lý-do>`: Lý do cập nhật quyền hoặc quy tắc Agent.

## Quy trình

1. Đọc `AGENTS.md`, `CONSTITUTION.md`, `CLAUDE.md`, Architecture Profile và constraint liên quan.
2. Đối chiếu thay đổi với Constitution; không mở rộng quyền vượt safety boundary hoặc Technology Gate.
3. Cập nhật role, permitted/forbidden path, tool permission, error handling hoặc escalation đúng phạm vi approved.
4. Bump version theo SemVer và ghi lý do/người cập nhật trong `## Changelog` của `AGENTS.md`.
5. Báo rõ permission impact, security risk, affected skill và bước escalation mới.

## AI Recommendation và Human Final Review

Trước khi sửa `AGENTS.md`, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, bao gồm permission impact, security risk, escalation behavior, alternative và affected skill. Lưu tại `.sdd/reviews/agents-edit.md` với `PENDING HUMAN REVIEW`. Human Director hoặc Tech Lead phải `APPROVED` trước khi sửa. Sau khi sửa, refresh recommendation; Agent không tự approve permission mới.
