# AI Recommendation & Human Final Review Protocol

## Purpose

Every SDD/ADD skill may analyze, propose, generate, update, or report. The Agent supplies evidence and a recommendation; the Human Director owns the final decision. No Agent may approve its own recommendation.

## Canonical blocks

Feature artifacts (`CONTEXT.md`, `SPEC.md`, `PLAN.md`, and `TASKS.md`) and any generated review report use these blocks:

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

For non-feature work, persist the same blocks in `.sdd/reviews/<review-slug>.md`. Do not create a fake feature only to store a review.

## State transitions

- The Agent may create or refresh a recommendation only with `Status: PENDING HUMAN REVIEW`.
- A human reviewer may set `Human Final Review.Status` to `APPROVED`, `REJECTED`, or `REVISE` and must provide decision, identity, and timestamp.
- `APPROVED` is valid only when all required fields are populated. Conversation text alone is not durable approval.
- `REJECTED` and `REVISE` block downstream work until the Agent produces a new recommendation and a human reviews it.
- Any artifact change after approval invalidates the prior review. The Agent must reset it to `PENDING` and record the changed scope as evidence.
- Downstream skills must read the persisted review block before treating an artifact as implementation-ready, locked, complete, or eligible for execution.

## Required Agent behavior

1. Read this protocol before creating or changing an SDD artifact or review report.
2. Generate the recommendation after analysis and before asking for approval.
3. Stop at the human gate when approval is required; do not self-approve, infer approval, or continue from an unreviewed artifact.
4. Report evidence, unresolved questions, risks, alternatives, and an exact next command.
5. Preserve the human review block when it remains valid; otherwise invalidate it as specified above.

## Review roles

- `Human Director` is the default final reviewer for feature behavior, execution, and session continuation.
- `Tech Lead` or `Architecture Board` may review architecture, governance, or RFC changes when the repository rules assign that authority.
- The Agent records the reviewer identity but never supplies it on behalf of a human.

## Human decision recording

Human reviewers should use `/sdd-review` to persist a decision instead of editing review fields ad hoc. The command validates the target, recommendation state, required fields, timestamp and allowed status before changing only the `Human Final Review` block.

`/sdd-review` requires `Status`, `Decision`, `Reviewer`, `Reviewed at` and `Follow-up`. For `SPEC.md`, an approved review may transition the header to `Status: APPROVED & LOCKED` only after the Spec DoD checks pass. `REVISE` and `REJECTED` leave the artifact blocked. `/sdd-review` never changes `CONSTITUTION.md` and does not replace `/sdd-rfc --approve=<rfc-number>` for RFC or Constitution changes.

## Skill integration contract

Each skill must state:

- when it generates or refreshes the recommendation;
- where it persists the blocks;
- the exact human decision required;
- the status required before its next action;
- that the Agent stops instead of self-approving;
- that Human records the decision through `/sdd-review` when the target is supported.
