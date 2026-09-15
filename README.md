# Starter Template SDD + ADD

Template khởi tạo dự án theo **Spec-Driven Development (SDD)** và **Agent-Driven Development (ADD)**. Requirement, quyết định Human, evidence và contract được lưu trong Git. Agent chỉ hành động trong scope đã được duyệt.

## Bắt đầu tại đây

Làm feature đầu tiên theo từng bước trong [Bắt đầu nhanh SDD + ADD](docs/sdd-add-quickstart.md). Đây là lộ trình chính cho người mới và đủ checkpoint để đi từ ý tưởng đến delivery.

```text
CONTEXT → SPEC → PLAN → TASKS → execute → verify → sync
```

## Ownership và execution

Template tách hai trục độc lập trong `.sdd/shared_context.md`:

- `Project Ownership: solo|team`: `solo` là một Human project owner; `team` là nhiều Human collaborator và là mặc định. Trục này quyết định Human review eligibility và Git delivery policy.
- `Agent Execution: direct|orchestrated`: `/add-execute` chạy `direct` trong Agent hiện tại hoặc điều phối `orchestrated` worker sau khi runtime capability được quan sát. Solo và team đều dùng được cả hai route.

Direct execution không bỏ Shadow Plan, Action Record, checkpoint, Architecture Profile hay validation. Agent không self-approve hoặc `git push`.

## Ba quy tắc cốt lõi

1. **Fix the Spec, not the Code.** Requirement thiếu hoặc mơ hồ: dùng `/sdd-update`, review lại rồi mới đổi behavior.
2. **Không suy đoán kỹ thuật.** Plan, Tasks và execution chỉ dùng binding cùng exact verification command đã `APPROVED` trong `.sdd/architecture-profile.md`.
3. **Human quyết định.** Agent không self-approve, không `git push`, không deploy và không tự thực hiện material state change.

## Chọn tài liệu theo nhu cầu

| Bạn cần | Đọc |
| :--- | :--- |
| Đi từng bước làm feature | [Bắt đầu nhanh](docs/sdd-add-quickstart.md) |
| Hiểu artifact, gate và ownership | [Hướng dẫn vận hành](docs/sdd-add-guide.md) |
| Chọn command theo tình huống | [Tra cứu nhanh](docs/sdd-add-field-guide.md) |
| Xử lý greenfield, brownfield, lỗi, handoff | [Sổ tay tình huống](docs/sdd-add-scenario-playbook.md) |
| Chọn binding và command kỹ thuật | [Hướng dẫn Hồ sơ kiến trúc](docs/architecture-profile-guide.md) |
| Thực thi task/feature và worker orchestration | [Hướng dẫn execution](docs/multi-agent-orchestration-guide.md) |

## Nguồn chuẩn

- `.claude/skills/`: command contract.
- `.claude/skills/_shared/ai-review-protocol.md`: review, methodology và Action Record.
- `.sdd/architecture-profile.md`: tech binding và exact verification command.
- `CONSTITUTION.md`: hard rule về security, architecture và quality.
- `AGENTS.md`: phạm vi/quyền của Agent.

## Tiện ích template

- `scripts/self-heal.sh`: chạy một exact approved command để thu thập evidence; không sửa source hay retry.
- `scripts/template-smoke.sh` / `.ps1`: static check file, links và policy contract.
- `scripts/adopt.*`: đưa template vào repository có sẵn.
- `scripts/update.*`: nhận template-owned update; governance files được stage để Human review.
