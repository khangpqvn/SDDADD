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
- `--task=<task-id>`: Tùy chọn; task cụ thể.
- `--dispatch-record=<reference>`: Required reference to a valid Dispatch Record created by `/sdd-dispatch`; with `orchestrated`, it also binds the immutable worker packet.
- `--dispatch-grant=<grant-id>`: Required ID của task execution grant trong Dispatch Record.
- `--dispatch-consumer=<consumer-ref>`: Required opaque consumer reference allocated by `/sdd-dispatch` for the matching grant.
- `--strict-checkpoint`: Tùy chọn; project opt-in yêu cầu Human checkpoint trước mọi task. Không phải baseline.

## Execution resolver (BLOCKING)

Đọc `.sdd/shared_context.md` trước execution. Canonical settings chỉ hợp lệ khi mỗi `# Project Ownership: solo|team` và `# Agent Execution: direct|orchestrated` tồn tại đúng một lần. Thiếu, trùng hoặc malformed canonical header là `BLOCKED`. Khi cả hai canonical header vắng mặt, legacy path chỉ hợp lệ với đúng một nguồn: đúng một `# Collaboration Mode: solo|team` hoặc đúng một `--team-size=solo|team`; header legacy thiếu, trùng hoặc malformed; alias lặp, malformed; hoặc cả header và alias cùng tồn tại là `BLOCKED`. `--team-size` không được kết hợp với canonical axis flag. Không fallback legacy khi canonical state invalid.

`/add-execute` không phải route discovery hoặc preflight. Mọi invocation phải có `--dispatch-record=<reference>`, `--dispatch-grant=<grant-id>` và `--dispatch-consumer=<consumer-ref>` do `/sdd-dispatch` tạo sau preflight. Thiếu hoặc không xác minh được record/grant/consumer là `BLOCKED`. Resolve record chỉ từ `TASKS.md` của `--feature`; `Feature` trong record phải bằng `--feature`. Grant phải xuất hiện đúng một lần, có task ID bằng `--task`, route bằng effective `Agent execution`, opaque consumer reference bằng `--dispatch-consumer`, và immutable boundary/frozen contract/profile/exact command/checkpoint khớp task approved. Markdown grant state không atomic; nó là cooperative evidence và không host-enforce replay prevention khi runtime enforcement là `UNVERIFIED`. Consumer reference là preallocated cooperative binding, không chứng minh host đã ngăn session khác replay reference. Nếu record có host-controlled execution claim, claim phải bound đúng feature/task/grant/route/consumer; stale hoặc mismatch là `BLOCKED`. Chỉ `task grant state=DISPATCHED` cùng `consumption state=UNCONSUMED` được bắt đầu. Với cả `direct` và `orchestrated`, trước Shadow Plan, command, edit hoặc action khác, persist transition matching grant sang `RUNNING`/`CONSUMED`, ghi consumer và consumption evidence. Grant consumed, non-`DISPATCHED`, missing, mismatched consumer, cross-feature, cross-task, cross-record hoặc replay là `BLOCKED`; `/add-execute` không allocate/reset grant hoặc authorize retry.

Record phải có `Governance resolution: canonical | legacy-header | legacy-alias` và `invocation axis overrides`. Record `canonical` không được chứa `legacy-alias` hoặc `--team-size`; có một canonical header cùng alias là `BLOCKED`. Với `canonical`, re-resolve canonical shared-context pair rồi áp dụng đúng override đã record. Với `legacy-header`, canonical headers phải vắng mặt và đúng một header legacy hợp lệ phải map về pair trong record. Với `legacy-alias`, canonical và legacy headers phải vắng mặt; alias chỉ được tin cậy từ immutable Dispatch Record. Mọi source/override invalid, override không hợp lệ hoặc effective `Project ownership`/`Agent execution` không bằng record là `BLOCKED`. Không nhận override mới trong `/add-execute`.

- `direct`: current Agent thực thi sau khi `/sdd-dispatch --agent-execution=direct` đã tạo Dispatch Record và matching unconsumed grant. Record phải có effective `Agent execution: direct` và preallocated consumer reference bằng `--dispatch-consumer`; không cần worker packet. Action Record phải echo consumed grant, consumer reference và consumption evidence.
- `orchestrated`: `/add-execute` chỉ chạy trong worker packet được `/sdd-dispatch` tạo. Record phải có effective `Agent execution: orchestrated`; `DISPATCH ID`, `FEATURE`, `TASK ID`, `DISPATCH GRANT ID`, `GRANT ATTEMPT`, `GRANT STATE: DISPATCHED`, `CONSUMPTION STATE: UNCONSUMED`, `CONSUMER`, task/boundary/frozen contract/profile/exact command/checkpoint phải khớp packet, `--dispatch-consumer` và record. Thiếu hoặc mismatch là `BLOCKED`.

## Shared methodology contract

Đọc [AI Review Protocol](../_shared/ai-review-protocol.md) trước execution. Mọi task cần Shadow Plan và Action Record. Human checkpoint persisted chỉ bắt buộc trước material state change. `--strict-checkpoint` tăng gate cho mọi task nhưng không thay baseline mặc định.

## Architecture Profile gate (BLOCKING)

1. Đọc `AGENTS.md`, `CONSTITUTION.md`, `CLAUDE.md`, Architecture Profile, constraints, feature artifacts, shared contract record và review block liên quan.
2. Xác minh profile binding bằng manifest/config/source evidence; mọi prerequisite review phải `APPROVED` cùng decision, reviewer và timestamp.
3. Chỉ tạo/sửa adapter, package usage, migration, config, command và test đã có trong profile/Plan/Tasks approved.
4. Task cần binding hoặc test/build/lint command chưa selected/evidenced thì dừng, lưu `PENDING HUMAN REVIEW`; không sinh code hoặc chạy placeholder command.
5. Profile/evidence mâu thuẫn, contract version drift hoặc task lệch Shadow Plan thì dừng.

## Quy trình

### 1. Atomic session và Shadow Plan bắt buộc

Với `Agent Execution: orchestrated`, `/sdd-dispatch` là coordinator; worker chỉ bắt đầu `/add-execute` sau immutable dispatch packet và matching `DISPATCHED`/`UNCONSUMED` grant hợp lệ. Với cả hai route, `/add-execute` persist consumption của matching grant trước khi thực thi cùng Shadow Plan, Action Record, checkpoint và boundary. Mỗi session chỉ load task-scoped context và không absorb cleanup/scope ngoài task.

Trước mỗi task, xuất Shadow Plan gồm Intent/DoD, scope/file boundary, profile binding/evidence, exact command, state-change/checkpoint, shared contract/version, risks, trace/sync decision và post-code review trigger.

Nếu task có material state change hoặc `--strict-checkpoint`, dừng trước edit đến khi Human checkpoint persisted `APPROVED`. Read-only/low-risk task vẫn cần Shadow Plan và Action Record.

### 2. Thực thi theo boundary đã approved

- Domain: TypeScript thuần, không external dependency hoặc adapter import.
- Usecase: business workflow và port; mọi business method có `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
- Interface/Infrastructure/Shared: chỉ dùng adapter, config và utility đã approved.

Dừng và handoff khi scope expansion, blocker, contract drift, material decision mới hoặc requirement/Spec gap xuất hiện.

### 3. Self-check và verification

- [ ] Không hardcode secret (`SEC-01`).
- [ ] Access control, data, dependency direction và error contract khớp Spec/constraints.
- [ ] Chỉ chạy exact approved verification command đã nêu trong Task/Shadow Plan hoặc ghi `N/A` với lý do hợp lệ (`ENG-03`).

Command thiếu, không tồn tại hoặc profile mismatch là blocker. Không thay bằng command suy đoán.

### 4. Validation route, Action Record và sync-back

Sau execution, ghi Action Record trong `## Current Handoff State`, execution evidence hoặc review report. Theo trigger, route delivery là:

1. Chạy exact approved command của task.
2. Chạy hoặc yêu cầu `/sdd-lint --feature=<slug>` khi Spec/artifact liên quan thay đổi.
3. Chạy hoặc yêu cầu `/sdd-audit --feature=<slug>` khi source hoặc governance thay đổi.
4. Chạy hoặc yêu cầu `/sdd-trace --feature=<slug> --diff` khi requirement, code hoặc tests thay đổi.
5. Chạy hoặc yêu cầu `/sdd-sync --feature=<slug> --reason="..."` khi shared state/contract thay đổi.
6. Chạy `/git-validate --scope=commit --feature=<slug>` trước commit hoặc PR.

Action Record phải echo task execution grant ID, route, dispatcher-issued consumer reference, observed host-controlled atomic claim reference, consumer/consumption evidence, command/result, validation route, residual blocker, sync-back decision và post-code review reference hoặc `N/A` có lý do. Không đánh dấu task complete nếu required checkpoint, verification evidence, post-code review hoặc sync-back thiếu.

### 5. Post-code Human review

Tạo post-code review tại `.sdd/reviews/post-code-<feature>-<delivery-or-timestamp>.md` và dùng `/sdd-review` khi delivery thay đổi implementation behavior, tests, API/public/shared contract, runtime/dependency/security configuration, persistence schema hoặc business state. Report cần changed boundary, `REQ-XXX` coverage, exact command/result, validation states, residual risk và required Human decision.

Docs-only artifact work không cần post-code review chỉ vì thay Markdown. `REVISE`, `REJECTED` hoặc thiếu report required block delivery; Agent không tự complete, commit hoặc push.

### 6. Test failure và Spec gap

Nếu test fail, phân loại implementation defect, Spec gap, profile/configuration gap hoặc prohibited/high-risk mutation.

- Spec/profile gap: dừng, đề xuất `/sdd-update` hoặc Architecture Profile review và chờ Human.
- Implementation defect: chỉ bounded recovery trong approved task/file scope; không auto-retry mutation prohibited/high-risk.
- Dispatcher chỉ retry packet immutable không đổi; maximum 5 consecutive failures trước `ESCALATED`.

Không tạo repair loop, không retry chung chung, không để validation failure tự mở rộng scope.

## AI Recommendation và Human Final Review

Trước execution, lưu canonical recommendation với Intent/DoD, profile evidence, approach, file boundary, exact command, state-change category, checkpoint, risk và sync-back. Sau execution, tạo completion recommendation với Action Record và delivery/post-code review evidence. Agent không tự complete, commit hoặc push.
