---
name: sdd-layer-edit
description: Chỉnh sửa luồng nghiệp vụ xuyên Domain, Usecase, Interface và Infra theo Architecture Profile
user-invocable: true
---

# SDD Cross-Layer Editor (`/sdd-layer-edit`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`), `@ears` references, file paths, and CLI commands are language-invariant.

Dùng để thêm hoặc thay đổi business flow xuyên Clean Architecture, giữ contract: interface gọi usecase; usecase phụ thuộc domain và port; infra triển khai port.

## Architecture Profile gate (BLOCKING)

Tuân thủ [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md).

- Đọc profile, constraint, feature `SPEC.md`, `PLAN.md`, `TASKS.md` và review block trước thay đổi.
- Domain/usecase có thể được plan bằng core-only TypeScript. Interface/infra chỉ sinh/sửa adapter khi HTTP framework, validation, database hoặc ORM/query layer tương ứng đã selected, evidenced và `APPROVED`.
- Thiếu binding, exact test/build/lint command hoặc Human Final Review: dừng, lưu `PENDING HUMAN REVIEW`. Không sinh controller, repository, migration, DTO decorator, cache client hoặc command suy đoán.
- Xuất Shadow Plan gồm profile evidence, file scope, exact command và risk; chờ Human Director `APPROVED` trước edit.

## Tham số

- `--feature=<feature-slug>`: Feature chứa Spec tương ứng.
- `--action=<add|modify|refactor>`: Loại thay đổi.
- `--target=<name>`: Usecase hoặc Entity mục tiêu, ví dụ `CreateOrder`.

## Layer boundary

1. **Domain (`src/domain/`)**: Entity, Value Object hoặc Domain Event thuần TypeScript; không import third-party package hoặc adapter.
2. **Usecase (`src/usecase/`)**: Interactor/Application Service và port cho repository/external service; business method có `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
3. **Interface (`src/interface/`)**: Chỉ dùng transport, validation, authentication adapter đã approved; chỉ gọi usecase, không gọi DB/repository trực tiếp.
4. **Infra (`src/infra/`)**: Triển khai port bằng DB/cache/external client đã approved; cấm hardcode API key/password, raw `DELETE` không `WHERE` và thao tác trái safety constraint.

## AI Recommendation và Human Final Review

Trước edit, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm requirement, boundary, file, risk, alternative và verification. Lưu trong feature artifact/review với `Human Final Review.Status: PENDING`. Human Director phải `APPROVED` execution scope; sau edit refresh recommendation và không tự approve.
