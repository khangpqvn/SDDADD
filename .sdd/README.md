# Vòng đời SDD và Multi-Feature Registry

Trạng thái feature và đặc tả của hệ thống.

> **Lần đầu?** Đọc [`../../docs/sdd-add-quickstart.md`](../../docs/sdd-add-quickstart.md) trước.

## 1. Global governance

- [`CONSTITUTION.md`](../CONSTITUTION.md) — Hard quality gate và security rule.
- [`AGENTS.md`](../AGENTS.md) — Constitution, phạm vi và quyền tool của Agent.
- [`CLAUDE.md`](../CLAUDE.md) — Bộ nhớ kiến trúc dành cho con người.
- [`architecture-profile.md`](./architecture-profile.md) — Binding tech stack/kiến trúc, evidence và artifact gate canonical.
- [`shared_context.md`](./shared_context.md) — API contract và trạng thái dùng chung.
- [`constraints/`](./constraints/) — Global, business và safety constraints.
- [`mcp-config.yaml`](./mcp-config.yaml) — MCP access control theo Agent.

---

## 2. Feature Registry

| Feature slug | Tên feature | Owner | Status | Path |
| :--- | :--- | :--- | :--- | :--- |
| *(Chưa có feature)* | Chạy `/sdd-context --feature=<slug>` để khởi tạo. | — | — | `.sdd/features/` |

---

## 3. Cấu trúc feature chuẩn

Mỗi feature nằm trong `.sdd/features/{feature-slug}/` và có bốn artifact:

- `CONTEXT.md` — Pha 0: Context Discovery.
- `SPEC.md` — Pha 1: Executable Specification.
- `PLAN.md` — Pha 2: Architecture Plan.
- `TASKS.md` — Pha 3: Atomic Tasks Breakdown.

`CONTEXT.md` và `SPEC.md` có thể dùng core-only baseline. `PLAN.md` và `TASKS.md` cần binding/command liên quan trong Architecture Profile đã approved.

---

## 4. Cập nhật artifact

Dùng `/sdd-update --artifact=<spec|context|plan|tasks>` để cập nhật artifact đã approved:

| Artifact | Khi dùng |
| :--- | :--- |
| `spec` | Sửa requirement, thêm error case, bump SemVer |
| `context` | Thay đổi stakeholder, constraint, glossary |
| `plan` | Sửa component, risk, data flow (Spec không đổi) |
| `tasks` | Thêm/sửa task, dependency (Plan không đổi) |

Mỗi update invalidate review cũ, tạo recommendation mới cần Human Director approve.