---
name: sdd-tasks
description: Pha 3 SDD — phân rã PLAN.md thành TASKS.md có ownership, dependency và verification command
user-invocable: true
---

# SDD Phase 3 — Task Decomposition (`/sdd-tasks`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `PENDING`, `APPROVED`), `@ears` references, file paths, and CLI commands are language-invariant.

Dùng `PLAN.md` đã approved để tạo `.sdd/features/{feature-slug}/TASKS.md`.

## Tham số

- `--feature=<feature-slug>`: Feature identifier.

## Architecture Profile gate (BLOCKING)

- Tuân thủ [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md).
- Đọc profile và `PLAN.md` đã approved trước khi sinh task.
- Chỉ ghi exact path, package, migration, config và command có profile evidence.
- `TASKS.md` bị block nếu thiếu test/build/lint command hoặc feature binding cần thiết. Không dùng `npm test` làm giá trị thay thế.
- Mỗi task phải nêu architecture layer, profile binding, `@ears` reference và exact verification command.

## Các bước

1. Phân rã task theo ba tiêu chí: Atomic, Independent và Verifiable.
2. Gắn requirement `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX` cho business behavior.
3. Cập nhật `.sdd/shared_context.md` với API contract dùng chung, chỉ dùng syntax adapter đã approved.
4. Ghi dependency, ownership, file boundary, command, risk và tạo recommendation.

## DoD

- [ ] Task atomic, independent hoặc có `blockedBy`, và verifiable.
- [ ] Task có path, layer, profile binding, requirement và command.
- [ ] Không task nào vượt Out of Scope.
- [ ] Shared contract đã đồng bộ khi applicable.
- [ ] Human Final Review `APPROVED` trước `/add-execute`.

## AI Recommendation và Human Final Review

Sau khi tạo/sửa `TASKS.md`, lưu canonical recommendation gồm thứ tự task, dependency, file, verification command và delivery risk. Giữ `Human Final Review.Status: PENDING`; `/add-execute` không được bắt đầu đến khi Human Director ghi `APPROVED`. Agent không tự approve task plan.
