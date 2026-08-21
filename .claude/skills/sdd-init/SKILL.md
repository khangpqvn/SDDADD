---
name: sdd-init
description: Khởi tạo toàn bộ khung dự án mẫu chuẩn SDD + ADD từ đầu (Layer 1 Governance, .sdd Structure, Shared Context & Guide)
user-invocable: true
---

# Skill: SDD Initializer (`/sdd-init`)

Sử dụng skill này khi bắt đầu một dự án mới hoàn toàn (hoặc bổ sung SDD+ADD vào dự án hiện tại) để khởi tạo tự động toàn bộ khung quản trị, thư mục đặc tả và các quy tắc chất lượng.

## Tham số
- `--project-name=<name>`: (Tùy chọn) Tên dự án (e.g. `order-service`).
- `--stack=<tech-stack>`: (Tùy chọn) Công nghệ sử dụng (e.g. `Node.js + TypeScript + PostgreSQL`).

## Các công việc Skill thực hiện tự động (6 Bước)

### 1. Khởi tạo Thư mục Cấu trúc Dự án
Tạo các thư mục bắt buộc:
- `.sdd/features/`
- `.sdd/rfcs/`
- `.claude/skills/`
- `docs/`
- `scripts/`
- `src/domain/entities/`
- `src/usecase/`
- `src/interface/`
- `src/infra/`
- `src/shared/`
- `tests/`

### 2. Khởi tạo Layer 1 Governance Files (Tại Root)
- **`CONSTITUTION.md`**: Tạo bản Hiến pháp dự án với 3 tầng Quality Gates (Hard Rules, Arch Constraints, Eng Standards).
- **`AGENTS.md`**: Tạo bản Agent Constitution quy định Persona, Scope và Bảng phân quyền Tool Permissions Matrix.
- **`CLAUDE.md`**: Tạo bộ nhớ dài hạn (Project Memory) ghi nhận Tech Stack, Clean Architecture DNA và Naming Conventions.

### 3. Khởi tạo Tầng Đặc tả `.sdd/` (Master Registry & Shared Context)
- **`.sdd/README.md`**: Master Feature Registry quản lý trạng thái tất cả các features.
- **`.sdd/shared_context.md`**: Đồng bộ State và API Contracts giữa các feature.

### 4. Khởi tạo Bộ Slash Commands SDD+ADD Skills (`.claude/skills/`)
Đảm bảo dự án có đầy đủ 21 slash commands cho SDD/ADD, governance, validation và Git Operator:
- `/sdd-init` — Initializer cho Greenfield project
- `/sdd-adopt` — Adoption & Reverse Spec cho Brownfield project
- `/sdd-context` — Pha 0 Context Discovery
- `/sdd-spec` — Pha 1 Executable Spec (EARS + BDD + SemVer)
- `/sdd-plan` — Pha 2 Architecture Planning
- `/sdd-tasks` — Pha 3 Atomic Task Decomposition
- `/add-execute` — Pha 4 & 5 Agentic Execution & Self-Check Validation
- `/sdd-update` — Cập nhật đặc tả, nâng version SemVer (Major/Minor/Patch) & ghi Changelog
- `/sdd-trace` — Truy vết ma trận yêu cầu (RTM) & Phân tích tác động thay đổi Spec (Impact Analysis)

### 5. Khởi tạo Document Hướng dẫn Vận hành (`docs/sdd-add-guide.md`)
- Xuất handbook hướng dẫn lifecycle SDD + ADD, AI recommendation gates và các kịch bản vận hành cho team.

### 6. Thông báo Hoàn thành & Hướng dẫn Bước Tiếp theo
Sau khi chạy xong, skill đưa ra hướng dẫn cho user gõ lệnh bắt đầu feature đầu tiên:
```bash
/sdd-context --feature=feat-001-<feature-name>
```

---

## AI Recommendation & Human Final Review

After initialization or framework changes, generate a recommendation using `.claude/skills/_shared/ai-review-protocol.md` covering detected stack, governance assumptions, missing setup, and migration risks. Persist it in `.sdd/reviews/init.md` (or the target project's review location) with `PENDING HUMAN REVIEW`. The Human Director must approve the bootstrap/adoption scope before the first feature phase; the Agent must not claim the project is approved or self-approve.
