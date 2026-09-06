# CLAUDE.md — Bộ nhớ dự án và kiến trúc

# Version: 1.1.0
# Project: Template khởi đầu SDD + ADD (Starter Template)

## Mục đích

Repository là Starter Template theo **SDD** (Spec-Driven Development) và **ADD** (Agent-Driven Development). Template tạo governance, slash command và đặc tả chuẩn hóa để Human quyết định còn Agent thực thi có evidence.

## Kiến trúc và cấu trúc

### Nguồn chuẩn

- `.sdd/architecture-profile.md` là profile machine-readable canonical cho tech binding và exact verification command.
- `.claude/skills/_shared/ai-review-protocol.md` là protocol canonical cho Human Final Review, Methodology Profile, Describe-back và Action Record.
- `.sdd/shared_context.md` canonicalize hai trục độc lập: `Project Ownership` (Human governance/delivery) và `Agent Execution` (direct/orchestrated worker route). `team` là mặc định cho ownership; solo vẫn có thể orchestration nhiều Agent.
- `CLAUDE.md` phản ánh kiến trúc đã approved cho con người đọc; không tự chọn stack.
- Thứ tự chọn binding: profile approved → repository evidence rõ ràng → input explicit → core-only baseline.

Skill không được tự suy đoán HTTP framework, database, ORM/query layer, validation library hoặc test/build command chưa được chọn.

### Clean Architecture / Hexagonal Architecture

```text
src/
├── domain/         # Entity, Value Object, Domain Event thuần TypeScript
├── usecase/        # Luồng ứng dụng, business logic và port
├── interface/      # HTTP/event adapter, DTO và presenter
├── infra/          # Repository, cache và external-service adapter
└── shared/         # Error, logger, bảo mật và tiện ích dùng chung
```

### Cấu trúc chính

```text
.
├── AGENTS.md
├── CLAUDE.md
├── CONSTITUTION.md
├── .agentignore
├── .claude/skills/             # SDD/ADD, Git và technical command contract
├── .sdd/
│   ├── README.md               # Feature registry
│   ├── architecture-profile.md # Binding, evidence, artifact gate
│   ├── shared_context.md       # Shared state/API contract
│   ├── mcp-config.yaml         # MCP policy; không chứng minh host enforcement
│   ├── constraints/            # Global, business, safety constraints
│   ├── reviews/                # Review ngoài feature, gồm post-code review
│   └── features/               # CONTEXT, SPEC, PLAN, TASKS
├── docs/
│   ├── sdd-add-quickstart.md   # Lộ trình chính từng bước
│   ├── sdd-add-guide.md        # Artifact, gate, ownership reference
│   ├── sdd-add-field-guide.md  # Tình huống → action reference
│   ├── sdd-add-scenario-playbook.md
│   ├── architecture-profile-guide.md
│   └── multi-agent-orchestration-guide.md
├── scripts/
│   ├── adopt.sh / adopt.ps1
│   ├── update.sh / update.ps1
│   ├── self-heal.sh
│   └── template-smoke.sh / template-smoke.ps1
├── src/
└── tests/
```

## Nguyên tắc cốt lõi

- **Spec-as-Code:** đặc tả có cấu trúc nằm trong Git.
- **Fix the Spec, not the Code:** requirement thiếu/mơ hồ phải update/review Spec trước behavior.
- **EARS:** Functional Requirement trong `SPEC.md` dùng EARS.
- **Architecture Profile Gate:** Context/Spec có thể core-only; Plan/Tasks/`/add-execute`/`/sdd-layer-edit` dừng khi thiếu binding hoặc exact command.
- **Human gate:** Agent không self-approve. Review phải persisted; chat không thay thế review.
- **Task sizing:** khoảng bốn giờ là signal để split task hoặc ghi Human-approved exception; không là bypass gate.
- **Delivery review:** source/test/contract/config/schema/state changes cần post-code Human review trước Git `READY`.

## Quy ước và anti-pattern

- Tệp dùng kebab-case; class/interface/type dùng PascalCase.
- Business method thực thi rule có `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
- Interface gọi usecase; usecase phụ thuộc port; infra triển khai port; domain không phụ thuộc adapter/third-party package.
- Không truy cập DB trực tiếp từ controller/interface.
- Không thêm framework, ORM, package, migration hoặc command ngoài Architecture Profile approved.
- Không vá code khi Spec không khớp.

## Self-heal safety boundary

`scripts/self-heal.sh` chỉ thu thập evidence cho `implementation-defect`: chạy **một** exact approved command với `--max-attempts=1`. Script không edit source, repair, retry, self-approve, commit, push hoặc deploy.

## Template lifecycle

`/sdd-init` và `/sdd-adopt` generate governance theo repository evidence; không copy manifest-specific command suy đoán. Repo đã adopt dùng `scripts/update.sh` hoặc `scripts/update.ps1`; `/sdd-template-update --check` xem version drift và `--review` hướng dẫn merge staged governance files. Không sửa `.sdd/architecture-profile.md` chỉ để cập nhật template.

## Tài liệu

| Mục đích | File |
| :--- | :--- |
| Lần đầu, làm từng bước | `docs/sdd-add-quickstart.md` |
| Artifact, gate, ownership | `docs/sdd-add-guide.md` |
| Tình huống → command | `docs/sdd-add-field-guide.md` |
| Recovery, handoff, delivery | `docs/sdd-add-scenario-playbook.md` |
| Binding/command | `docs/architecture-profile-guide.md` |
| Agent execution và dispatch | `docs/multi-agent-orchestration-guide.md` |
