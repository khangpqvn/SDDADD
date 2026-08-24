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
2. Khởi tạo `CONSTITUTION.md`, `AGENTS.md`, `CLAUDE.md`, `.agentignore` và `.sdd/constraints/`.
3. Khởi tạo `.sdd/README.md`, `.sdd/architecture-profile.md`, `.sdd/shared_context.md`, `.sdd/mcp-config.yaml`.
4. Cài bộ slash command SDD/ADD, Git và technical skill từ template hiện hành.
5. Cài `docs/sdd-add-guide.md`, `docs/architecture-profile-guide.md`, `docs/multi-agent-orchestration-guide.md` và script hỗ trợ.
6. Hướng dẫn bắt đầu feature bằng `/sdd-context --feature=feat-001-<feature-name>`.

`/sdd-review` không thay thế `/sdd-rfc --approve=<rfc-number>` khi thay đổi `CONSTITUTION.md`.

## AI Recommendation và Human Final Review

Sau khởi tạo hoặc thay đổi framework, tạo recommendation theo `.claude/skills/_shared/ai-review-protocol.md` gồm detected stack, governance assumption, missing setup và migration risk. Lưu tại `.sdd/reviews/init.md` với `PENDING HUMAN REVIEW`. Human Director approve bootstrap/adoption scope trước pha feature đầu tiên; Agent không self-approve hoặc tuyên bố dự án đã approved.
