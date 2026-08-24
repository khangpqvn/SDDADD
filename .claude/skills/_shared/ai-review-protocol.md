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

## State transition

- Agent chỉ tạo hoặc refresh recommendation với `Status: PENDING HUMAN REVIEW`.
- Human reviewer có thể đặt `Human Final Review.Status` thành `APPROVED`, `REJECTED` hoặc `REVISE`; phải cung cấp decision, identity và timestamp.
- `APPROVED` chỉ hợp lệ khi đủ field bắt buộc. Hội thoại không phải durable approval.
- `REJECTED` và `REVISE` block downstream đến khi Agent tạo recommendation mới và Human review.
- Artifact thay đổi sau approval làm review cũ mất hiệu lực. Agent phải đặt lại `PENDING` và ghi changed scope làm evidence.
- Downstream skill phải đọc persisted review block trước khi coi artifact implementation-ready, locked, complete hoặc eligible for execution.

## Hành vi Agent bắt buộc

1. Đọc protocol trước khi tạo hoặc thay đổi SDD artifact/review report.
2. Sinh recommendation sau phân tích và trước khi yêu cầu approval.
3. Dừng tại human gate khi cần approval; không self-approve, không suy approval và không tiếp tục từ artifact chưa review.
4. Báo evidence, unresolved question, risk, alternative và exact next command.
5. Giữ Human Final Review block còn hiệu lực; nếu không thì invalidate theo quy tắc trên.

## Vai trò review

- `Human Director` là reviewer mặc định cho feature behavior, execution và session continuation.
- `Tech Lead` hoặc `Architecture Board` có thể review architecture, governance hoặc RFC khi repository rule giao thẩm quyền.
- Agent ghi reviewer identity do con người cung cấp, không tự điền thay con người.

## Ghi quyết định Human

Human reviewer nên dùng `/sdd-review` để lưu decision thay vì sửa review field thủ công. Command xác minh target, recommendation state, required field, timestamp và status được phép trước khi chỉ sửa `Human Final Review` block.

`/sdd-review` yêu cầu `Status`, `Decision`, `Reviewer`, `Reviewed at` và `Follow-up`. Với `SPEC.md`, review approved chỉ chuyển header thành `Status: APPROVED & LOCKED` khi Spec DoD pass. `REVISE` và `REJECTED` giữ artifact ở trạng thái block. `/sdd-review` không sửa `CONSTITUTION.md` và không thay thế `/sdd-rfc --approve=<rfc-number>` cho RFC hoặc Constitution change.

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
