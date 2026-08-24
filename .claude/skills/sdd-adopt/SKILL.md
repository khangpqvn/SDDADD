---
name: sdd-adopt
description: Khảo sát repository có sẵn, tạo Architecture Profile và tích hợp SDD + ADD không làm thay đổi source hiện có
user-invocable: true
---

# SDD Brownfield Adoption (`/sdd-adopt`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`, `CONFIGURATION GAP`), file paths, and CLI commands are language-invariant.

Dùng để áp dụng SDD + ADD vào repository có source code sẵn hoặc tạo Reverse Spec cho module legacy.

## Tham số

- `--stack=<tech-stack>`: Tùy chọn; stack đã biết, ví dụ `NestJS + PostgreSQL + Prisma`.
- `--reverse-feature=<feature-slug>`: Tùy chọn; feature cần Reverse Spec.
- `--path=<module-path>`: Tùy chọn; path module nguồn, ví dụ `src/modules/auth`.

## Các bước

1. Kiểm tra root, manifest, lockfile, runtime/bootstrap config, DB/migration config, CI, test config và source layout.
2. Tạo/cập nhật `.sdd/architecture-profile.md`; mỗi runtime, framework, DB, ORM, validation, test/build/lint command phải có evidence, confidence, conflict và `PENDING HUMAN REVIEW`.
3. Resolve binding theo thứ tự: profile approved → repository evidence rõ ràng → `--stack` explicit → core-only baseline. Mâu thuẫn thì dừng; không ghi đè profile approved.
4. **Generate governance files theo stack thực tế** (xem nguyên tắc Generate vs Copy bên dưới): `CLAUDE.md`, `AGENTS.md` phải giới hạn path/tool phù hợp repository; `CONSTITUTION.md` chỉ thay đổi qua RFC process.
5. Khởi tạo `.sdd/`, architecture protocol và toàn bộ slash command hiện hành.

## Generate vs Copy — Nguyên tắc quan trọng

Với brownfield adoption, các governance file **phải phản chiếu repository thực** — persona, path, command và anti-pattern học được từ codebase hiện có — không phải copy verbatim từ template. Điều này đặc biệt quan trọng vì:
- Project đã có convention riêng (naming, error handling, test patterns) → AGENTS.md phải capture những điều này
- Build/lint/test command đã xác định từ CI → CONSTITUTION.md ENG-03 có thể điền exact command ngay
- Lesson learned có thể seed từ PR history, commit message, incident log

### AGENTS.md — Generate từ repository evidence

Survey repository trước khi generate:

1. **Identity & Persona**: Detect ngôn ngữ chính, framework, test runner. Generate persona phù hợp (Go developer ≠ TypeScript developer — philosophy, style guide, idioms khác nhau).
2. **Scope & Boundaries**: Dùng path thực của repository. Nếu project dùng `app/`, `lib/`, `pkg/` thay vì `src/` — reflect đúng thực tế.
3. **Tool Permissions**: Điền exact command từ CI/Makefile/package.json scripts đã verified. Ví dụ: nếu CI chạy `make test`, ghi `make test`, không ghi `npm test`.
4. **Security Rules**: Giữ Zero Secret Policy. Thêm constraint đặc thù nếu phát hiện (ví dụ: project có `.env.vault` → ghi rõ không được commit `.env.vault`).
5. **Communication Style**: Mirroring language rule + format báo cáo.
6. **Error Handling**: Quy trình khi test fail, Spec mơ hồ, conflict.
7. **Escalation Protocol**: Khi nào dừng và báo Human Director.
8. **Changelog**: Seed với version 1.0.0 + timestamp adoption.

### CLAUDE.md — Generate từ codebase thực

Không dùng placeholder. Điền từ repository evidence:

1. **TL;DR**: Viết mô tả ngắn dựa trên README, package.json description, module chính.
2. **Architecture**: Detect pattern thực (thư mục `domain/`, `usecase/` → Clean Architecture; `modules/` → Modular Monolith; ...). Ghi file structure thực.
3. **Lesson Learned**: Seed từ PR/commit history nếu có pattern nổi bật (ví dụ: nhiều commit fix N+1, deadlock, auth bug). Format `[YYYY-MM] Vấn đề — Fix đã áp dụng`.
4. **Current Sprint Focus**: Để trống hoặc điền nếu `--reverse-feature` được cung cấp.

### .agentignore — Generate theo stack thực

Scan build artifact, cache directory và generated file trong repository; thêm vào pattern chuẩn theo ngôn ngữ. Ví dụ: nếu repository có `coverage/` directory → thêm. Nếu có Prisma → thêm `prisma/migrations/*.js` (generated). Không copy `.agentignore` của template.

### .gitignore — Bổ sung, không ghi đè

Nếu repository đã có `.gitignore`, chỉ thêm pattern liên quan SDD (`.sdd/updates/`) mà chưa có. Không xóa hoặc thay thế. Nếu chưa có `.gitignore`, generate theo stack phát hiện.

### CONSTITUTION.md — Tùy chỉnh nhẹ, không ghi đè sau RFC

Nếu repository chưa có `CONSTITUTION.md`:
- Generate với 3-layer structure chuẩn
- Điền exact verification command (ENG-03) từ CI evidence nếu có

Nếu repository đã có `CONSTITUTION.md` (từ lần adopt trước hoặc manual):
- Không ghi đè Layer 1/2 đã approved
- Chỉ bổ sung thiếu với recommendation `PENDING HUMAN REVIEW`
- Layer 1/2 thay đổi cần RFC theo `/sdd-rfc`

## Reverse Spec

Khi có `--reverse-feature` và `--path`:

- Đọc source/test trong module.
- Tạo `CONTEXT.md`, `SPEC.md`, `PLAN.md`, `TASKS.md` quan sát behavior hiện tại.
- `SPEC.md` dùng EARS, bắt đầu `DRAFT`; `PLAN.md`/`TASKS.md` không tự thành `COMPLETED`.
- Chỉ thêm `@ears` vào source sau scope approval và khi binding liên quan đã approved.
- Reverse Spec mô tả behavior quan sát được, không chứng minh business behavior đúng.

## AI Recommendation và Human Final Review

Sau adoption hoặc Reverse Spec, tạo recommendation theo `.claude/skills/_shared/ai-review-protocol.md` gồm kiến trúc phát hiện, governance assumption, migration risk, độ tin cậy Reverse Spec và alternative. Lưu tại `.sdd/reviews/adopt-<slug>.md` với `PENDING HUMAN REVIEW`. Human Director/Tech Lead approve scope trước downstream work; Agent không self-approve hoặc coi legacy behavior là business-approved.
