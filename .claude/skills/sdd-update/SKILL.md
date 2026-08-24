---
name: sdd-update
description: Cập nhật artifact SDD của feature (SPEC.md, CONTEXT.md, PLAN.md hoặc TASKS.md) sau khi đã approved — bump SemVer cho Spec, invalidate review cũ và chuẩn bị recommendation mới
user-invocable: true
---

# SDD Artifact Update (`/sdd-update`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`, `APPROVED & LOCKED`, `DRAFT`), EARS keywords, `REQ-XXX` identifiers, SemVer, file paths, and CLI commands are language-invariant.

Dùng khi cần sửa artifact SDD đã approved mà không sinh lại từ đầu.

## Khi nào dùng skill này

| Tình huống | Lệnh đúng |
| :--- | :--- |
| `SPEC.md` đã `APPROVED & LOCKED`, cần sửa/thêm requirement | `/sdd-update --artifact=spec` |
| `CONTEXT.md` đã approved, stakeholder hoặc constraint thay đổi | `/sdd-update --artifact=context` |
| `PLAN.md` đã approved, cần sửa component/risk mà Spec không đổi | `/sdd-update --artifact=plan` |
| `TASKS.md` đã approved, cần thêm/sửa task mà Plan không đổi | `/sdd-update --artifact=tasks` |
| `SPEC.md` vẫn ở `DRAFT`, cần sửa trong lần đầu | `/sdd-spec` — không cần `/sdd-update` |
| Context thay đổi lớn, làm lại từ đầu | `/sdd-context` rồi `/sdd-spec` |
| Sửa xuyên nhiều artifact do breaking change | `/sdd-update --artifact=spec --bump=major` → review → rồi `/sdd-plan`, `/sdd-tasks` |

## Tham số

- `--feature=<feature-slug>`: Feature identifier. Bắt buộc.
- `--artifact=<spec|context|plan|tasks>`: Artifact cần cập nhật. Mặc định: `spec`.
- `--bump=<patch|minor|major>`: Loại thay đổi SemVer. Bắt buộc khi `--artifact=spec`.
- `--reason=<mô-tả>`: Lý do cập nhật. Bắt buộc. Khuyến khích gắn REQ-XXX khi áp dụng, ví dụ `"[REQ-003] Add OTP rate-limit: max 5 attempts per 10 minutes"`.

## Chọn bump đúng (chỉ áp dụng cho `--artifact=spec`)

| Loại thay đổi | Bump |
| :--- | :--- |
| Làm rõ behavior đã có, thêm error case, clarify edge case không phá contract | `patch` |
| Thêm behavior tương thích ngược, thêm optional flow hoặc NFR mới | `minor` |
| Thay đổi API, DB schema, data contract hoặc behavior không tương thích ngược | `major` |

`--bump=major` bắt buộc phải ghi migration plan, rollback plan và risk trong Spec trước khi Agent được execute downstream.

## Architecture Profile preflight

Tuân thủ [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md).

- Đọc profile và governance trước khi sửa artifact.
- Requirement bổ sung phải technology-neutral; không sinh ORM decorator, HTTP route, framework schema hoặc command chưa approved.
- Binding chưa resolve vẫn được phép trong Spec nhưng phải là `PLAN.md` planning blocker.

## Clarification-First — bắt buộc trước khi thêm requirement hoặc sửa behavior

Trước khi viết thay đổi, liệt kê điểm chưa chắc chắn theo 3 loại:

1. **Business logic gaps** — Rule mới/sửa có assumption nào chưa được xác nhận?
2. **Constraint kỹ thuật** — NFR thêm vào có giá trị đo được chưa? (timeout, rate limit, threshold)
3. **Edge case chưa xử lý** — Thay đổi này ảnh hưởng tình huống nào đang có trong Spec?

Dừng và chờ Human Director confirm trước khi ghi thay đổi. Nếu được phép tiếp tục với assumption, ghi rõ assumption đó trong artifact.

## Quy trình

### Khi `--artifact=spec`

1. Đọc `SPEC.md` hiện tại, `CONTEXT.md`, `CONSTITUTION.md` và Architecture Profile.
2. Chạy Clarification-First; chờ confirm.
3. Đặt header Spec về `Status: DRAFT` nếu đang ở `APPROVED & LOCKED`.
4. Thêm/sửa requirement theo EARS; cập nhật BDD, error behavior, acceptance và Out of Scope liên quan.
5. Bump version theo SemVer và ghi changelog entry:
   ```markdown
   ### vX.Y.Z (YYYY-MM-DD)
   - <reason>: <mô tả thay đổi>, ảnh hưởng: <REQ-XXX hoặc section>
   ```
6. Invalidate recommendation cũ: đặt `AI Agent Recommendation.Status` về `PENDING HUMAN REVIEW` với changed scope làm evidence.
7. Tạo recommendation mới gồm requirement gap, EARS risk, edge case, Out of Scope impact và SemVer impact.
8. Xác định artifact bị ảnh hưởng downstream: `PLAN.md`, `TASKS.md`, `@ears` trong `src/`, test liên quan, và có cần `/sdd-sync` không.

### Khi `--artifact=context`

1. Đọc `CONTEXT.md` hiện tại và `SPEC.md` để hiểu phạm vi đang lock.
2. Chạy Clarification-First cho thay đổi context.
3. Cập nhật section bị ảnh hưởng (stakeholder, constraint, glossary, open question).
4. Xác định Spec requirement nào cần review lại do context thay đổi; ghi rõ trong recommendation.
5. Invalidate recommendation cũ và tạo recommendation mới.

### Khi `--artifact=plan`

1. Đọc `PLAN.md` hiện tại, `SPEC.md` `APPROVED & LOCKED` và Architecture Profile.
2. Chạy Clarification-First cho thay đổi plan.
3. Cập nhật component, data flow hoặc risk bị ảnh hưởng.
4. Xác định task trong `TASKS.md` bị invalidated; ghi rõ trong recommendation.
5. Invalidate recommendation cũ và tạo recommendation mới.

### Khi `--artifact=tasks`

1. Đọc `TASKS.md` hiện tại, `PLAN.md` `APPROVED` và `SPEC.md` `APPROVED & LOCKED`.
2. Chạy Clarification-First cho task mới/sửa.
3. Thêm/sửa task: đảm bảo atomic, independent hoặc có `blockedBy`, và có exact verification command.
4. Xác định task nào cần invalidate; cập nhật dependency nếu cần.
5. Invalidate recommendation cũ và tạo recommendation mới.

## DoD

### Spec (`--artifact=spec`)

- [ ] Clarification-First đã chạy; assumption được ghi hoặc Human đã confirm.
- [ ] SemVer bumped đúng loại thay đổi.
- [ ] Mọi requirement mới/sửa dùng EARS.
- [ ] Changelog entry ghi rõ, có REQ-XXX liên quan khi áp dụng.
- [ ] `Status: DRAFT` — không còn `APPROVED & LOCKED`.
- [ ] Recommendation mới ở `PENDING HUMAN REVIEW`.
- [ ] Artifact bị ảnh hưởng downstream đã liệt kê.
- [ ] Đã nhắc người dùng chạy `/sdd-sync` nếu shared contract thay đổi.
- [ ] Đã nhắc người dùng chạy `/sdd-trace --diff` sau khi execute downstream.

### Context (`--artifact=context`)

- [ ] Clarification-First đã chạy.
- [ ] Section bị ảnh hưởng đã cập nhật (stakeholder, constraint, glossary, open question).
- [ ] Spec requirement cần review lại đã liệt kê trong recommendation.
- [ ] Recommendation mới ở `PENDING HUMAN REVIEW`.

### Plan (`--artifact=plan`)

- [ ] Clarification-First đã chạy.
- [ ] Component/data flow/risk đã cập nhật theo Spec hiện tại.
- [ ] Task trong TASKS.md bị invalidated đã liệt kê.
- [ ] Recommendation mới ở `PENDING HUMAN REVIEW`.

### Tasks (`--artifact=tasks`)

- [ ] Clarification-First đã chạy.
- [ ] Task mới/sửa: atomic, có dependency rõ, có exact verification command.
- [ ] Không task nào vượt Out of Scope của Spec.
- [ ] Recommendation mới ở `PENDING HUMAN REVIEW`.

## AI Recommendation và Human Final Review

Sau khi cập nhật artifact, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`. Giữ `Human Final Review.Status: PENDING`; downstream execution bị block đến khi Human Director ghi `APPROVED`. Agent không tự approve artifact đã sửa.

## Ví dụ

```text
# Sửa Spec đã lock — thêm error case cho OTP
/sdd-update --feature=feat-user-register --artifact=spec --bump=patch --reason="[REQ-003] Add OTP rate-limit: max 5 attempts per 10 minutes, return 429"

# Thêm optional recovery flow vào Spec
/sdd-update --feature=feat-user-register --artifact=spec --bump=minor --reason="Add optional account recovery flow via email"

# Breaking change API contract
/sdd-update --feature=feat-user-register --artifact=spec --bump=major --reason="Change registration response: remove token from body, use httpOnly cookie"

# Cập nhật context khi stakeholder thay đổi
/sdd-update --feature=feat-user-register --artifact=context --reason="Add compliance team as stakeholder; add GDPR constraint"

# Sửa plan khi phát hiện risk mới
/sdd-update --feature=feat-user-register --artifact=plan --reason="Add Redis session risk and mitigation after security review"

# Thêm task xử lý edge case phát hiện lúc implement
/sdd-update --feature=feat-user-register --artifact=tasks --reason="Add T009 for concurrent registration dedup check"
```

Sau khi Human Director approve artifact mới, nếu có cascade:
- Spec change → chạy `/sdd-plan` (nếu Plan bị ảnh hưởng) hoặc `/sdd-tasks` (nếu chỉ Tasks bị ảnh hưởng).
- Plan change → chạy `/sdd-tasks` nếu task bị invalidated.
- Sau execute → chạy `/sdd-trace --diff` và `/sdd-sync` nếu contract thay đổi.
