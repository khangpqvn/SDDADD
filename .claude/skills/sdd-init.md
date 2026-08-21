---
name: sdd-init
description: Khởi tạo toàn bộ khung dự án mẫu chuẩn SDD + ADD từ đầu (Layer 1 Governance, .sdd Structure, Shared Context & Guide)
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

### 4. Khởi tạo Bộ 5 Custom SDD+ADD Skills (`.claude/skills/`)
Đảm bảo dự án có đầy đủ 5 slash commands hỗ trợ quy trình:
- `/sdd-context` — Pha 0 Context Discovery
- `/sdd-spec` — Pha 1 Executable Spec (EARS + BDD)
- `/sdd-plan` — Pha 2 Architecture Planning
- `/sdd-tasks` — Pha 3 Atomic Task Decomposition
- `/add-execute` — Pha 4 & 5 Agentic Execution & Self-Check Validation

### 5. Khởi tạo Document Hướng dẫn Vận hành (`docs/sdd-add-guide.md`)
- Xuất tài liệu hướng dẫn quy trình 5 bước phát triển tính năng cho các thành viên trong team.

### 6. Thông báo Hoàn thành & Hướng dẫn Bước Tiếp theo
Sau khi chạy xong, skill đưa ra hướng dẫn cho user gõ lệnh bắt đầu feature đầu tiên:
```bash
/sdd-context --feature=feat-001-<feature-name>
```
