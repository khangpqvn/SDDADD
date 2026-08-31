---
name: sdd-adopt
description: Khảo sát repository có sẵn, tạo Architecture Profile và tích hợp SDD + ADD không làm thay đổi source hiện có
user-invocable: true
---

# SDD Brownfield Adoption (`/sdd-adopt`)

Dùng để adopt SDD+ADD vào repository có source hoặc tạo Reverse Spec cho module legacy.

## Tham số

- `--stack=<tech-stack>`: Tùy chọn; stack explicit đã biết.
- `--reverse-feature=<feature-slug>`: Tùy chọn.
- `--path=<module-path>`: Tùy chọn, dùng cùng `--reverse-feature`.
- `--team-size=solo|team`: Tùy chọn; `team` là mặc định.

## Adoption workflow

1. Khảo sát root, manifest, lockfile, runtime/bootstrap configuration, database/migration configuration, CI, test configuration, source layout và docs.
2. Tạo/cập nhật Architecture Profile: runtime, framework, DB, ORM/query, validation và test/build/lint command đều cần evidence, confidence và conflict state.
3. Resolve theo precedence: approved profile → clear repository evidence → explicit `--stack` → core-only baseline.
4. Mâu thuẫn không được tự resolve. Lưu `PENDING HUMAN REVIEW` recommendation.
5. Context/Spec có thể business-neutral khi technical binding chưa resolved. Plan/Tasks/execution cần selected/evidenced binding và exact command.
6. Generate/reconcile governance theo actual repository. Không overwrite approved Constitution rules; RFC controls Layer 1/2 changes.
7. Install the full template-owned docs and support scripts listed by `/sdd-init`; distribution scripts retain staged/NEVER safety.

## Governance generation

Generate `AGENTS.md`, `CLAUDE.md`, `.agentignore` and `.gitignore` from observed convention, repository paths, real commands and secret boundaries. Never copy stack-specific permissions, command names or source layout as a default.

`CLAUDE.md` reflects approved profile for human readers. `.sdd/mcp-config.yaml` is policy specification; it does not prove runtime enforcement. `/sdd-dispatch` maps to Claude Code `Agent` only when the adopted host exposes observed evidence; adoption does not copy assumed settings, identity provider or permission configuration.

## Reverse Spec

With `--reverse-feature` and `--path`:

1. Observe source and tests; produce Context, Spec, Plan and Tasks as evidence of current behavior.
2. Keep Spec `DRAFT`; legacy behavior is not business-approved merely because code exists.
3. Include Intent Packet, Methodology Profile, Feature Lock/deferred-work decision, state-change classification and trace/sync implications for new or updated artifacts.
4. Only add `@ears` or change source after explicit scope approval and relevant profile gate.

## Shared contract and dispatch

Adoption recognizes frozen shared contracts in `.sdd/shared_context.md`. Only owner/Lead changes contract. A future dispatch must carry task ID, frozen version, ownership boundary, selected binding/evidence, exact commands, checkpoint and audit reference.

## Solo mode

Solo uses one developer role but keeps the same review/profile/checkpoint requirements. It does not authorize Agent push. Human performs remote delivery.

## AI Recommendation and Human Final Review

Create `.sdd/reviews/adopt-<slug>.md` with canonical protocol block. Include discovered evidence, unresolved/conflicting binding, governance impact, contract impact, recommendation and required Human decision. Human Director/Tech Lead approves adoption scope before downstream technical work. Agent does not self-approve or treat reverse-engineered behavior as approved business intent.
