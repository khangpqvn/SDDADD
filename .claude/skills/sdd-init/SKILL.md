---
name: sdd-init
description: Khởi tạo template SDD + ADD, Architecture Profile, governance và cấu trúc dự án
user-invocable: true
---

# SDD Initializer (`/sdd-init`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`), file paths, and CLI commands are language-invariant.

Dùng khi khởi tạo dự án mới hoặc bổ sung khung SDD + ADD vào dự án hiện tại.

## Tham số

- `--project-name=<name>`: Tùy chọn; tên dự án, ví dụ `order-service`.
- `--stack=<tech-stack>`: Tùy chọn; chỉ nêu binding đã biết, ví dụ `Node.js + TypeScript + PostgreSQL`.

## Architecture Profile

`/sdd-init` phải tạo `.sdd/architecture-profile.md` và dùng profile này làm nguồn sự thật cho artifact sinh ra.

- Chỉ parse `--stack` thành binding được nêu explicit. `Node.js + TypeScript + PostgreSQL` không tự chọn HTTP framework, ORM, validation hoặc test command.
- Không có `--stack` thì chỉ seed core-only baseline: TypeScript + Node.js + Clean Architecture.
- Ghi evidence, binding chưa chọn và canonical block `PENDING HUMAN REVIEW` vào profile.
- `/sdd-context` và `/sdd-spec` được tiếp tục với binding chưa chọn. `/sdd-plan`, `/sdd-tasks` và implementation bị block đến khi binding/command cần thiết được approved.
- `CLAUDE.md` phản ánh architecture decision đã approved; skill đọc profile, không suy đoán từ prose.

## Các bước

1. Tạo `.sdd/features/`, `.sdd/reviews/`, `.sdd/rfcs/`, `.claude/skills/`, `docs/`, `scripts/`, `src/{domain,usecase,interface,infra,shared}/` và `tests/`.
2. **Generate governance files theo tech stack** (xem nguyên tắc Generate vs Copy bên dưới):
   - `CONSTITUTION.md` — giữ cấu trúc 3-layer chuẩn; tùy chỉnh Layer 3 ENG-03 với exact test/lint/build command của stack nếu đã biết.
   - `AGENTS.md` — generate 8 sections đầy đủ phù hợp tech stack.
   - `CLAUDE.md` — generate với TL;DR, Architecture, File Structure, Lesson Learned và Current Sprint Focus phù hợp project.
   - `.agentignore` — generate pattern loại trừ build artifact đúng ngôn ngữ/framework.
   - `.gitignore` — generate theo tech stack; không copy file `.gitignore` của template.
3. Khởi tạo `.sdd/README.md`, `.sdd/architecture-profile.md`, `.sdd/shared_context.md`, `.sdd/mcp-config.yaml` và `.sdd/constraints/` (global, business, safety).
4. Cài bộ slash command SDD/ADD, Git và technical skill từ template hiện hành.
5. Cài `docs/sdd-add-guide.md`, `docs/architecture-profile-guide.md`, `docs/multi-agent-orchestration-guide.md` và script hỗ trợ.
6. Hướng dẫn bắt đầu feature bằng `/sdd-context --feature=feat-001-<feature-name>`.

`/sdd-review` không thay thế `/sdd-rfc --approve=<rfc-number>` khi thay đổi `CONSTITUTION.md`.

## Generate vs Copy — Nguyên tắc quan trọng

Các governance file **phải được generate theo tech stack** của dự án, không phải copy verbatim từ template. Lý do: AGENTS.md của một dự án Go/gRPC có persona, tool permissions và forbidden paths khác với TypeScript/REST; `.agentignore` của Next.js loại `.next/` nhưng Go loại `bin/`; CLAUDE.md phải phản chiếu lesson learned thực của dự án, không phải placeholder chung.

### AGENTS.md — 8 sections bắt buộc

Generate đầy đủ 8 sections, tùy chỉnh theo stack:

1. **Identity & Persona** — Seniority level, ngôn ngữ chính, philosophy (Go: explicit > implicit; TypeScript: type safety first; Python: readability).
2. **Scope & Boundaries** — Path đọc/ghi theo project layout thực tế; không dùng `src/` nếu project dùng cấu trúc khác.
3. **Tool Permissions** — Exact commands của stack: Go dùng `go test`, `go vet`, `golangci-lint`; TypeScript dùng `npm test`, `eslint`, `tsc`. Chỉ điền sau khi binding đã confirmed.
4. **Security Rules** — Zero secret policy, input validation tại boundary, data masking — giữ nguyên.
5. **Communication Style** — Ngôn ngữ output, định dạng báo cáo, cách đặt câu hỏi khi không rõ.
6. **Error Handling** — Quy trình khi test fail, khi Spec mơ hồ, khi gặp conflict.
7. **Escalation Protocol** — Khi nào dừng và hỏi Human Director; khi nào tự xử lý; khi nào RFC.
8. **Changelog** — Semantic versioning cho mọi thay đổi AGENTS.md; review required.

### CLAUDE.md — 4 sections cốt lõi

Generate với content phù hợp project, không placeholder:

1. **TL;DR (30 giây)** — Mô tả ngắn project: loại service, giao thức chính, dependency quan trọng.
2. **Architecture** — Pattern (Clean/Hexagonal/MVC), file structure thực, dependency direction rules.
3. **Lesson Learned** — Để trống hoặc seed với 1–2 mục từ context `--stack`; format `[YYYY-MM]`.
4. **Current Sprint Focus** — Để trống hoặc điền feature đầu tiên.

### .agentignore — Generate theo stack

| Stack | Patterns cần loại trừ |
| :--- | :--- |
| Node.js / TypeScript | `node_modules/`, `dist/`, `.next/`, `build/`, `coverage/`, `*.tsbuildinfo` |
| Go | `bin/`, `vendor/` (nếu dùng), `*.test` binary, `tmp/` |
| Python | `__pycache__/`, `*.pyc`, `.venv/`, `dist/`, `*.egg-info/` |
| Java / Kotlin | `target/`, `build/`, `*.class`, `.gradle/` |
| Rust | `target/` |
| Common (luôn có) | `.env`, `.env.*`, `*.pem`, `*.key`, `secrets/`, `.git/` |

### .gitignore — Generate theo stack

Dùng template `.gitignore` chuẩn của ngôn ngữ/framework (gitignore.io style); không copy `.gitignore` của template SDD vốn chỉ phù hợp Node.js. Nếu project đã có `.gitignore`, chỉ bổ sung pattern `.sdd/updates/` và không xóa pattern hiện tại.

### CONSTITUTION.md — Tùy chỉnh nhẹ Layer 3

Giữ nguyên Layer 1 (Hard Rules) và Layer 2 (Architectural Constraints). Chỉ điều chỉnh:
- `ENG-03` verification command: thay placeholder bằng exact command của stack nếu đã biết.
- Nếu binding chưa confirmed, ghi `[PENDING HUMAN REVIEW — verification command chưa được chọn]` thay vì để trống.

## AI Recommendation và Human Final Review

Sau khởi tạo hoặc thay đổi framework, tạo recommendation theo `.claude/skills/_shared/ai-review-protocol.md` gồm detected stack, governance assumption, missing setup và migration risk. Lưu tại `.sdd/reviews/init.md` với `PENDING HUMAN REVIEW`. Human Director approve bootstrap/adoption scope trước pha feature đầu tiên; Agent không self-approve hoặc tuyên bố dự án đã approved.
