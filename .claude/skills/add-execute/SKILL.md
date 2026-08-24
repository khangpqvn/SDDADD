---
name: add-execute
description: Pha 4–5 ADD — thực thi task theo Architecture Profile, governance và verification command đã approved
user-invocable: true
---

# ADD Phase 4–5 — Agentic Execution và Validation (`/add-execute`)

Dùng để thực thi task trong `.sdd/features/{feature-slug}/TASKS.md`, theo **Fix the Spec, not the Code**, `CONSTITUTION.md` và Architecture Profile.

## Tham số

- `--feature=<feature-slug>`: Feature identifier.
- `--task=<task-id>`: Tùy chọn; task cụ thể, ví dụ `T001`.

## Architecture Profile gate (BLOCKING)

1. Đọc `AGENTS.md`, `CONSTITUTION.md`, `CLAUDE.md`, Architecture Profile, constraints, `CONTEXT.md`, `SPEC.md`, `PLAN.md`, `TASKS.md` và review block liên quan.
2. Xác minh profile binding bằng manifest/config/source evidence; mọi prerequisite review phải `APPROVED` cùng decision, reviewer và timestamp.
3. Chỉ tạo/sửa adapter, package usage, migration, config, command và test đã có trong profile/Plan/Tasks approved.
4. Task cần HTTP, persistence, validation, cache, messaging hoặc test/build/lint command chưa selected/evidenced thì dừng, lưu `PENDING HUMAN REVIEW`; không sinh adapter code hoặc chạy placeholder command.
5. Profile/evidence mâu thuẫn hoặc task lệch Shadow Plan thì dừng, nêu conflict và yêu cầu Human Director quyết định.

## Quy trình

### 1. Shadow Plan bắt buộc

Trước mỗi task, xuất Shadow Plan và chờ Human Director xác nhận execution scope:

```text
SHADOW PLAN — Task {T00X}: {Task title}

ARCHITECTURE PROFILE
- Version/status: {approved profile version/status}
- Bindings: {only relevant approved bindings}
- Evidence: {manifest/config/human decision}

FILES TO READ
- {path}: {reason}

FILES TO CREATE/MODIFY
- {path}: {purpose/change}

APPROVED COMMANDS
1. {exact approved test command}
2. {exact approved lint/typecheck/build or N/A reason}

RISKS
- {risk and mitigation}
```

Không tự nối test filter/option theo framework khi profile không có feature-scoped command. Yêu cầu Human Director approve command hoặc dùng exact approved general command nếu scope cho phép.

### 2. Thực thi theo boundary đã approved

- Domain: TypeScript thuần, không external dependency hoặc adapter import.
- Usecase: business workflow và port; mọi business method có `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
- Interface: chỉ dùng approved transport/validation/authentication adapter; chỉ gọi usecase.
- Infrastructure: chỉ dùng approved DB/ORM/cache/external adapter; tuân thủ `DATA-01`, `SEC-01`.
- Shared: error, logging và security utility bám binding approved.

### 3. Self-check và verification

- [ ] Không hardcode secret (`SEC-01`).
- [ ] Feature cần access control có identity, authorization ownership và unauthorized behavior khớp Spec (`SEC-02`).
- [ ] Feature đổi core business data có retention, recovery, authorization, audit và deletion policy khớp Spec; soft-delete chỉ dùng khi binding/review đã xác định (`DATA-01`).
- [ ] Dependency direction khớp `ARCH-01`; async/reliability behavior khớp `ARCH-02`.
- [ ] Business method có `@ears`; error contract không leak sensitive detail và HTTP mapping, nếu có, khớp `ENG-02`.
- [ ] Chỉ chạy exact approved verification command đã nêu trong Task/Shadow Plan hoặc ghi `N/A` với lý do hợp lệ (`ENG-03`).

Command thiếu, không tồn tại hoặc profile mismatch là blocker. Không thay bằng `npm`, `pnpm`, `yarn` hoặc command suy đoán.

### 4. Test failure và Spec gap

Nếu test fail do requirement mơ hồ/thiếu edge case:

1. Không vá behavior trực tiếp.
2. Đề xuất cập nhật `SPEC.md` và SemVer phù hợp.
3. Chờ Human review Spec; regenerate Plan/Tasks nếu bị ảnh hưởng rồi mới execution lại.

## AI Recommendation và Human Final Review

Trước execution, lưu canonical recommendation với profile evidence, approach, file, exact command, risk và Spec gap. Human Director phải ghi `APPROVED` trước edit. Sau execution, tạo completion recommendation; Agent không tự complete, commit hoặc push.
