# Bắt đầu nhanh SDD + ADD

Tài liệu này hướng dẫn người mới hoàn thành **một feature** từ ý tưởng đến Git delivery. Đi lần lượt từng bước; không nhảy từ ý tưởng sang code.

```text
CONTEXT → SPEC → PLAN → TASKS → dispatch → execute → validation → delivery
```

Mục tiêu không phải tạo nhiều tài liệu. Mỗi artifact trả lời một câu hỏi trước khi bước tiếp theo được phép bắt đầu:

| Bạn cần biết | Artifact trả lời |
| :--- | :--- |
| Cần giải quyết vấn đề gì, cho ai, trong phạm vi nào? | `CONTEXT.md` |
| Hệ thống phải làm gì và không làm gì? | `SPEC.md` |
| Sẽ thay đổi phần nào, kiểm tra ra sao? | `PLAN.md` |
| Ai làm từng phần, trong boundary nào? | `TASKS.md` |
| Có đủ evidence để thực thi và delivery không? | Dispatch/Action Record, review và validation evidence |

> **Nguyên tắc:** Human quyết định business, risk và approval. Agent đề xuất cách làm, chỉ thực thi scope đã duyệt, rồi ghi evidence. Chat không thay thế approval đã lưu trong Git.

Agent không self-approve, không `git push`, không deploy và không tự chọn stack/verification command. Agent không tự thực hiện material state change khi chưa có Human checkpoint persisted `APPROVED`; sau checkpoint, Agent chỉ thực thi trong scope và boundary đã duyệt.

---

## 1. Chuẩn bị trước feature đầu tiên

### 1.1 Bạn cần có gì?

- Một repository Git có template này.
- Một Human project owner/reviewer có thể đọc artifact và ghi quyết định.
- Một tên feature viết bằng **kebab-case**, ví dụ: `feat-user-register`.
- Một mô tả ngắn về outcome mong muốn, ví dụ: “Người dùng có thể đăng ký tài khoản bằng email và mật khẩu.”

Dùng **một feature slug xuyên suốt**. Với ví dụ này, mọi artifact sẽ nằm tại:

```text
.sdd/features/feat-user-register/
├── CONTEXT.md
├── SPEC.md
├── PLAN.md
└── TASKS.md
```

`.sdd/` là nơi lưu governance, Architecture Profile, feature artifact và review evidence. Không tạo `PLAN.md` hoặc `TASKS.md` tùy ý ngoài luồng này.

### 1.2 Các từ cần biết

| Từ | Nghĩa thực tế |
| :--- | :--- |
| **Artifact** | Một file có cấu trúc lưu intent, requirement, plan, task hoặc evidence. |
| **Gate** | Điều kiện phải đạt trước khi sang bước tiếp theo. Không đạt thì dừng. |
| **Human Final Review** | Quyết định persisted do Human ghi bằng `/sdd-review`, không phải Agent tự đánh dấu. |
| **Checkpoint** | Human approval bắt buộc trước một material state change cụ thể. |
| **Exact approved command** | Lệnh verification đã được Architecture Profile/Plan/Task duyệt. Không tự thay bằng lệnh quen thuộc. |
| **Feature Lock** | Trạng thái khóa behavior đã duyệt trong `SPEC.md`. Behavior đổi phải update/review Spec trước. |
| **Action Record** | Evidence sau khi thực thi task: boundary, command/result, risk còn lại và sync-back. |

### 1.3 Chọn ownership và execution — hai việc khác nhau

Đọc `.sdd/shared_context.md`. File này có hai trục độc lập:

| Trục | Giá trị | Quyết định điều gì? |
| :--- | :--- | :--- |
| `Project Ownership` | `solo` hoặc `team` | Ai được ghi Human Final Review và Git delivery policy. |
| `Agent Execution` | `direct` hoặc `orchestrated` | Task chạy trong Agent hiện tại hay được dispatcher điều phối worker. |

Bốn combination đều hợp lệ:

```text
solo + direct
solo + orchestrated
team + direct
team + orchestrated
```

- `solo` là một Human project owner. Solo **vẫn có thể** dùng nhiều Agent qua `orchestrated`.
- `team` là nhiều Human collaborator. Team **vẫn có thể** dùng `direct`.
- `direct` phù hợp với một task atomic mà Agent hiện tại thực hiện được trong boundary rõ ràng.
- `orchestrated` phù hợp khi task độc lập, worker boundary không overlap và runtime hỗ trợ worker dispatch.

`direct` không bỏ Shadow Plan, Action Record, checkpoint, profile hay validation. Execution route không thay delivery policy.

> **DỪNG:** Không dùng `--team-size` trong flow mới. Đó là alias deprecated cho migration; xem [Hướng dẫn điều phối nhiều Agent](./multi-agent-orchestration-guide.md) nếu đang migrate repository cũ.

### 1.4 Khởi tạo template khi repository chưa có governance

Nếu repository **chưa có** `.sdd/`, khởi tạo trước:

```text
/sdd-init --project-name="my-project"
```

Mặc định của template là `Project Ownership: team` và `Agent Execution: orchestrated`. Có thể chọn từng trục độc lập khi khởi tạo:

```text
/sdd-init --project-name="my-project" \
  --project-ownership=solo \
  --agent-execution=orchestrated
```

Sau init, Human phải review bootstrap scope và governance đã tạo trước khi Agent bắt đầu Context cho feature đầu tiên:

```text
/sdd-review --target=.sdd/reviews/init.md --status=APPROVED \
  --decision="Đã duyệt bootstrap scope và governance." \
  --reviewer="<human reviewer>" \
  --follow-up="Bắt đầu Context cho feature tiếp theo."
```

Thiếu review này, hoặc review là `REVISE` hay `REJECTED`, thì feature work bị block. Resolve review trước rồi mới bắt đầu Bước 1.

Nếu `.sdd/` đã tồn tại, không chạy lại init chỉ để tạo feature mới. Bắt đầu từ Bước 1.

---

## 2. Gate bắt buộc: Architecture Profile

Trước khi lập Plan kỹ thuật, tạo Tasks hoặc thực thi code, mở `.sdd/architecture-profile.md`.

**Trạng thái hiện tại của starter template:** header profile là `Status: DRAFT`.

- Baseline TypeScript, Node.js, Clean/Hexagonal Architecture và layout core có row `APPROVED`.
- HTTP framework, database, ORM/query layer, validation library và exact test/build/lint command chưa được chọn hoặc đang `BLOCKED`.
- Vì vậy profile **không phải** đã được duyệt toàn cục.

| Feature đang cần | Bạn có thể làm gì? |
| :--- | :--- |
| Intent, business rule và behavior technology-neutral | Tiếp tục `CONTEXT.md` và `SPEC.md`. |
| HTTP route, database, migration, validation adapter, package usage hoặc test/build/lint command | Dừng trước `PLAN.md`; cần evidence và Human-approved binding/command liên quan. |

Thứ tự resolve binding luôn là:

```text
approved Architecture Profile
→ repository evidence rõ ràng
→ input explicit
→ core-only baseline
```

Không đoán framework, DB, ORM, package manager hoặc command. Không thay lệnh thiếu bằng `npm test`, `npm run build` hay lệnh quen tay khác.

Khi có binding/evidence/exact command cần duyệt, Human ghi review cho profile:

```text
/sdd-review --target=.sdd/architecture-profile.md --status=APPROVED \
  --decision="Đã duyệt binding và command cho scope feature." \
  --reviewer="<human reviewer>" \
  --follow-up="/sdd-plan --feature=feat-user-register"
```

Review này chỉ xác nhận binding/evidence/command đã trình bày. Nó không tự giải quyết các phần profile còn thiếu. Xem [Hướng dẫn Hồ sơ kiến trúc](./architecture-profile-guide.md) khi bị block ở gate này.

---

## 3. Làm feature từng bước

### Bước 0 — Chọn độ sâu phân tích

`Methodology Profile` chọn độ sâu phân tích; nó không thay thế Architecture Profile gate hoặc Human review.

| Level | Dùng khi |
| :--- | :--- |
| `SKIP` | Scope exploratory/throwaway, không thêm behavior/contract material và đã có Human decision/evidence. |
| `SKETCH` | Scope nhỏ, rủi ro thấp. |
| `DETAILED` | Mặc định cho integration, authorization, concurrency, third-party hoặc risk đáng kể. |
| `FORMAL` | Money, compliance, security/authorization, migration, destructive/irreversible action, core state hoặc external contract. |

Nếu chưa chắc, bắt đầu bằng `DETAILED`. Agent ghi đề xuất; Human vẫn quyết định và review artifact.

### Bước 1 — Tạo Context: thống nhất bài toán trước

**Mục đích:** nói rõ feature là gì, vì sao cần, phạm vi nào và ai quyết định những điểm còn mơ hồ.

```text
/sdd-context --feature=feat-user-register
```

**Artifact tạo ra:** `.sdd/features/feat-user-register/CONTEXT.md`.

Khi đọc `CONTEXT.md`, Human kiểm tra:

- `Intent Packet` có WHAT, WHY, Definition of Done, boundary, exclusion và decision owner.
- Glossary giải thích từ nghiệp vụ có thể gây hiểu nhầm.
- Actor, state, business constraint và open question có liên quan.
- Mọi question material có disposition: `resolved`, `approved assumption`, `deferred` hoặc `blocking decision`.
- `Describe-back record` diễn giải lại WHAT/WHY/DoD/boundary và không mâu thuẫn Intent Packet.

`Methodology Profile` trong Context chỉ quyết định độ sâu làm việc. Nó không chọn technology stack.

**Trước khi sang bước tiếp:** Human đọc recommendation/evidence rồi ghi persisted review:

```text
/sdd-review --feature=feat-user-register --artifact=context --status=APPROVED \
  --decision="Đã duyệt Context và cách Agent hiểu bài toán." \
  --reviewer="<human reviewer>" \
  --follow-up="/sdd-spec --feature=feat-user-register"
```

> **DỪNG:** Describe-back sai, scope chưa rõ hoặc question `blocking decision` còn mở. Sửa Context và review lại; không sang Spec.

### Bước 2 — Viết và khóa Spec: định nghĩa behavior cần giao

**Mục đích:** chuyển Context đã duyệt thành requirement có thể kiểm tra, chưa gắn vào framework/DB cụ thể.

```text
/sdd-spec --feature=feat-user-register
```

**Artifact tạo ra:** `.sdd/features/feat-user-register/SPEC.md`.

Trong Spec:

- `REQ-XXX` là mã requirement để Plan, Task, code và test trace lại cùng một behavior.
- EARS mô tả khi nào hệ thống phải làm gì.
- Acceptance criteria và error behavior cho biết làm sao chứng minh requirement đạt.
- NFR đo được khi feature có performance, security, reliability hoặc constraint tương ứng.
- Out-of-scope ngăn feature phình thêm.
- Feature Lock giữ behavior đã duyệt ổn định.

**Clarification-First là bắt buộc trước khi viết `REQ-XXX`:**

```text
Agent liệt kê business gap, technical/NFR gap và edge case chưa rõ
→ dừng chờ Human có thẩm quyền xác nhận hoặc phê duyệt assumption
→ chỉ sau đó mới viết REQ-XXX và hoàn tất SPEC.md
```

Không tự điền gap bằng suy đoán. Pre-mortem và domain walkthrough thực hiện khi Methodology Profile hoặc scope yêu cầu; Human đọc finding/disposition liên quan trước final review.

Đây là gate trước khi soạn requirement. Final Human review và Spec lock ở bước dưới là gate riêng, sau khi `SPEC.md` đã hoàn tất.

Chạy route áp dụng theo skill/project và review Spec. Khi Spec đủ điều kiện, Human chạy:

```text
/sdd-review --feature=feat-user-register --artifact=spec --status=APPROVED \
  --decision="Đã duyệt requirement và khóa phạm vi feature." \
  --reviewer="<human reviewer>" \
  --follow-up="Xác nhận Architecture Profile rồi lập Plan."
```

`SPEC.md` phải là `APPROVED & LOCKED` trước Plan kỹ thuật.

> **DỪNG:** Thiếu business rule, acceptance, error behavior hoặc edge case. Nếu behavior đổi sau lock, dùng:
>
> ```text
> /sdd-update --feature=feat-user-register --artifact=spec \
>   --bump=<patch|minor|major> --reason="..."
> ```
>
> Review/lock lại trước khi thực thi behavior mới. Không vá code trước.

### Bước 3 — Lập Plan: chọn đường kỹ thuật đã được phép

**Mục đích:** map từng `REQ-XXX` vào component, data flow, file boundary dự kiến, risk và verification.

**Preflight:** gate Architecture Profile ở phần 2 phải đủ cho scope feature. Nếu feature cần binding/command còn thiếu, dừng tại đây.

```text
/sdd-plan --feature=feat-user-register
```

**Artifact tạo ra:** `.sdd/features/feat-user-register/PLAN.md`.

Human đọc Plan để xác nhận:

- Mỗi requirement được map tới design/component phù hợp.
- Data flow, state change và shared-contract impact không bị bỏ sót.
- Exact approved command đã có evidence; không phải placeholder hoặc command đoán.
- Risk, compatibility, trace/sync decision và post-code review trigger rõ ràng.
- Các câu hỏi kỹ thuật cần Human quyết định đã được nêu thay vì bị Agent tự chọn.

Sau đó Human review `PLAN.md` bằng `/sdd-review` với `--artifact=plan` và một decision/follow-up cụ thể.

> **DỪNG:** Profile thiếu binding/command, Design mâu thuẫn Spec, hoặc Plan tạo material decision chưa có Human disposition.

### Bước 4 — Chia Tasks: biến Plan thành công việc có thể kiểm tra

**Mục đích:** tạo những đơn vị thực thi nhỏ, có owner, boundary và cách xác minh rõ ràng.

```text
/sdd-tasks --feature=feat-user-register
```

**Artifact tạo ra:** `.sdd/features/feat-user-register/TASKS.md`.

Một task tốt trả lời được:

- Nó thực hiện `REQ-XXX` nào?
- File/path boundary nào được phép sửa?
- Có dependency với task nào?
- Ai là owner và shared contract có owner/version nào?
- Exact approved command nào xác minh kết quả?
- Có checkpoint material state change, sync-back hoặc post-code review không?

`Estimated effort` và `Sizing signal` là tín hiệu phân chia: task độc lập thường nên gần bốn giờ. Tách task khi có nhiều ownership, requirement, command, checkpoint hoặc integration. Nếu cần giữ task lớn, phải có `approved-exception` với lý do, risk và Human evidence.

Human review `TASKS.md` bằng `/sdd-review --artifact=tasks` trước execution.

> **DỪNG:** Task chưa có exact command, boundary overlap, dependency chưa hoàn tất hoặc checkpoint chưa xác định. Dispatch readiness chỉ cho phép chọn task; nó không phải execution grant.

### Bước 5 — Dispatch: cấp quyền thực thi cho đúng task

**Mục đích:** `/sdd-dispatch` kiểm tra task trước khi thực thi và cấp quyền cho **đúng một task, đúng attempt, đúng bên thực thi**. `/add-execute` chỉ bắt đầu sau bước này; nó không tạo grant mới, reset grant cũ hay tự cho phép retry.

#### Luồng chuẩn cho người mới: một task, route `direct`

Đây là đường mặc định khi `T001` là một task atomic, boundary đã approved và Agent hiện tại có thể thực hiện.

```text
TASKS.md đã APPROVED
→ /sdd-dispatch --agent-execution=direct
→ Dispatch Record + grant + consumer được tạo
→ /add-execute với đúng ba giá trị vừa nhận
→ grant bị consume trước mọi action
→ validation và Action Record
```

Chạy dispatch:

```text
/sdd-dispatch --feature=feat-user-register --task=T001 --agent-execution=direct
```

`direct` nghĩa là không launch worker khác. Nó **không** bỏ preflight, Shadow Plan, Action Record, checkpoint, exact approved command hoặc validation.

#### Alternative flow: khi nào chọn `orchestrated`?

| Route | Chọn khi | Dispatcher làm thêm | Không dùng khi |
| :--- | :--- | :--- | :--- |
| `direct` | Một task atomic, Agent hiện tại thực hiện trong boundary rõ ràng. Đây là lựa chọn đầu tiên cho người mới. | Tạo Dispatch Record, grant và consumer; không launch worker. | Task chưa approved hoặc có blocker. |
| `orchestrated` | Có một hoặc nhiều task độc lập, boundary độc quyền không overlap, runtime quan sát được worker dispatch. | Cấp immutable worker packet, worker reference và integration validation. | Shared file/contract, dependency, retry hoặc integration cần thứ tự; các trường hợp này phải tuần tự. |

Ví dụ alternative route:

```text
/sdd-dispatch --feature=feat-user-register --task=T001 --agent-execution=orchestrated
```

`Project Ownership` không chọn route: solo vẫn có thể `orchestrated`; team vẫn có thể `direct`.

#### Dispatcher tạo gì, và bạn dùng chúng thế nào?

**Artifact/evidence tạo ra:** Dispatch Record dưới `## Current Handoff State` của `TASKS.md`.

| Giá trị | Có ở đâu? | Dùng để làm gì? | Người mới không được làm |
| :--- | :--- | :--- | :--- |
| Dispatch Record `--dispatch-record=<reference>` | Dispatch Record trong `TASKS.md`. | Chỉ đúng evidence/preflight của lần dispatch này. | Tự viết reference hoặc dùng record của feature/task khác. |
| Task grant `--dispatch-grant=<grant-id>` | Entry grant khớp `T001` trong Dispatch Record. | Quyền thực thi một lần cho task/attempt/route đó. | Tạo grant thủ công, reset hoặc dùng lại grant đã consumed. |
| Consumer `--dispatch-consumer=<consumer-ref>` | Cùng entry grant do dispatcher cấp. | Gắn grant với đúng bên thực thi được chỉ định. | Tự đoán, copy sang task khác hoặc dùng consumer của attempt cũ. |

Ba giá trị opaque này được `/sdd-dispatch` tạo cho đúng feature/task. Hãy copy nguyên vẹn vào Bước 6.

> **DỪNG trước dispatch:** `TASKS.md` chưa `APPROVED`, dependency chưa xong, boundary overlap, frozen contract/profile/exact command/checkpoint thiếu hoặc drift, hay material batch chưa có Human checkpoint. Quay lại artifact/profile/review phù hợp; không gọi `/add-execute` để “thử trước”.

### Bước 6 — Execute: thực thi một task trong grant đã cấp

**Mục đích:** Agent thực hiện đúng task đã dispatch, trong boundary đã approved, rồi lưu Action Record. Bước này không phải là “chạy lại cho đến khi pass”; mỗi grant chỉ là một lần thực thi có kiểm soát.

#### Thứ tự bắt buộc trong execution

```text
Đọc Dispatch Record
→ xác minh record/grant/consumer và immutable task inputs
→ consume matching DISPATCHED/UNCONSUMED grant thành RUNNING/CONSUMED
→ Shadow Plan
→ checkpoint nếu task có material state change
→ action trong boundary
→ exact approved command và validation
→ Action Record
```

Grant phải được consume **trước** Shadow Plan, command, edit hoặc action khác. Khi grant đã `CONSUMED`, không gọi lại `/add-execute` với cùng grant để “thử lại”.

Sau khi lấy ba giá trị từ Bước 5, gọi:

```text
/add-execute --feature=feat-user-register --task=T001 \
  --dispatch-record=<reference> \
  --dispatch-grant=<grant-id> \
  --dispatch-consumer=<consumer-ref>
```

Trước edit, Agent phải:

1. Xác minh record, grant, consumer, route, boundary, frozen contract, profile, exact command và checkpoint khớp task.
2. Persist transition của matching grant sang `RUNNING`/`CONSUMED` trước Shadow Plan, command, edit hoặc action khác.
3. Tạo Shadow Plan: Intent/DoD, boundary, profile evidence, exact command, risk, trace/sync và post-code review trigger.
4. Dừng trước material state change cho đến khi checkpoint persisted `APPROVED` tồn tại.

Material state change gồm shared/public contract, schema hoặc business-data mutation, permission/security/dependency/runtime configuration, và external/irreversible side effect.

Sau execution, Action Record lưu changed path, `REQ-XXX` coverage, command/result, residual blocker và sync-back decision. Action Record là evidence sau action, không phải quyền để bắt đầu action.

#### Alternative và exception flow: gặp tình huống này thì làm gì?

| Tình huống | Làm đúng | Không được làm |
| :--- | :--- | :--- |
| Blocker trước dispatch: task chưa approved, dependency chưa xong, boundary overlap, profile/contract/checkpoint/command thiếu | Dừng trước `/sdd-dispatch`; quay lại `TASKS.md`, artifact, Architecture Profile hoặc Human review đúng chỗ. | Tạo grant thủ công hoặc gọi `/add-execute`. |
| Blocker khi execute: record/grant/consumer mismatch, grant consumed, requirement mới hoặc scope/contract/profile drift | Dừng, giữ evidence; handoff hoặc để owner/Lead resolve rồi revalidate. | Dùng grant cũ, đổi command để bypass hoặc tự mở rộng task. |
| Implementation defect sau execution, immutable task inputs không đổi và state là `RETRY_PENDING` | Dùng `/sdd-dispatch --feature=feat-user-register --retry`. Dispatcher retire grant consumed và cấp grant mới nếu retry đủ điều kiện. | Gọi lại `/add-execute` với grant đã consumed. |
| Session bị ngắt hoặc blocker đã được resolve | Dùng `/sdd-handoff --feature=feat-user-register`, rồi `/sdd-resume --feature=feat-user-register`. Sau revalidation, dispatcher route tiếp theo có thể là `/sdd-dispatch --feature=feat-user-register --resume`. | Giả định grant, worker reference hoặc permission cũ vẫn hợp lệ. |
| Task là `ESCALATED` | Chờ Human disposition explicit rồi mới recovery/resume. | Tự retry hoặc tự chuyển task về `PLANNED`. |
| Exact command thiếu, không tồn tại hoặc mâu thuẫn profile | Ghi command/result; quay lại Architecture Profile evidence và Human review để chọn/duyệt command đúng. | Thay bằng lệnh quen thuộc để lấy `PASS`. |

> **DỪNG:** Grant missing, consumed, không `DISPATCHED`, mismatched consumer, cross-feature/cross-task/cross-record hoặc replay là `BLOCKED`. Retry và resume là hai flow khác nhau: `--retry` chỉ cho implementation defect `RETRY_PENDING`; `--resume` chỉ sau interruption hoặc blocker đã resolve và luôn cần revalidation.

Xem [Hướng dẫn điều phối nhiều Agent](./multi-agent-orchestration-guide.md) khi cần lifecycle, retry hoặc runtime evidence chi tiết.

### Bước 7 — Validation: chứng minh task/feature đạt yêu cầu

**Mục đích:** lưu evidence cho requirement, command, contract và delivery readiness.

Route luôn bắt đầu từ exact approved command của Task/Shadow Plan:

```text
<exact approved command>
```

Các route sau chỉ chạy khi trigger áp dụng và phải ghi command/result trong Action Record:

```text
/sdd-lint --feature=feat-user-register
/sdd-audit --feature=feat-user-register
/sdd-trace --feature=feat-user-register --diff
/sdd-sync --feature=feat-user-register --reason="feature delivery"
/git-validate --scope=commit --feature=feat-user-register
```

| Route | Dùng khi |
| :--- | :--- |
| Exact approved command | Mọi task có command đã approved. |
| `/sdd-lint` | Spec/artifact liên quan thay đổi. |
| `/sdd-audit` | Source hoặc governance thay đổi. |
| `/sdd-trace` | Requirement, code hoặc test thay đổi. |
| `/sdd-sync` | Shared state/contract thay đổi. |
| `/git-validate` | Trước commit hoặc PR. |

Route không áp dụng phải ghi `N/A` cùng lý do; không ghi giả `PASS`. Command bị thiếu, không chạy được hoặc mâu thuẫn profile là configuration/profile gap, không phải lý do đổi sang command suy đoán.

### Bước 8 — Review sau code khi cần

Post-code review cần khi delivery thay đổi:

- source behavior hoặc tests;
- API/public/shared contract;
- runtime, dependency hoặc security configuration;
- persistence schema hoặc business state.

Tạo report tại:

```text
.sdd/reviews/post-code-<feature>-<delivery-or-timestamp>.md
```

Report nêu changed boundary, `REQ-XXX` coverage, exact command/result, lint/audit/trace/sync state, residual risk và Human decision cần có. Human dùng `/sdd-review` để ghi quyết định.

Docs-only change không cần post-code review chỉ vì thay Markdown.

> **DỪNG:** Nếu post-code review bắt buộc nhưng report thiếu, `REVISE` hoặc `REJECTED`, delivery bị block.

### Bước 9 — Delivery Git

**Mục đích:** chỉ chuyển thay đổi đã đủ evidence sang Git delivery.

```text
/git-validate --scope=commit --feature=feat-user-register
/git-commit --message="feat: add user registration"
```

Chỉ commit khi Human yêu cầu và kết quả là `GIT VALIDATION: READY`.

| Project Ownership | Delivery |
| :--- | :--- |
| `solo` | Human-owned direct delivery sau validation/review; không bắt buộc PR. |
| `team` | Dùng PR/review flow bên dưới. |

Với `team`, thứ tự remote delivery là:

```text
Human commit sau GIT VALIDATION: READY
→ Human push branch
→ /git-pr fetch remote state và chạy /git-validate --scope=pr --strict
→ Human xác nhận nội dung PR
→ /git-pr tạo PR
```

Dù ownership/execution là combination nào, Agent không `git push`. Human tự xử lý push và remote delivery.

---

## 4. Khi bị block: quay lại đúng chỗ

| Bạn thấy gì? | Làm gì ngay? | Không được làm |
| :--- | :--- | :--- |
| Context hoặc describe-back không đúng | Sửa `CONTEXT.md`, disposition question, rồi review lại. | Sang Spec. |
| Spec thiếu business rule/edge case | `/sdd-update --feature=<slug> --artifact=spec --bump=<patch|minor|major> --reason="..."`, rồi review/lock lại. | Vá code trước. |
| Thiếu binding hoặc exact command | Ghi evidence, yêu cầu Human review Architecture Profile. | Đoán stack hoặc command. |
| Contract/task/boundary drift | Dừng; để contract owner/Lead resolve, sau đó trace/sync khi phù hợp. | Mở rộng task hay sửa shared contract không quyền. |
| Exact command fail hoặc environment mismatch | Giữ command/result; quay lại Architecture Profile evidence và Human review để chọn/duyệt command đúng. | Thay bằng command khác cho “pass”. |
| Grant consumed/mismatch hoặc execution drift | Dừng, giữ evidence; resolve đúng artifact/owner rồi revalidate route. | Gọi lại `/add-execute` với grant cũ. |
| Implementation defect `RETRY_PENDING` | Chỉ dùng `/sdd-dispatch --feature=<slug> --retry` khi immutable inputs không đổi. | Nhầm retry với resume hoặc tự cấp grant mới. |
| Session bị ngắt hoặc context pressure | `/sdd-handoff --feature=<slug>` → `/sdd-resume --feature=<slug>` → revalidation → `/sdd-dispatch --feature=<slug> --resume` khi phù hợp. | Reset scope hoặc giả định grant/worker cũ còn hợp lệ. |
| Task `ESCALATED` | Chờ Human disposition explicit trước recovery/resume. | Tự retry hoặc tự chuyển task về `PLANNED`. |

`scripts/self-heal.sh` chỉ thu thập evidence cho implementation defect theo approved environment; nó không repair, retry, self-approve, commit, push hoặc deploy. Không dùng nó như cách thay gate hay tự khắc phục lỗi.

Xem [Sổ tay tình huống](./sdd-add-scenario-playbook.md) cho brownfield, failure, checkpoint, recovery và handoff.

---

## 5. Đọc tiếp khi cần

- [Hướng dẫn Hồ sơ kiến trúc](./architecture-profile-guide.md): bị block vì thiếu binding hoặc exact command.
- [Hướng dẫn điều phối nhiều Agent](./multi-agent-orchestration-guide.md): worker dispatch, grants, retry và runtime evidence.
- [Sổ tay tình huống](./sdd-add-scenario-playbook.md): recovery, handoff, brownfield và exception.
- [Tra cứu nhanh](./sdd-add-field-guide.md): đã biết tình huống và cần command phù hợp.
