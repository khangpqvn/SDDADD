# CLAUDE.md — Bộ nhớ dự án và kiến trúc

# Version: 1.1.0
# Project: Template khởi đầu SDD + ADD (Starter Template)

---

## 1. Mục đích

Repository là Starter Template theo **SDD** (Spec-Driven Development) và **ADD** (Agent-Driven Development). Dùng template để khởi tạo dự án mới với governance, slash command và tài liệu đặc tả chuẩn hóa.

---

## 2. Kiến trúc và cấu trúc thư mục

### 2.1 Kiến trúc chuẩn

Trạng thái Human Final Review được ghi bằng `/sdd-review`; protocol canonical nằm tại `.claude/skills/_shared/ai-review-protocol.md`.

**Nguồn sự thật kiến trúc:** `.sdd/architecture-profile.md` là profile machine-readable canonical mà SDD/ADD skills sử dụng. `CLAUDE.md` là bộ nhớ kiến trúc dành cho con người và phải phản ánh các thay đổi profile đã approved. Thứ tự chọn: profile approved → repository evidence rõ ràng → input explicit của skill → core-only baseline. Skill không được tự suy đoán HTTP framework, database, ORM/query layer, validation library hoặc test/build command chưa được chọn.

Dự án tuân thủ **Clean Architecture / Hexagonal Architecture**:

```text
src/
├── domain/         # Entity, Value Object, Domain Event thuần TypeScript
├── usecase/        # Luồng ứng dụng, business logic và port
├── interface/      # HTTP/event adapter, DTO và presenter
├── infra/          # Repository, cache và external-service adapter
└── shared/         # Error, logger, bảo mật và tiện ích dùng chung
```

### 2.2 Cấu trúc chuẩn

```text
.
├── AGENTS.md               # Constitution dành cho Agent: vai trò, phạm vi, quyền tool
├── CLAUDE.md               # Bộ nhớ dự án và kiến trúc
├── CONSTITUTION.md         # Hard governance rule và quality gate
├── .agentignore            # Tệp cần bỏ qua để giữ context sạch
├── .claude/skills/         # Slash command SDD/ADD, Git và technical skill
├── .sdd/
│   ├── README.md           # Feature registry
│   ├── architecture-profile.md # Binding công nghệ, evidence và artifact gate
│   ├── shared_context.md   # State và API contract dùng chung
│   ├── mcp-config.yaml     # MCP access control theo Agent
│   ├── template-version.md # Version template đã adopt; do adopt/update scripts quản lý
│   ├── constraints/        # Global, business và safety constraints
│   ├── reviews/            # Report và review ngoài feature
│   ├── rfcs/               # RFC thay đổi governance
│   ├── updates/            # Staged governance files chờ merge (tạm thời sau update)
│   └── features/           # Bộ CONTEXT, SPEC, PLAN, TASKS của từng feature
├── docs/
│   ├── sdd-add-guide.md
│   ├── architecture-profile-guide.md
│   └── multi-agent-orchestration-guide.md
├── scripts/
│   ├── adopt.sh / adopt.ps1       # Tích hợp vào repository có sẵn
│   ├── update.sh / update.ps1     # Cập nhật template từ nguồn gốc
│   ├── self-heal.sh               # Test, sửa có giới hạn và Human review
│   └── start-claude.sh / .ps1     # Chế độ --dangerously-skip-permissions
├── src/                    # Mã nguồn thực thi
└── tests/                  # Test suite
```

---

## 3. Nguyên tắc kiến trúc cốt lõi

- **Spec-as-Code:** Đặc tả được lưu trong Git ở Markdown có cấu trúc để con người và Agent cùng đọc/ghi.
- **EARS Notation:** Functional Requirement trong `SPEC.md` phải dùng EARS: Ubiquitous, Event-driven, State-driven, Optional hoặc Unwanted.
- **Fix the Spec, not the Code:** Khi test thất bại vì requirement thiếu, bổ sung Spec rồi mới thay đổi behavior.
- **Architecture Profile Gate:** `CONTEXT.md` và `SPEC.md` có thể core-only; `PLAN.md`, `TASKS.md`, `/add-execute` và `/sdd-layer-edit` phải dừng khi thiếu binding hoặc exact verification command cần thiết.
- **Template Update:** Repo đã adopt theo dõi version template tại `.sdd/template-version.md`. Dùng `scripts/update.sh` (Linux/macOS) hoặc `scripts/update.ps1` (Windows) để nhận thay đổi mới từ template nguồn; dùng `/sdd-template-update --check` để xem version drift và `/sdd-template-update --review` để AI hướng dẫn merge governance files.

---

## 4. Quy ước kỹ thuật và anti-pattern

### 4.1 Quy ước

- **Tên:** Tệp dùng kebab-case (`order-repository.ts`); class, interface và type dùng PascalCase (`OrderRepository`, `OrderEntity`).
- **EARS tagging:** Function/method thực thi business rule phải có JSDoc `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
- **Dependency direction:** Interface gọi usecase; usecase phụ thuộc port; infra triển khai port. Domain không phụ thuộc adapter hay third-party package.

### 4.2 Anti-pattern cần tránh

- Không truy cập DB trực tiếp từ controller/interface.
- Không dùng magic number inline; đưa vào constant hoặc configuration đã approved.
- Không vá code trực tiếp khi Spec không khớp; quay lại `.sdd/features/{slug}/SPEC.md` trước.
- Không thêm framework, ORM, package, migration hoặc command ngoài Architecture Profile đã approved.

---

## 5. Hệ thống skill — tạo mới hay sao chép (generate vs copy)

`/sdd-init` và `/sdd-adopt` **generate** governance files theo tech stack, không copy verbatim từ template. `AGENTS.md` có 8-section canonical structure (Identity, Scope, Tool Permissions, Security Rules, Communication Style, Error Handling, Escalation Protocol, Changelog). `CLAUDE.md` được điền từ project context thực tế. Xem chi tiết tại skill SKILL.md tương ứng.

ADD 4-phase pipeline: Context Setup → Intent Communication → Agentic Execution → Human Review. Human time ≈ 20% (setup + review); AI time ≈ 80% (execute). Xem `docs/sdd-add-guide.md` section 1.3.

## 6. Tài liệu tham chiếu nhanh

| Mục đích | File |
| :--- | :--- |
| **Lần đầu — bắt đầu từ đây** | `docs/sdd-add-quickstart.md` |
| Vận hành đầy đủ, review gate | `docs/sdd-add-guide.md` |
| Tra nhanh scenario → command | `docs/sdd-add-field-guide.md` |
| Kịch bản chi tiết từng bước | `docs/sdd-add-scenario-playbook.md` |
| Architecture Profile chọn stack | `docs/architecture-profile-guide.md` |
| Multi-Agent orchestration | `docs/multi-agent-orchestration-guide.md` |
| Hard rule, quality gate | `CONSTITUTION.md` |
| Agent scope & tool permission | `AGENTS.md` |
| Architecture Profile (canonical) | `.sdd/architecture-profile.md` |
