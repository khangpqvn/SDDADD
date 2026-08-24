---
name: sdd-update
description: Cập nhật SPEC.md của feature — bump SemVer, thêm/sửa requirement, invalidate review cũ và chuẩn bị recommendation mới
user-invocable: true
---

# SDD Spec Update (`/sdd-update`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`, `APPROVED & LOCKED`, `DRAFT`), EARS keywords, `REQ-XXX` identifiers, SemVer, file paths, and CLI commands are language-invariant.

Dùng khi cần sửa `SPEC.md` sau khi đã lock — thêm requirement mới, làm rõ edge case, sửa behavior hoặc đổi contract. Skill invalidate review cũ, bump SemVer và tạo recommendation mới để Human Director review lại trước khi execute.

## Tham số

- `--feature=<feature-slug>`: Feature identifier. Bắt buộc.
- `--bump=<patch|minor|major>`: Loại thay đổi SemVer. Bắt buộc.
- `--reason=<mô-tả>`: Lý do cập nhật. Bắt buộc.

## Chọn bump đúng

| Loại thay đổi | Bump |
| :--- | :--- |
| Làm rõ behavior đã có, thêm error case, clarify edge case không phá contract | `patch` |
| Thêm behavior tương thích ngược, thêm optional flow hoặc NFR mới | `minor` |
| Thay đổi API, DB schema, data contract hoặc behavior không tương thích ngược | `major` |

`--bump=major` bắt buộc phải ghi migration plan, rollback plan và risk trong Spec trước khi Agent được execute downstream.

## Architecture Profile preflight

Tuân thủ [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md).

- Đọc profile và governance trước khi sửa Spec.
- Requirement bổ sung technology-neutral; không sinh ORM decorator, HTTP route, framework schema hoặc command chưa approved.
- Binding chưa resolve vẫn được phép trong Spec nhưng phải là `PLAN.md` planning blocker.

## Quy trình

1. Đọc `SPEC.md` hiện tại, `CONTEXT.md`, `CONSTITUTION.md` và Architecture Profile.
2. Đặt header Spec về `Status: DRAFT` nếu đang ở `APPROVED & LOCKED`.
3. Thêm/sửa requirement theo EARS; cập nhật BDD, error behavior, acceptance và Out of Scope liên quan.
4. Bump version theo SemVer và ghi changelog entry:
   ```markdown
   ### vX.Y.Z (YYYY-MM-DD)
   - <reason>: <mô tả thay đổi>
   ```
5. Invalidate recommendation cũ: đặt `AI Agent Recommendation.Status` về `PENDING HUMAN REVIEW` với changed scope làm evidence.
6. Tạo recommendation mới gồm requirement gap, EARS risk, edge case, Out of Scope impact và SemVer impact.
7. Xác định artifact bị ảnh hưởng: `PLAN.md`, `TASKS.md`, `@ears` trong `src/`, test liên quan.

## DoD

- [ ] SemVer bumped đúng loại thay đổi.
- [ ] Mọi requirement mới/sửa dùng EARS.
- [ ] Changelog entry ghi rõ.
- [ ] `Status: DRAFT` — không còn `APPROVED & LOCKED`.
- [ ] Recommendation mới ở `PENDING HUMAN REVIEW`.
- [ ] Artifact bị ảnh hưởng đã được liệt kê.

## AI Recommendation và Human Final Review

Sau khi cập nhật `SPEC.md`, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm requirement thay đổi, artifact bị ảnh hưởng, EARS/SemVer risk, edge case và downstream impact. Giữ `Human Final Review.Status: PENDING`; `/sdd-plan`, `/sdd-tasks` và `/add-execute` bị block đến khi Human Director ghi `APPROVED` và lock lại. Agent không tự approve Spec đã sửa.

## Ví dụ

```text
/sdd-update --feature=feat-user-register --bump=patch --reason="Add OTP rate-limit behavior"
/sdd-update --feature=feat-user-register --bump=minor --reason="Add optional recovery flow"
/sdd-update --feature=feat-user-register --bump=major --reason="Change registration contract"
```

Sau khi Human Director approve và lock Spec mới, nếu Plan/Tasks bị ảnh hưởng thì phải chạy lại `/sdd-plan` hoặc cập nhật `TASKS.md` trước khi `/add-execute`.
