# AI Recommendation và Human Final Review Protocol

## Mục đích

Mọi SDD/ADD skill có thể phân tích, đề xuất, sinh, cập nhật hoặc báo cáo. Agent cung cấp evidence và recommendation; Human Director sở hữu quyết định cuối cùng. Không Agent nào được approve recommendation của chính mình.

## Canonical block

Feature artifact (`CONTEXT.md`, `SPEC.md`, `PLAN.md`, `TASKS.md`) và review report sinh ra dùng block sau:

```markdown
## AI Agent Recommendation
- Status: PENDING HUMAN REVIEW
- Scope: <artifact, feature, or report>
- Recommendation: <proposed decision and next action>
- Evidence: <files, checks, or observed facts>
- Risks and assumptions: <known uncertainty>
- Alternatives considered: <alternatives and reason not selected>
- Required human decision: <specific approval boundary>

## Human Final Review
- Status: PENDING
- Decision: <leave empty until a human reviews>
- Reviewer: <leave empty until a human reviews>
- Reviewed at: <leave empty until a human reviews>
- Follow-up: <required changes or next command>
```

Với công việc không thuộc feature, lưu cùng block trong `.sdd/reviews/<review-slug>.md`. Không tạo feature giả chỉ để lưu review.

## Shared methodology conventions

Các section sau là additive metadata cho artifact mới hoặc được cập nhật. Không đổi canonical blocks bên trên và không làm artifact legacy mất hiệu lực.

### Methodology Profile

`CONTEXT.md` hoặc `SPEC.md` ghi một `## Methodology Profile` với:

```markdown
- Depth: Sketch | Detailed | Formal
- Rationale: <risk và complexity dẫn tới độ sâu này>
- Risk posture: low | elevated | high
- High-risk review route: <durable review route hoặc N/A>
- Unresolved-decision owner: <human role hoặc decision owner>
```

`High-risk review route` bắt buộc khi feature xử lý dữ liệu nhạy cảm, financial/business-critical behavior, destructive hoặc irreversible action, compliance, authorization, cross-system consistency, hoặc public/external contract. Template không tự gán danh tính reviewer.

### Intent Packet

`CONTEXT.md` ghi một `## Intent Packet` technology-neutral:

```markdown
- WHAT: <observable outcome>
- WHY: <problem hoặc value>
- Definition of Done: <verifiable completion conditions>
- Boundaries: <included behavior>
- Exclusions: <explicitly deferred or excluded behavior>
- Decision owner: <human role responsible for unresolved decisions>
```

Intent không được thay thế bởi solution kỹ thuật. Mọi question material phải có disposition: resolved, approved assumption, deferred, hoặc blocking decision.

### Material state change

Task hoặc change được phân loại `none` hoặc một hay nhiều category sau:

- shared/public contract;
- persistence schema hoặc business-data mutation;
- permission, security, dependency hoặc runtime configuration;
- external hoặc irreversible side effect.

Mỗi material state change cần persisted Human checkpoint trước action và checkpoint evidence trong Action Record. Project có thể chọn strict confirmation cho mọi task, nhưng đó không phải baseline.

### Action Record

Execution evidence hoặc handoff state ghi record tối thiểu:

```markdown
## Action Record — <task-id>
- Actor: <human or agent role>
- Approved scope and file boundary: <paths and intent>
- Profile binding and exact commands: <approved evidence>
- State-change category: <none or category list>
- Human checkpoint: <review reference or N/A>
- Actions and result: <what ran/changed and outcome>
- Residual blocker: <none or blocker>
- Sync-back decision: <affected artifacts; /sdd-trace and /sdd-sync decision>
```

Task không complete khi required checkpoint, verification evidence hoặc sync-back còn thiếu.

### Consistency and sync-back

Mọi artifact hoặc code change phải nêu downstream artifact bị ảnh hưởng và có cần `/sdd-trace` hoặc `/sdd-sync` hay không. Shared contract change phải ghi producer, version/status, owner, consumers và compatibility decision trong `.sdd/shared_context.md` trước completion.

## State transition

- Agent chỉ tạo hoặc refresh recommendation với `Status: PENDING HUMAN REVIEW`.
- Human reviewer có thể đặt `Human Final Review.Status` thành `APPROVED`, `REJECTED` hoặc `REVISE`; phải cung cấp decision, identity và timestamp.
- `APPROVED` chỉ hợp lệ khi đủ field bắt buộc. Hội thoại không phải durable approval.
- `REJECTED` và `REVISE` block downstream đến khi Agent tạo recommendation mới và Human review.
- Thay đổi intent, requirement, file boundary, exact command, checkpoint category hoặc shared-contract decision sau approval làm review cũ mất hiệu lực. Agent phải đặt lại `PENDING` và ghi changed scope làm evidence.
- Task status và append-only Action Record/`Current Handoff State` là execution evidence, không tự làm mất hiệu lực approval khi không thay đổi các field scope ở trên. Scope khác biệt phải dừng qua `/sdd-update` và review mới.
- Downstream skill phải đọc persisted review block trước khi coi artifact implementation-ready, locked, complete hoặc eligible for execution.

## Hành vi Agent bắt buộc

1. Đọc protocol trước khi tạo hoặc thay đổi SDD artifact/review report.
2. Sinh recommendation sau phân tích và trước khi yêu cầu approval.
3. Dừng tại human gate khi cần approval; không self-approve, không suy approval và không tiếp tục từ artifact chưa review.
4. Báo evidence, unresolved question, risk, alternative và exact next command.
5. Giữ Human Final Review block còn hiệu lực; nếu không thì invalidate theo quy tắc trên.
6. Dùng shared methodology conventions thay vì tự tạo format tương đương trong skill hoặc artifact.

## Vai trò review

- `Human Director` là reviewer mặc định cho feature behavior, execution và session continuation.
- `Tech Lead` hoặc `Architecture Board` có thể review architecture, governance hoặc RFC khi repository rule giao thẩm quyền.
- Agent ghi reviewer identity do con người cung cấp, không tự điền thay con người.

## Ghi quyết định Human

Human reviewer nên dùng `/sdd-review` để lưu decision thay vì sửa review field thủ công. Command xác minh target, recommendation state, required field, timestamp và status được phép trước khi chỉ sửa `Human Final Review` block.

`/sdd-review` yêu cầu `Status`, `Decision`, `Reviewer`, `Reviewed at` (tùy chọn, mặc định lấy thời gian hiện tại) và `Follow-up`. Với `SPEC.md`, review approved chỉ chuyển header thành `Status: APPROVED & LOCKED` khi Spec DoD pass. `REVISE` và `REJECTED` giữ artifact ở trạng thái block. `/sdd-review` không sửa `CONSTITUTION.md` và không thay thế `/sdd-rfc --approve=<rfc-number>` cho RFC hoặc Constitution change.

## Output Language

All skill output — section headers, status lines, descriptions, recommendations, and report bodies — must mirror the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical status tokens (`PASS`, `FAIL`, `BLOCKED`, `READY`, `PENDING`, `APPROVED`, `REJECTED`, `REVISE`, `PENDING HUMAN REVIEW`, `CONFIGURATION GAP`), code identifiers, file paths, and CLI commands are language-invariant.

## Skill integration contract

Mỗi skill phải nêu:

- khi nào sinh hoặc refresh recommendation;
- nơi lưu block;
- quyết định Human cần đưa ra;
- status bắt buộc trước hành động tiếp theo;
- Agent phải dừng thay vì self-approve;
- Human ghi decision qua `/sdd-review` khi target được hỗ trợ.
