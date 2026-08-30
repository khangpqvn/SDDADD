---
name: sdd-agents-edit
description: Quản lý và cập nhật AGENTS.md: Agent Constitution, vai trò, phạm vi và ma trận quyền công cụ
user-invocable: true
---

# SDD Agent Constitution Editor (`/sdd-agents-edit`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`), file paths, and CLI commands are language-invariant.

Dùng khi cần cập nhật `AGENTS.md`: vai trò, phạm vi, quyền công cụ, quy tắc bảo mật hoặc quy trình escalation của AI Agent.

## Tham số

- `--section=<tên-mục>`: Tùy chọn; tên section canonical, ví dụ `identity`, `scope`, `tool-permissions`, `security`, `communication`, `error-handling`, `escalation`, `changelog`.
- `--reason=<lý-do>`: Lý do cập nhật quyền hoặc quy tắc Agent.

## Cấu trúc 8 sections canonical của AGENTS.md

`AGENTS.md` phải có đúng 8 sections theo thứ tự. Khi sửa, chỉ thay đổi đúng section liên quan — không thêm section ngoài canonical, không đổi thứ tự.

| # | Section | Nội dung |
| :--- | :--- | :--- |
| 1 | **Identity & Persona** | Seniority, ngôn ngữ chính, philosophy, vị thế Agent |
| 2 | **Scope & Boundaries** | Path được phép/bị cấm theo project layout thực tế |
| 3 | **Tool Permissions** | Exact commands của stack; quyền theo loại hành động |
| 4 | **Security Rules** | Zero secret, input sanitization, data masking |
| 5 | **Communication Style** | Language mirroring, format báo cáo, cách đặt câu hỏi |
| 6 | **Error Handling** | Quy trình khi test fail, Spec mơ hồ, recommendation/review |
| 7 | **Escalation Protocol** | Khi nào dừng và báo Human Director; không escalate chung chung |
| 8 | **Changelog** | Semantic versioning; mọi thay đổi cần peer review |

Khi project adopt từ template, các sections phải được **customize theo stack thực** — persona Go ≠ TypeScript; path `cmd/internal/pkg` ≠ `src/`; tool command `make test` ≠ `npm test`. Xem `/sdd-init` hoặc `/sdd-adopt` để generate tự động.

> **Solo mode** (`--team-size=solo`): AGENTS.md chỉ có 1 role `@developer` — full-stack scope, toàn bộ tool permission. Sections 1–8 vẫn đầy đủ nhưng giản lược: bỏ ownership boundary, bỏ Lead→sub-agent escalation, giữ Human gate khi cần external decision.

## Quy trình

1. Đọc `AGENTS.md`, `CONSTITUTION.md`, `CLAUDE.md`, Architecture Profile và constraint liên quan.
2. Xác định section canonical cần sửa; đối chiếu với Constitution — không mở rộng quyền vượt safety boundary.
3. Cập nhật đúng section trong 8-section structure; không thêm section ngoài canonical.
4. Bump SemVer và ghi entry trong section `## 8. Changelog` kèm lý do/người cập nhật.
5. Báo rõ permission impact, security risk, affected skill và bước escalation mới.

## AI Recommendation và Human Final Review

Trước khi sửa `AGENTS.md`, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, bao gồm permission impact, security risk, escalation behavior, alternative và affected skill. Lưu tại `.sdd/reviews/agents-edit.md` với `PENDING HUMAN REVIEW`. Human Director hoặc Tech Lead phải `APPROVED` trước khi sửa. Sau khi sửa, refresh recommendation; Agent không tự approve permission mới.
