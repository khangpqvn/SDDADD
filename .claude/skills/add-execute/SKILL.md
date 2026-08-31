---
name: add-execute
description: Pha 4–5 ADD — thực thi task theo Architecture Profile, governance và verification command đã approved
user-invocable: true
---

# ADD Phase 4–5 — Agentic Execution và Validation (`/add-execute`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`, `SHADOW PLAN`, `BLOCKED`), rule codes, `@ears` references, file paths, and CLI commands are language-invariant.

Dùng để thực thi task trong `.sdd/features/{feature-slug}/TASKS.md`, theo **Fix the Spec, not the Code**, `CONSTITUTION.md` và Architecture Profile.

## Tham số

- `--feature=<feature-slug>`: Feature identifier.
- `--task=<task-id>`: Tùy chọn; task cụ thể, ví dụ `T001`.
- `--strict-checkpoint`: Tùy chọn; project opt-in yêu cầu Human checkpoint trước mọi task. Không phải baseline.

## Shared methodology contract

Đọc [AI Review Protocol](../_shared/ai-review-protocol.md) trước execution. Mọi task cần Shadow Plan và Action Record. Human checkpoint persisted chỉ bắt buộc trước material state change: shared/public contract; persistence schema/business-data mutation; permission, security, dependency/runtime configuration; external/irreversible side effect. `--strict-checkpoint` tăng gate cho mọi task nhưng không thay baseline mặc định.

## Architecture Profile gate (BLOCKING)

1. Đọc `AGENTS.md`, `CONSTITUTION.md`, `CLAUDE.md`, Architecture Profile, constraints, `CONTEXT.md`, `SPEC.md`, `PLAN.md`, `TASKS.md`, shared contract record và review block liên quan.
2. Xác minh profile binding bằng manifest/config/source evidence; mọi prerequisite review phải `APPROVED` cùng decision, reviewer và timestamp.
3. Chỉ tạo/sửa adapter, package usage, migration, config, command và test đã có trong profile/Plan/Tasks approved.
4. Task cần HTTP, persistence, validation, cache, messaging hoặc test/build/lint command chưa selected/evidenced thì dừng, lưu `PENDING HUMAN REVIEW`; không sinh adapter code hoặc chạy placeholder command.
5. Profile/evidence mâu thuẫn, contract version drift hoặc task lệch Shadow Plan thì dừng, nêu conflict và yêu cầu Human Director quyết định.

## Quy trình

### 1. Atomic session và Shadow Plan bắt buộc

Mỗi session chỉ load task-scoped context: Intent Packet, locked `REQ-XXX`, applicable Plan/task records, profile binding/exact command, shared contract version và review evidence. Không absorb cleanup hoặc scope ngoài task.

Trước mỗi task, xuất Shadow Plan:

```text
SHADOW PLAN — Task {T00X}: {Task title}

INTENT AND DONE
- WHAT/DoD: {locked Intent Packet and REQ-XXX outcome}
- Scope/file boundary: {approved paths only}

ARCHITECTURE PROFILE
- Version/status: {approved profile version/status}
- Bindings and evidence: {only relevant approved bindings}
- Exact commands: {approved test/lint/typecheck/build or N/A reason}

STATE AND CONTRACT
- State-change category: {none or category list}
- Human checkpoint: {required persisted evidence | N/A}
- Shared contract/version: {record and owner | N/A}
- Sync-back: {/sdd-trace, /sdd-sync, or N/A}

RISKS
- {risk and mitigation}
```

Nếu task có material state change hoặc `--strict-checkpoint`, dừng trước edit đến khi Human checkpoint persisted `APPROVED`. Read-only/low-risk task vẫn cần Shadow Plan và Action Record, nhưng không cần checkpoint mặc định. Không tự nối test filter/option theo framework khi profile không có feature-scoped command.

### 2. Thực thi theo boundary đã approved

- Domain: TypeScript thuần, không external dependency hoặc adapter import.
- Usecase: business workflow và port; mọi business method có `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
- Interface: chỉ dùng approved transport/validation/authentication adapter; chỉ gọi usecase.
- Infrastructure: chỉ dùng approved DB/ORM/cache/external adapter; tuân thủ `DATA-01`, `SEC-01`.
- Shared: error, logging và security utility bám binding approved.

Dừng và handoff khi scope expansion, blocker, contract drift, material decision mới hoặc requirement/Spec gap xuất hiện. Không tiếp tục bằng cleanup không liên quan hoặc assumed contract change.

### 3. Self-check và verification

- [ ] Không hardcode secret (`SEC-01`).
- [ ] Feature cần access control có identity, authorization ownership và unauthorized behavior khớp Spec (`SEC-02`).
- [ ] Feature đổi core business data có retention, recovery, authorization, audit và deletion policy khớp Spec; soft-delete chỉ dùng khi binding/review đã xác định (`DATA-01`).
- [ ] Dependency direction khớp `ARCH-01`; async/reliability behavior khớp `ARCH-02`.
- [ ] Business method có `@ears`; error contract không leak sensitive detail và HTTP mapping, nếu có, khớp `ENG-02`.
- [ ] Chỉ chạy exact approved verification command đã nêu trong Task/Shadow Plan hoặc ghi `N/A` với lý do hợp lệ (`ENG-03`).

Command thiếu, không tồn tại hoặc profile mismatch là blocker. Không thay bằng `npm`, `pnpm`, `yarn` hoặc command suy đoán.

### 4. Action Record và sync-back

Sau execution, ghi Action Record trong `## Current Handoff State`, execution evidence hoặc review report. Record phải nêu approved scope/file boundary, profile binding/exact command, checkpoint, actions/result, residual blocker và sync-back decision.

- Chạy hoặc yêu cầu `/sdd-trace --feature=<slug> --diff` khi requirement/code/test evidence thay đổi.
- Chạy hoặc yêu cầu `/sdd-sync --feature=<slug> --reason="..."` khi shared contract/state thay đổi.
- Không đánh dấu task complete nếu required checkpoint, verification evidence hoặc sync-back thiếu.

### 5. Test failure và Spec gap

Nếu test fail do requirement mơ hồ/thiếu edge case:

1. Không vá behavior trực tiếp.
2. Phân loại failure: implementation defect, Spec gap, profile/configuration gap, hoặc prohibited/high-risk mutation.
3. Với Spec gap hoặc profile/configuration gap, dừng, đề xuất `/sdd-update` hoặc Architecture Profile review và chờ Human.
4. Chỉ bounded recovery cho implementation defect trong approved task/file scope; không auto-retry mutation thuộc prohibited/high-risk category.

## AI Recommendation và Human Final Review

Trước execution, lưu canonical recommendation với Intent/DoD, profile evidence, approach, file boundary, exact command, state-change category, checkpoint, risk và sync-back. Sau execution, tạo completion recommendation với Action Record. Agent không tự complete, commit hoặc push.
