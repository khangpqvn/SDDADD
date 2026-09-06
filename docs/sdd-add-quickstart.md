# Bắt đầu nhanh SDD + ADD

Đây là lộ trình chính để làm một feature từ ý tưởng đến delivery. Làm theo thứ tự. Dừng tại mọi `Human Final Review`; chat không phải approval persisted.

**Bạn cần:** repository Git, feature slug (ví dụ `feat-user-register`) và một Human quyết định business/risk.

```text
Human quyết định WHAT, WHY, boundary và risk.
Agent đề xuất HOW, thực thi scope đã duyệt, rồi ghi evidence.
```

Agent không self-approve, không `git push`, không deploy, không tự chọn stack/command và không tự thực hiện material state change.

## Bước 0 — Chọn độ sâu trước khi viết

Chọn trong `Methodology Profile`:

| Level | Dùng khi |
| :--- | :--- |
| `SKIP` | Scope exploratory/throwaway hoặc không thêm behavior/contract material, đã có Human decision và evidence. |
| `SKETCH` | Phạm vi nhỏ, risk thấp. |
| `DETAILED` | Mặc định cho integration, authorization, concurrency, third-party hoặc risk đáng kể. |
| `FORMAL` | Money, compliance, security/authorization, migration, destructive/irreversible action, core state hoặc external contract. |

Đây là sizing recommendation, không bỏ Human review, Feature Lock, Architecture Profile evidence, exact command hay checkpoint.

## Bước 1 — Tạo Context và kiểm tra Agent hiểu đúng

```text
/sdd-init --project-name="my-project"
/sdd-context --feature=feat-user-register
```

Trong `CONTEXT.md`, kiểm tra:

- `Intent Packet`: WHAT, WHY, Definition of Done, boundaries, exclusions, decision owner.
- glossary, actor/state, constraint và open question.
- disposition cho mọi question material: `resolved`, `approved assumption`, `deferred` hoặc `blocking decision`.
- `Describe-back record`: Agent diễn giải lại WHAT/WHY/DoD/boundary; không được mâu thuẫn Intent Packet, glossary hoặc constraints.

**Dừng:** Human review Context. Nếu describe-back sai, sửa Context trước; không sang Spec.

## Bước 2 — Viết, phản biện và khóa Spec

```text
/sdd-review --feature=feat-user-register --artifact=context --status=APPROVED \
  --decision="Đã duyệt Context và cách Agent hiểu bài toán." \
  --reviewer="<human reviewer>" \
  --follow-up="/sdd-spec --feature=feat-user-register"
/sdd-spec --feature=feat-user-register
```

Spec cần EARS, acceptance, error behavior, NFR đo được, out-of-scope và Feature Lock. Trước recommendation, Agent phải:

1. Chạy Clarification-First và dừng khi business rule/NFR/edge case còn mơ hồ.
2. Làm pre-mortem: giả định feature gây incident, bổ sung rule/evidence cần thiết.
3. Domain walkthrough: normal/error flow, state boundary, authorization, duplicate/concurrency, data lifecycle khi phù hợp.
4. Ghi disposition cho mọi finding.

Chạy `/sdd-lint --feature=feat-user-register`, sau đó Human review. `SPEC.md` phải là `APPROVED & LOCKED` trước Plan kỹ thuật.

**Nếu behavior đổi sau lock:** `/sdd-update --artifact=spec --reason="..."`, review/lock lại. Không vá code trước.

## Bước 3 — Xác nhận Hồ sơ kiến trúc

Mở `.sdd/architecture-profile.md` trước Plan/Tasks/execution. Với behavior kỹ thuật trong feature, cần binding liên quan, evidence và exact verification command `APPROVED`.

```text
/sdd-review --target=.sdd/architecture-profile.md --status=APPROVED \
  --decision="Đã duyệt binding và command cho scope feature." \
  --reviewer="<human reviewer>" \
  --follow-up="/sdd-plan --feature=feat-user-register"
```

**Dừng:** thiếu binding/command, evidence mâu thuẫn, hoặc command không chạy được. Không thay bằng `npm test` hay command suy đoán. Xem [Hướng dẫn Hồ sơ kiến trúc](./architecture-profile-guide.md).

## Bước 4 — Lập Plan

```text
/sdd-plan --feature=feat-user-register
```

Plan phải map `REQ-XXX` đến component/data flow, phân loại state change, ghi shared-contract impact, exact command, trace/sync decision và post-code review trigger. Human review Plan trước Tasks.

## Bước 5 — Chia Tasks có thể xác minh

```text
/sdd-tasks --feature=feat-user-register
```

Mỗi task cần ownership/file boundary, `REQ-XXX`, exact command, checkpoint, sync-back, post-code review trigger, `Estimated effort` và `Sizing signal`.

Một task implementation độc lập nên trong khoảng bốn giờ. Tách task khi có nhiều ownership, requirement, command, checkpoint, shared contract/integration hoặc không thể verify atomically. Nếu giữ task lớn hơn, ghi `approved-exception` cùng lý do, risk và Human evidence.

Human review `TASKS.md` trước execution.

## Bước 6 — Chọn execution rồi thực thi task

Chọn `Agent Execution` độc lập với `Project Ownership`:

- `direct`: Agent hiện tại thực thi task.
- `orchestrated`: dispatcher điều phối một hoặc nhiều worker có boundary độc quyền.

Solo owner và team đều dùng được cả hai route.

```text
# direct
/sdd-dispatch --feature=feat-user-register --task=T001 --agent-execution=direct

# orchestrated, kể cả solo project owner
/sdd-dispatch --feature=feat-user-register --task=T001 --project-ownership=solo --agent-execution=orchestrated
```

`/add-execute` luôn cần `--dispatch-record=<reference>`, `--dispatch-grant=<grant-id>` và `--dispatch-consumer=<consumer-ref>` do `/sdd-dispatch` tạo cho đúng feature/task. Chỉ grant matching `DISPATCHED`/`UNCONSUMED` cùng consumer reference được bắt đầu; direct consume grant trước action, còn orchestrated worker cần immutable packet khớp record. Không gọi trực tiếp để bỏ qua `/sdd-dispatch` preflight.


Trước edit, Agent tạo Shadow Plan. Material state change cần Human checkpoint persisted trước action:

- shared/public contract;
- schema hoặc business-data mutation;
- permission, security, dependency hoặc runtime configuration;
- external hoặc irreversible side effect.

Mỗi task phải có Action Record. Scope/contract/profile drift hoặc requirement mới là blocker, không phải lý do mở rộng task.

## Bước 7 — Chạy validation route

Theo trigger của diff, ghi command/result vào Action Record:

```text
<exact approved command>
/sdd-lint --feature=feat-user-register
/sdd-audit --feature=feat-user-register
/sdd-trace --feature=feat-user-register --diff
/sdd-sync --feature=feat-user-register --reason="feature delivery"
/git-validate --scope=commit --feature=feat-user-register
```

Chỉ chạy exact command đã được Architecture Profile duyệt. Một route không áp dụng phải ghi `N/A` cùng lý do, không giả `PASS`.

## Bước 8 — Review sau code khi cần

Tạo `.sdd/reviews/post-code-<feature>-<delivery-or-timestamp>.md` khi delivery thay đổi source behavior, test, API/public/shared contract, runtime/dependency/security configuration, schema hoặc business state.

Report phải nêu changed boundary, `REQ-XXX` coverage, command/result, lint/audit/trace/sync state, residual risk và Human decision. Human dùng `/sdd-review` để approve.

Docs-only không cần post-code review chỉ vì thay Markdown.

## Bước 9 — Delivery Git

```text
/git-validate --scope=commit --feature=feat-user-register
/git-commit --message="feat: add user registration"
```

Chỉ commit khi Human yêu cầu và `GIT VALIDATION: READY`. Human tự `git push`. `Project Ownership: team` chạy thêm `/git-validate --scope=pr --strict` trước `/git-pr`; `solo` không cần PR. `Agent Execution` không đổi delivery policy.

## Khi bị block

| Dấu hiệu | Làm đúng |
| :--- | :--- |
| Describe-back/Context mâu thuẫn | Sửa Context, disposition question rồi review lại. |
| Spec thiếu rule hoặc edge case | `/sdd-update --artifact=spec`, review/lock lại. |
| Binding/command thiếu hoặc mâu thuẫn | Review Architecture Profile; không đoán stack/command. |
| Contract drift | Dừng; owner/Lead resolve rồi trace/sync. |
| Task quá lớn | Tách task hoặc ghi Human-approved exception. |
| Lặp sửa không tiến triển | Dừng; giữ evidence, phân loại blocker, handoff hoặc xin Human decision. |
| Context/token pressure | `/sdd-handoff --feature=<slug>` rồi `/sdd-resume --feature=<slug>`. |
| Environment/command mismatch | Ghi evidence, coi là profile/configuration gap. |

## Self-heal: chỉ thu thập evidence

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

Script chạy command một lần, không edit/repair/retry, self-approve, commit, push hoặc deploy.

## Đọc tiếp khi cần

- [Hướng dẫn vận hành](./sdd-add-guide.md)
- [Tra cứu nhanh](./sdd-add-field-guide.md)
- [Sổ tay tình huống](./sdd-add-scenario-playbook.md)
- [Hướng dẫn điều phối nhiều Agent](./multi-agent-orchestration-guide.md)
