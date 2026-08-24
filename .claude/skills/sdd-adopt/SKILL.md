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
4. Đồng bộ `CLAUDE.md` từ profile approved; `AGENTS.md` phải giới hạn path/tool phù hợp repository; `CONSTITUTION.md` chỉ thay đổi qua RFC process.
5. Khởi tạo `.sdd/`, architecture protocol và toàn bộ slash command hiện hành.

## Reverse Spec

Khi có `--reverse-feature` và `--path`:

- Đọc source/test trong module.
- Tạo `CONTEXT.md`, `SPEC.md`, `PLAN.md`, `TASKS.md` quan sát behavior hiện tại.
- `SPEC.md` dùng EARS, bắt đầu `DRAFT`; `PLAN.md`/`TASKS.md` không tự thành `COMPLETED`.
- Chỉ thêm `@ears` vào source sau scope approval và khi binding liên quan đã approved.
- Reverse Spec mô tả behavior quan sát được, không chứng minh business behavior đúng.

## AI Recommendation và Human Final Review

Sau adoption hoặc Reverse Spec, tạo recommendation theo `.claude/skills/_shared/ai-review-protocol.md` gồm kiến trúc phát hiện, governance assumption, migration risk, độ tin cậy Reverse Spec và alternative. Lưu tại `.sdd/reviews/adopt-<slug>.md` với `PENDING HUMAN REVIEW`. Human Director/Tech Lead approve scope trước downstream work; Agent không self-approve hoặc coi legacy behavior là business-approved.
