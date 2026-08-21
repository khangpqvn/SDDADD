---
name: sdd-agents-edit
description: Quản lý và cập nhật file AGENTS.md (Agent Constitution, Persona, Scope & Tool Permissions Matrix)
user-invocable: true
---

# Skill: SDD Agent Constitution Editor (`/sdd-agents-edit`)

Sử dụng skill này khi cần cập nhật `AGENTS.md` — nơi định nghĩa Persona, Phạm vi cho phép (Scope Boundaries), Phân quyền công cụ (Tool Permissions Matrix), Quy định Bảo mật hoặc Quy trình Leo thang (Escalation Protocol) của AI Agents.

## Tham số
- `--section=<tên-mục>`: (Tùy chọn) Section cần sửa (e.g. `persona`, `scope`, `tool-permissions`, `security`, `escalation`).
- `--reason=<lý-do>`: Lý do cập nhật phân quyền hoặc quy tắc cho AI Agent.

## Quy trình Thực hiện (4 Bước)

1. **Đọc & Đánh giá `AGENTS.md` hiện tại**:
   - Đọc phiên bản hiện tại của `AGENTS.md`.
   - Đối chiếu với `CONSTITUTION.md` để đảm bảo phân quyền của Agent không vượt quá giới hạn an toàn hệ thống.

2. **Cập nhật Quy tắc Persona / Phân quyền Agent**:
   - Thêm/Sửa định danh Agent, đường dẫn được phép/bị cấm (`Permitted/Forbidden Paths`).
   - Cập nhật Ma trận Phân quyền Tool Permissions (Allowed / Restricted / Forbidden).
   - Cập nhật quy trình xử lý lỗi và Leo thang khi Agent bị tắc kẹt (Escalation Protocol).

3. **Bump Version & Cập nhật Changelog**:
   - Bump version `AGENTS.md` (e.g. `v1.0.0` ➔ `v1.0.1` hoặc `v1.1.0`).
   - Ghi lý do thay đổi và người cập nhật vào mục `## Changelog` ở cuối file `AGENTS.md`.

4. **Thông báo Cập nhật**:
   - Thông báo cho người dùng biết các quy định phân quyền hoặc hành vi mới của Agent đã được thiết lập.

---

## AI Recommendation & Human Final Review

Before changing `AGENTS.md`, generate the canonical recommendation from `.claude/skills/_shared/ai-review-protocol.md` covering permission impact, security risk, escalation behavior, alternatives, and affected skills. Persist it in `.sdd/reviews/agents-edit.md` with `PENDING HUMAN REVIEW`. The Human Director/Tech Lead must approve before the edit; after editing, refresh the recommendation and do not self-approve the new permissions.
