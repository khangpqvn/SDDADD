# Vòng đời SDD và sổ đăng ký nhiều feature

> **Lần đầu dùng template?** Làm theo [Bắt đầu nhanh SDD + ADD](../docs/sdd-add-quickstart.md). Đây là lộ trình chính từ Context đến delivery.

## Governance dùng chung

- [`CONSTITUTION.md`](../CONSTITUTION.md): hard quality/security rules.
- [`AGENTS.md`](../AGENTS.md): phạm vi và quyền của Agent.
- [`CLAUDE.md`](../CLAUDE.md): bộ nhớ kiến trúc cho con người.
- [`architecture-profile.md`](./architecture-profile.md): tech binding, evidence và exact verification command canonical.
- [`shared_context.md`](./shared_context.md): shared contract/state.
- [`constraints/`](./constraints/): global, business và safety constraints.
- [`mcp-config.yaml`](./mcp-config.yaml): MCP/dispatch policy, không phải runtime enforcement evidence.

## Sổ đăng ký feature

| Feature slug | Tên feature | Owner | Status | Path |
| :--- | :--- | :--- | :--- | :--- |
| *(Chưa có feature)* | Chạy `/sdd-context --feature=<slug>` để khởi tạo. | — | — | `.sdd/features/` |

## Cấu trúc feature

Mỗi feature nằm trong `.sdd/features/{feature-slug}/`:

- `CONTEXT.md`: Intent Packet, Describe-back, Methodology Profile, glossary và question disposition.
- `SPEC.md`: executable requirements, Feature Lock và review/lock.
- `PLAN.md`: architecture/data flow, profile evidence, consistency và risk.
- `TASKS.md`: atomic tasks, owner, command, checkpoint, sizing và delivery trigger.

Context/Spec có thể core-only. Plan/Tasks cần binding/command liên quan từ Architecture Profile đã `APPROVED`.

## Cập nhật artifact

Dùng `/sdd-update --feature=<slug> --artifact=<context|spec|plan|tasks> --reason="..."` để cập nhật artifact đã approved. Update material invalidate review bị ảnh hưởng, tạo recommendation mới và cần Human review trước downstream work.
