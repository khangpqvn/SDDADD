---
name: sdd-spec
description: Pha 1 SDD — tạo SPEC.md với EARS, SemVer, BDD, error contract và DoD
user-invocable: true
---

# SDD Phase 1 — Specification (`/sdd-spec`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `PENDING`, `APPROVED`, `APPROVED & LOCKED`, `DRAFT`), EARS keywords (`WHEN`, `WHILE`, `WHERE`, `IF`, `THEN`, `SHALL`), file paths, and CLI commands are language-invariant.

Dùng `CONTEXT.md` và `CONSTITUTION.md` để tạo `.sdd/features/{feature-slug}/SPEC.md`.

## Tham số

- `--feature=<feature-slug>`: Feature identifier.
- `--bump=<major|minor|patch>`: Dùng khi cập nhật Spec.

## Architecture Profile preflight

Tuân thủ [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md).

- Đọc profile trước Context và Constitution.
- `SPEC.md` chỉ mô tả behavior, data contract, error và NFR; không sinh ORM decorator, framework schema, package hoặc CLI command chưa approved.
- Ghi profile version và binding feature cần dùng.
- Binding chưa resolve được phép trong Spec nhưng phải là planning blocker; `PLAN.md` dừng đến khi Human Director approve.

## Các bước

1. Đọc Context và Constitution.
2. Ghi SemVer và `Status: DRAFT`.
3. Viết Functional Requirement bằng EARS: `THE`, `WHEN`, `WHILE`, `WHERE`, `IF ... THEN ... SHALL`.
4. Viết technology-neutral data contract, BDD scenario, error behavior và NFR có thể đo.
5. Nêu Out of Scope để chặn scope creep.
6. Kiểm tra DoD, cập nhật changelog và tạo recommendation.

## DoD

- [ ] Có Context, actor, Functional Requirement, NFR, data, error, acceptance, Out of Scope.
- [ ] Mọi Functional Requirement dùng EARS.
- [ ] Có edge case và error behavior cần thiết.
- [ ] Open question quan trọng đã resolve hoặc nêu rõ.
- [ ] SemVer/changelog đúng và Human Final Review đã `APPROVED` trước lock.

## AI Recommendation và Human Final Review

Sau khi tạo/sửa `SPEC.md`, lưu canonical recommendation trong artifact, gồm requirement gap, EARS risk, edge case, Out of Scope và SemVer impact. Giữ `Human Final Review.Status: PENDING`; `/sdd-plan` bị block đến khi Human Director ghi `APPROVED`. Agent không được đặt `APPROVED & LOCKED` thay con người.
