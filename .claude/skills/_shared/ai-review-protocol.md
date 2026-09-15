# AI Recommendation và Human Final Review Protocol

## Mục đích

Mọi SDD/ADD skill có thể phân tích, đề xuất, sinh, cập nhật hoặc báo cáo. Agent cung cấp evidence và recommendation; Human reviewer có thẩm quyền theo `Project Ownership` sở hữu quyết định cuối cùng. Không Agent nào được approve recommendation của chính mình.

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
- Depth: SKIP | SKETCH | DETAILED | FORMAL
- Rationale: <risk, complexity và lý do chọn độ sâu>
- Risk posture: low | elevated | high
- High-risk review route: <durable review route hoặc N/A>
- Unresolved-decision owner: <human role hoặc decision owner>
```

- `SKIP`: chỉ cho scope được Human chấp nhận là exploratory/throwaway hoặc không thêm behavior/contract material; phải ghi lý do và evidence.
- `SKETCH`: behavior nhỏ, risk thấp; vẫn có requirement, acceptance, boundary và disposition cho ambiguity.
- `DETAILED`: mặc định cho integration, authorization, concurrency, third-party hoặc risk đáng kể.
- `FORMAL`: money, compliance, destructive/irreversible action, migration, security/authorization, core business state hoặc public/external contract; bổ sung state/invariant và adversarial review phù hợp.

Depth là sizing recommendation. Nó không bypass Human review, Feature Lock, Architecture Profile evidence, exact approved command hoặc material checkpoint. `High-risk review route` bắt buộc khi feature xử lý dữ liệu nhạy cảm, financial/business-critical behavior, destructive hoặc irreversible action, compliance, authorization, cross-system consistency, hoặc public/external contract. Template không tự gán danh tính reviewer.

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

### Describe-back record

Trước Context review, Agent ghi `## Describe-back record` để Human kiểm tra Agent hiểu đúng bài toán:

```markdown
- WHAT understood: <observable outcome in Agent's own words>
- WHY understood: <problem/value in Agent's own words>
- Definition of Done understood: <verifiable conditions>
- Boundaries and exclusions understood: <included and excluded behavior>
- Assumptions and unknowns: <each item and its impact>
- Material questions and disposition: <clarified | approved assumption | deferred | blocking>
- Consistency check: <Intent Packet, glossary, constraints and contradictions checked>
```

Không chuyển sang Spec nếu record mâu thuẫn Intent Packet, glossary hoặc constraint; nếu còn material question không disposition; hoặc nếu Agent đưa solution/technology không có evidence. Describe-back là evidence cho Human review, không phải approval tự động hay gate thay thế Human Final Review.

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
- Task execution grant: <grant ID; route; /add-execute-issued opaque consumer reference; consumption evidence or N/A with reason>
- Host execution-claim evidence: <host-controlled claim reference or UNVERIFIED>
- Actions and result: <what ran/changed and outcome>
- Validation route: <lint/audit/trace/sync/git-validation result or N/A with reason>
- Post-code review: <required report/reference or N/A with reason>
- Residual blocker: <none or blocker>
- Sync-back decision: <affected artifacts; /sdd-trace and /sdd-sync decision>
```

Task không complete khi required checkpoint, verification evidence, required post-code review hoặc sync-back còn thiếu.

### Delivery and post-code review

Delivery thay đổi implementation behavior, test, API/public/shared contract, runtime/dependency/security configuration, persistence schema hoặc business state cần post-code review persisted tại `.sdd/reviews/post-code-<feature>-<delivery-or-timestamp>.md` trước khi delivery complete hoặc Git validation trả `READY`.

Report dùng canonical block và phải nêu changed boundary, `REQ-XXX` coverage, exact approved command/result, lint/audit/trace/sync state, residual risk và required Human decision. Docs-only artifact work tiếp tục dùng artifact review thông thường; không cần post-code review chỉ vì có thay đổi Markdown.

### Execution Record và retry evidence

`/add-execute` ghi một `## Execution Record — <execution-id>` dưới `## Current Handoff State` của feature `TASKS.md`. Record là additive evidence, không thay task marker, Action Record hoặc Human Final Review. `Project ownership` và `Agent execution` phải được ghi tách biệt; direct execution không phải bypass governance. Historical `Dispatch Record` vẫn là immutable evidence, nhưng không authorize execution mới.

```markdown
## Execution Record — E-<feature>-<selection>-A<attempt>
- Coordinator: <Claude Code /add-execute or current Agent>
- Project ownership: solo | team
- Agent execution: direct | orchestrated
- Governance resolution: <canonical | legacy-header>; invocation axis overrides: none
- Feature: <feature-slug>
- Selection/tasks/state: <task=<T00X> | all snapshot; ordered task IDs; PLANNED | AWAITING_APPROVAL | READY | DISPATCHED | RUNNING | VERIFYING | RETRY_PENDING | COMPLETED | BLOCKED | ESCALATED>
- Task execution grants: <one append-only entry per selected task: task ID; grant ID; grant attempt; route=direct|orchestrated; task grant state=DISPATCHED|RUNNING|RETIRED|REVOKED; consumption state=UNCONSUMED|CONSUMED; /add-execute-issued opaque consumer reference; consumption evidence; terminal/retry evidence>
- Host execution-claim evidence: <host-controlled atomic claim reference or UNVERIFIED; matching feature/task/grant/route/consumer when available>
- Ownership and frozen contracts: <boundary check; ID/version/owner or N/A>
- Profile/checkpoint/commands: <approved evidence>
- Runtime identity evidence: VERIFIED | UNVERIFIED; <observed evidence>
- Runtime enforcement evidence: VERIFIED | UNVERIFIED; <observed evidence or absence>
- Worker/host task references: <supplemental IDs, direct/no worker, or unavailable>
- Attempt and retry count: <attempt; consecutive failures; maximum 5>
- Results/integration/blocker/sync-back: <Action Record, command result, compatibility, blocker, decision>
```

Runtime policy metadata does not prove host enforcement. Markdown grant state is cooperative evidence only: compliant routes must persist `RUNNING`/`CONSUMED` before action and reject consumed or mismatched grants, but this template cannot atomically prevent concurrent or malicious writers across sessions. `/add-execute` allocates an opaque consumer reference in every grant before direct execution or worker handoff and must match it before consumption. This is cooperative binding, not proof that a host prevented another session from replaying the reference. When an observed host provides an atomic execution claim, bind it to feature/task/grant/route/consumer and record the evidence; otherwise preserve `Runtime enforcement evidence: UNVERIFIED` and do not represent the grant as host-enforced replay protection. Task execution eligibility is controlled by the matching task execution grant, not aggregate selection state: only `DISPATCHED` with `UNCONSUMED` may start; `/add-execute` records `RUNNING` with `CONSUMED` before task action. A consumed, non-`DISPATCHED`, mismatched or missing grant is `BLOCKED`. Only `/add-execute` may allocate, revoke, retire or renew a grant. Automatic retry is limited to an implementation defect inside the unchanged approved task boundary, frozen contract, profile binding, exact command and checkpoint; it retires the consumed grant and creates a fresh eligible grant. A Spec/profile/command/checkpoint/contract/ownership/security/policy/dependency/runtime gap is `BLOCKED`, not retryable. At five consecutive failures, retain task marker `[/]`, set `ESCALATED`, persist an execution review report and require Human disposition.

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

- Với `Project Ownership: solo`, Human project owner duy nhất có thể persist Human Final Review cho feature behavior, execution và session continuation.
- Với `Project Ownership: team`, bất kỳ Human collaborator nào được project ủy quyền có thể persist Human Final Review; `Tech Lead` hoặc `Architecture Board` có thể review architecture, governance hoặc RFC khi repository rule giao thẩm quyền.
- Agent ghi reviewer identity do con người cung cấp, không tự điền, xác thực identity hoặc suy membership thay con người/host.

## Ghi quyết định Human

Human reviewer nên dùng `/sdd-review` để lưu decision thay vì sửa review field thủ công. Command xác minh target, recommendation state, required field, timestamp và status được phép trước khi chỉ sửa `Human Final Review` block.

`/sdd-review` yêu cầu `Status`, `Decision`, `Reviewer`, `Reviewed at` (tùy chọn, mặc định lấy thời gian hiện tại) và `Follow-up`. Với `SPEC.md`, review approved chỉ chuyển header thành `Status: APPROVED & LOCKED` khi Spec DoD pass. `REVISE` và `REJECTED` giữ artifact ở trạng thái block. `/sdd-review` không sửa `CONSTITUTION.md` và không thay thế `/sdd-rfc --approve=<rfc-number>` cho RFC hoặc Constitution change.

## Output Language

All skill output — section headers, status lines, descriptions, recommendations, and report bodies — must mirror the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical status tokens (`PASS`, `FAIL`, `BLOCKED`, `READY`, `PENDING`, `APPROVED`, `REJECTED`, `REVISE`, `PENDING HUMAN REVIEW`, `CONFIGURATION GAP`), code identifiers, file paths, and CLI commands are language-invariant.

## Completion output contract

Sau khi hoàn tất, dừng hoặc đến Human gate, mọi skill phải append một completion output theo ngôn ngữ prompt. Đây là hướng dẫn đọc state/evidence, không thay thế `Human Final Review`, `Action Record`, `Execution Record`, checkpoint, profile binding, exact approved command hoặc bất kỳ durable artifact nào.

```text
<Localized "Tổng kết thực thi" | "Execution summary">
- <Localized "Kết quả" | "Outcome">: <status kết quả hiện có của skill; không dịch hoặc tự tạo canonical status>
- <Localized "Trạng thái đã kiểm tra" | "State checked">: <artifact/review/task/grant/execution/delivery state, hoặc N/A kèm lý do>
- <Localized "Evidence" | "Evidence">: <file, persisted record, exact command/result đã quan sát, hoặc N/A kèm lý do>
- <Localized "Đã lưu hoặc thay đổi" | "Persisted or changed">: <path/record đã tạo hoặc cập nhật, hoặc none>
- <Localized "Blocker còn lại" | "Remaining blockers">: <none hoặc từng blocker và evidence>

<Localized "Hành động tiếp theo" | "Next action"> — <localized "Tiếp tục" | "continue" | localized "Cần quyết định Human" | "Human decision required" | BLOCKED>
- <Localized "Lý do lúc này" | "Why now">: <state transition hoặc precondition không đạt>
- <Localized "Người thực hiện" | "Actor">: <Agent | authorized Human reviewer | contract owner/Lead | Human delivery owner>
- <Localized "Lệnh hoặc hành động" | "Command or action">: <một exact command hiện có với placeholder đã biết, hoặc quyết định không phải command khi chưa có route an toàn>
- <Localized "Điều kiện trước" | "Preconditions">: <status/evidence phải còn đúng; chỉ dùng none khi đã verified>
- <Localized "Không được" | "Do not">: <shortcut bị cấm khi cần ngăn misuse>
```

Quy tắc:

1. `Outcome` giữ vocabulary hiện có của skill, ví dụ `READY`, `BLOCKED`, `NO-OP`, `PASS`, `FAIL`, `APPROVED`, `REVISE`, `REJECTED`, `UP-TO-DATE` hoặc `CONFIGURATION GAP`.
2. Chọn đúng một lớp `Next action` từ state đã quan sát. `continue` chỉ được nêu command đang eligible; không được dự đoán binding, command, grant, profile hoặc runtime state.
3. `Human decision required` phải nêu target/decision boundary, Human actor có thẩm quyền và `/sdd-review` khi target được hỗ trợ. `BLOCKED` phải nêu precondition thiếu và một remediation route an toàn, không tự repair hoặc bypass gate.
4. Không completion output nào là approval hoặc execution grant. Agent không self-approve, không reuse consumed grant, không tự retry gap không eligible, không commit/push/merge/deploy ngoài boundary hiện có.
5. Recommendation cho handoff/resume phải lưu tại `.sdd/reviews/handoff-<slug>.md` hoặc `.sdd/reviews/resume-<slug>.md`; `TASKS.md` chỉ giữ `## Current Handoff State`, Action/Execution Record và không được thêm `Human Final Review` block thứ hai. Historical Dispatch Record giữ nguyên nhưng không cấp authority mới.

## Skill integration contract

Mỗi skill phải nêu:

- khi nào sinh hoặc refresh recommendation;
- nơi lưu block;
- quyết định Human cần đưa ra;
- status bắt buộc trước hành động tiếp theo;
- Agent phải dừng thay vì self-approve;
- Human ghi decision qua `/sdd-review` khi target được hỗ trợ;
- `## Completion output` ở cuối skill, tham chiếu `Completion output contract` và route `continue`, `Human decision required`, `BLOCKED` theo state cục bộ.
