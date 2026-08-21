---
name: sdd-adopt
description: Tự động phân tích dự án có sẵn (Brownfield/Existing Repo) và tích hợp khung SDD+ADD mà không làm ảnh hưởng tới code hiện tại
---

# Skill: SDD Legacy Project Adoption (`/sdd-adopt`)

Sử dụng skill này khi muốn áp dụng phương pháp luận **SDD + ADD** vào một **Repository đã có sẵn nguồn mã (Existing / Brownfield Codebase)**. Skill sẽ tự động phân tích kiến trúc hiện tại, trích xuất Architecture DNA và thiết lập bộ khung quản trị SDD phù hợp với dự án.

## Tham số
- `--stack=<tech-stack>`: (Tùy chọn) Khai báo nhanh Tech Stack chính nếu có (e.g. `NestJS + PostgreSQL + Prisma`).
- `--reverse-feature=<feature-slug>`: (Tùy chọn) Tên feature muốn đảo ngược đặc tả (Reverse-engineer Spec) từ một thư mục code có sẵn.
- `--path=<module-path>`: (Tùy chọn) Thư mục nguồn của module cần đảo ngược Spec (e.g. `src/modules/auth`).

---

## Các công việc Skill thực hiện tự động (5 Bước)

### 1. Phân tích & Trích xuất Kiến trúc Hiện tại (Codebase Scouting & Reverse Engineering)
- Scan toàn bộ thư mục root và các file cấu hình (`package.json`, `docker-compose.yml`, `tsconfig.json`, `go.mod`, `requirements.txt`, `pom.xml`, etc.).
- Nhận diện Tech Stack, Framework, Database, ORM, Test Framework và Naming Conventions đang dùng trong dự án.
- Xác định cấu trúc thư mục hiện tại (ví dụ: MVC, Modular Monolith, Microservices, Hexagonal...).

### 2. Tự động Tạo Layer 1 Governance Files Phù hợp với Dự án
- **`CLAUDE.md`**: Ghi nhận Architecture DNA đảo ngược từ codebase hiện tại, bao gồm Tech Stack, Cấu trúc thư mục thực tế, Conventions và Run/Test Commands đang dùng.
- **`AGENTS.md`**: Định nghĩa Persona và Tool Permissions phù hợp với codebase (giới hạn Agent chỉ sửa đổi các module được phép, bảo vệ các file config nhạy cảm của dự án).
- **`CONSTITUTION.md`**: Thiết lập 3 tầng Quality Gates thích ứng với codebase hiện tại (Sec, Arch, Eng Rules).

### 3. Tự động Khởi tạo Hạ tầng `.sdd/` & Skills
- Tạo cấu trúc thư mục `.sdd/`, `.sdd/features/`, `.sdd/rfcs/`.
- Tạo `.sdd/README.md` (Master Feature Registry) và `.sdd/shared_context.md`.
- Copy/Cập nhật đầy đủ bộ 9 Slash Commands vào `.claude/skills/` (`sdd-init`, `sdd-adopt`, `sdd-context`, `sdd-spec`, `sdd-plan`, `sdd-tasks`, `add-execute`, `sdd-update`, `sdd-trace`).

### 4. Đảo ngược Đặc tả cho Module có sẵn (Reverse Spec — Tùy chọn)
Nếu truyền `--reverse-feature=<slug>` và `--path=<module-path>`:
- Agent sẽ đọc source code và tests trong `<module-path>`.
- Trích xuất các Business Rules hiện có và tạo lại bộ 4 file SDD trong `.sdd/features/{slug}/`:
  - `CONTEXT.md`: Tóm tắt bài toán module hiện tại đang giải quyết.
  - `SPEC.md`: Viết lại toàn bộ Functional Requirements hiện có bằng **EARS Notation** và gán phiên bản `v1.0.0 (LOCKED)`.
  - `PLAN.md` & `TASKS.md`: Đánh dấu trạng thái `COMPLETED` cho code hiện tại.
- Gắn JSDoc tag `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX` vào các function nghiệp vụ hiện có để đảm bảo tính truy vết 100%.

### 5. Thông báo Hoàn thành & Hướng dẫn Tiếp theo
Skill xuất báo cáo chi tiết kết quả tích hợp và hướng dẫn:
- Cách dùng SDD+ADD cho các tính năng mới sắp tới (`/sdd-context --feature=feat-new`).
- Cách đảo ngược Spec cho các module cũ còn lại khi cần refactor (`/sdd-adopt --reverse-feature=<slug> --path=<path>`).
