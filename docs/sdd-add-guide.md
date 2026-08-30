# HƯỚNG DẪN VẬN HÀNH SDD + ADD

# Version: 7.1.0
# Đối tượng: Product Owner, Human Director, Tech Lead, Developer, QA và AI Agent

> **Lần đầu tiếp cận?** Đọc [`sdd-add-quickstart.md`](./sdd-add-quickstart.md) trước — giải thích tại sao, mental model, và kịch bản bắt đầu.  
> **Tra nhanh command?** Dùng [`sdd-add-field-guide.md`](./sdd-add-field-guide.md).  
> **Tìm kịch bản cụ thể?** Dùng [`sdd-add-scenario-playbook.md`](./sdd-add-scenario-playbook.md).

Đây là cẩm nang thao tác đầy đủ cho Starter Template SDD + ADD. Tài liệu trả lời ba câu hỏi:

1. Con người phải chuẩn bị và quyết định điều gì ở từng pha?
2. Agent được làm gì, phải dừng ở đâu và phải đưa bằng chứng nào?
3. Review, approve, revise, reject và các trạng thái được ghi vào đâu?

Quy tắc bất biến nằm ở [`CONSTITUTION.md`](../CONSTITUTION.md). Quyền hạn và phạm vi của Agent nằm ở [`AGENTS.md`](../AGENTS.md). Contract của từng slash command nằm trong `.claude/skills/`; tài liệu này hướng dẫn **khi nào dùng** và **con người phải làm gì**, không thay thế các contract đó.

---

## 1. SDD + ADD là gì?

### 1.1 SDD — Spec-Driven Development

SDD coi đặc tả là nguồn sự thật cho hành vi nghiệp vụ. Mỗi feature được làm rõ theo bốn artifact:

| Artifact | Câu hỏi phải trả lời | Người chịu trách nhiệm chính |
| :--- | :--- | :--- |
| `CONTEXT.md` | Vì sao cần làm? Ai bị ảnh hưởng? Ràng buộc là gì? | Product Owner / Human Director |
| `SPEC.md` | Hệ thống phải làm gì, kể cả lỗi và trường hợp biên? | Product Owner + Tech Lead |
| `PLAN.md` | Sẽ xây dựng theo ranh giới kiến trúc nào? Rủi ro ra sao? | Tech Lead / Architect |
| `TASKS.md` | Ai hoặc Agent làm những bước nhỏ nào, kiểm chứng bằng gì? | Tech Lead + Developer |

Code và test phải truy vết được về requirement. Nếu behavior chưa rõ hoặc test cho thấy Spec thiếu điều kiện, cập nhật Spec trước rồi mới đồng bộ code.

### 1.2 ADD — Agent-Driven Development

ADD dùng AI Agent làm executor dưới sự chỉ đạo của con người:

- **Human Director** quyết định business behavior, trade-off, phạm vi, ngoại lệ và phê duyệt cuối.
- **Product Owner** xác nhận nhu cầu, tiêu chí nghiệm thu và ưu tiên nghiệp vụ.
- **Tech Lead / Architect** duyệt kiến trúc, rủi ro, thay đổi contract và governance.
- **Developer / QA** kiểm tra code, test, khả năng vận hành và bằng chứng thực tế.
- **Agent** đọc artifact, phân tích, đề xuất, thực thi trong phạm vi được phép và báo evidence.

Agent không được tự phê duyệt recommendation, tự suy ra approval từ câu nói trong hội thoại, tự sửa `CONSTITUTION.md` sau khi template đã phát hành, bypass quality gate, push hoặc deploy. Chỉ một Human authorization explicit cho đúng đợt phát hành template mới là ngoại lệ; ngoại lệ không tạo quyền mặc định cho thay đổi sau này.

### 1.3 ADD 4-phase pipeline

ADD đặt Agent làm executor chính trong vòng lặp phát triển. Con người đóng vai **Director** (định hướng và phê duyệt), không phải Executor (gõ code). Human time ≈ 20% (setup + review); AI time ≈ 80% (execute).

```text
ADD PIPELINE

PHA 1: CONTEXT SETUP (một lần, đầu dự án)
  AGENTS.md + CLAUDE.md + CONSTITUTION.md + Constraint Docs
  → Agent biết: Tôi là ai? Dự án này là gì? Giới hạn nào?

PHA 2: INTENT COMMUNICATION (per-feature)
  User Story → Prompt → Definition of Done
  "WHAT" không phải "HOW"

PHA 3: AGENTIC EXECUTION
  Agent tự: Plan → Code → Test → Fix → Iterate
  Human gates: Approve Plan (Shadow Plan) + Approve risky file changes

PHA 4: HUMAN REVIEW & ITERATE
  Review Plan (trước code) → Review Code → Merge/Iterate
```

**Pha 1 — Context Setup:** Đây là pha quan trọng nhất nhưng thường bị bỏ qua. Agent không có "common sense" về dự án của bạn. Mỗi phút đầu tư vào context setup tiết kiệm 10 phút debug sau.

- **AGENTS.md**: Persona, scope, tool permissions, security rules, escalation — "Agent là ai?"
- **CLAUDE.md**: TL;DR, architecture, file structure, lesson learned — "DNA của dự án"
- Sau khi setup xong, kiểm tra bằng cách hỏi Agent: *"Describe lại dự án này cho tôi nghe."* Nếu Agent mô tả đúng architecture, stack và constraints — Pha 1 thành công.

**Pha 2 — Intent Communication:** Mô tả WHAT bạn muốn đạt được + WHY + Definition of Done. Agent tự quyết HOW trong khuôn khổ constraints. Nếu đã có `SPEC.md`, intent chỉ cần là *"implement spec này"*.

**Pha 3 — Agentic Execution:** Agent chạy Plan → Execute → Test loop. Hai human gates:
1. Approve **Shadow Plan** trước khi Agent bắt đầu code (xem section 5.5).
2. Review file changes trước khi commit.

Không can thiệp giữa quá trình trừ khi thấy red flags. Interrupt bằng cách cập nhật document, không phải chat correction — chat correction không persist.

**Pha 4 — Human Review:** Review xảy ra hai lần: plan trước code → code sau plan. Một plan sai được phát hiện ở pha này = 0 dòng code cần xóa.

### 1.4 Ba nguyên tắc bắt buộc

1. **Fix the Spec, not the Code**: Nếu failure do thiếu hoặc mơ hồ về nghiệp vụ, sửa `.sdd/features/{slug}/SPEC.md` trước.
2. **Traceability 100%**: Business method trong `src/usecase/` phải có `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
3. **Fail closed trước Git delivery**: `/git-commit` và `/git-pr` chỉ được tiếp tục khi `/git-validate` trả `READY`.

---

## 2. Thành phần của template

### 2.1 Governance files

| File | Vai trò | Cách con người sử dụng |
| :--- | :--- | :--- |
| `CONSTITUTION.md` | Hard security, architecture và engineering rule profile-aware | Đọc trước khi làm; thay đổi Layer 1/2 sau khi phát hành phải qua RFC. |
| `AGENTS.md` | Persona, permitted path, tool permission và escalation | Xác định Agent được đọc/sửa gì và khi nào phải dừng. |
| `CLAUDE.md` | Human-readable Architecture DNA, naming và anti-pattern | Đồng bộ sau khi profile được duyệt; không dùng để Agent suy đoán stack. |
| `.sdd/architecture-profile.md` | Canonical stack/architecture profile cho artifact generation | Duyệt binding HTTP/DB/ORM/validation/test command trước PLAN/TASKS/Execute. Xem `docs/architecture-profile-guide.md`. |
| `.agentignore` | Context hygiene — exclude pattern cho AI Agent | Thêm pattern khi thấy Agent đọc build artifact hoặc log không liên quan. |
| `.sdd/constraints/global.md` | Global tech baseline, naming và dependency rule | Đọc khi onboard Agent hoặc thêm dependency. |
| `.sdd/constraints/business.md` | Access control, PII masking, rate limiting và data-lifecycle rule | Đọc khi feature liên quan auth, tiền hoặc user data. |
| `.sdd/constraints/safety.md` | DB safety, Git safety, Agent safety | **CRITICAL** — vi phạm làm CI/CD `FAIL`. Đọc trước migration hoặc delete operation. |
| `.sdd/mcp-config.yaml` | MCP tool access control theo Agent | Cấu hình khi dùng multi-agent; solo mode: 1 entry `@developer` với toàn quyền. |

### 2.2 SDD feature files

Mỗi feature nằm tại `.sdd/features/{feature-slug}/`:

| File | Nội dung | Điều kiện để chuyển pha |
| :--- | :--- | :--- |
| `CONTEXT.md` | Problem, pain points, glossary, stakeholders, constraints | Open question quan trọng đã được trả lời hoặc ghi nhận thành giả định được chấp nhận. |
| `SPEC.md` | Functional requirements theo EARS, SemVer, BDD, error và out-of-scope | Human review `APPROVED`; khi implementation-ready phải là `APPROVED & LOCKED`. |
| `PLAN.md` | Clean Architecture, component boundary, data flow, risk | Các quyết định kỹ thuật và rủi ro đã được Tech Lead/Human Director duyệt. |
| `TASKS.md` | Atomic tasks, dependency, file boundary, verification | Task đủ nhỏ, độc lập hoặc có `blockedBy`, có lệnh kiểm chứng. |

### 2.3 Các nhóm command

- **Khởi tạo:** `/sdd-init`, `/sdd-adopt`.
- **Đặc tả:** `/sdd-context`, `/sdd-spec`, `/sdd-plan`, `/sdd-tasks`.
- **Human review:** `/sdd-review`.
- **Thực thi:** `/add-execute`, `/sdd-layer-edit`.
- **Kiểm định và đồng bộ:** `/sdd-update`, `/sdd-trace`, `/sdd-lint`, `/sdd-audit`, `/sdd-sync`.
- **Governance và session:** `/sdd-claude-edit`, `/sdd-agents-edit`, `/sdd-handoff`, `/sdd-resume`.
- **Git delivery:** `/git-validate`, `/git-commit`, `/git-pr`.
- **Domain skills:** `/sql-performance-tuner`, `/api-security-auditor`, `/error-handler-pattern`.
- **Automation:** `scripts/self-heal.sh` (self-healing loop), `scripts/adopt.sh` (brownfield migration).
- **Multi-agent:** Xem `docs/multi-agent-orchestration-guide.md` và `.sdd/mcp-config.yaml`. Solo mode (1 developer): dùng `--team-size=solo` khi `/sdd-init` hoặc `/sdd-adopt`.

---

### 2.4 Architecture Profile — bắt buộc trước technical planning

`.sdd/architecture-profile.md` là source of truth cho mọi tài liệu hoặc code do skills sinh ra. Precedence: **approved profile → repository evidence → explicit command input → core-only baseline**.

Baseline hiện tại chỉ xác nhận **TypeScript + Node.js + Clean Architecture**. Chưa xác nhận HTTP framework, database, ORM/query layer, validation library, test/build/lint commands.

| Pha / Skill | Khi chưa chọn binding cần thiết |
| :--- | :--- |
| `/sdd-context`, `/sdd-spec` | Được tạo artifact business-neutral; ghi unknown như planning blocker. |
| `/sdd-plan`, `/sdd-tasks` | **Dừng**; request Human Director chọn binding + command chính xác. |
| `/add-execute`, `/sdd-layer-edit` | **Dừng**; không tạo adapter code hoặc chạy placeholder command. |
| Technical skills | Chỉ audit framework-neutral rules; trả `CONFIGURATION GAP` cho adapter-specific check. |

Hướng dẫn đủ 5 kịch bản (greenfield, partial stack, brownfield, first plan, stack migration): [`architecture-profile-guide.md`](./architecture-profile-guide.md).

---

## 3. Mô hình trạng thái: đọc đúng từng loại cờ

Không gộp các trạng thái dưới đây. Mỗi loại trả lời một câu hỏi khác nhau.

### 3.1 Trạng thái Human Final Review

Đây là cờ quyết định của con người trong block `## Human Final Review`:

| Status | Ý nghĩa | Agent được làm gì? |
| :--- | :--- | :--- |
| `PENDING` | Chưa có quyết định bền vững của người có thẩm quyền | Phải dừng ở gate; chỉ được báo cần review. |
| `APPROVED` | Người có thẩm quyền chấp thuận đúng phạm vi đã ghi | Được chuyển pha nếu mọi điều kiện khác đạt. |
| `REVISE` | Cần sửa artifact/recommendation theo feedback | Không được execute hoặc chuyển pha; tạo recommendation mới sau khi sửa. |
| `REJECTED` | Không chấp thuận hướng đề xuất | Dừng hướng hiện tại; chỉ tiếp tục khi có hướng/recommendation mới được duyệt. |

`APPROVED` chỉ hợp lệ khi có đủ `Decision`, `Reviewer`, `Reviewed at` và `Follow-up`. Hội thoại, tin nhắn không ghi vào artifact hoặc câu “ok” không phải durable approval.

### 3.2 Trạng thái artifact

- `CONTEXT.md`, `PLAN.md`, `TASKS.md`: thường bắt đầu ở `DRAFT` hoặc `IN_PROGRESS`; chỉ dùng sau khi review `APPROVED`.
- `SPEC.md`: bắt đầu `DRAFT`; chỉ Human Director/Tech Lead được đổi thành `APPROVED & LOCKED` sau khi duyệt recommendation.
- Sửa artifact sau approval làm mất hiệu lực review cũ. Agent phải đưa review về `PENDING` và ghi rõ phần đã thay đổi.

`APPROVED & LOCKED` không có nghĩa là không bao giờ được sửa. Nó có nghĩa là phiên bản Spec hiện tại được phép làm cơ sở cho Plan/Tasks/Execute. Muốn sửa, dùng `/sdd-update`, bump SemVer phù hợp, review lại và lock phiên bản mới.

### 3.3 Cờ task trong `TASKS.md`

| Cờ | Ý nghĩa | Bằng chứng bắt buộc |
| :--- | :--- | :--- |
| `[ ]` | Chưa bắt đầu | Không được coi là hoàn thành. |
| `[/]` | Đang làm dở | Ghi file đã đổi, failure/blocker và bước tiếp theo trong `Current Handoff State`. |
| `[x]` | Đã hoàn thành | Test hoặc lệnh verify tương ứng đã pass. |

Agent không được đổi `[ ]`/`[/]` thành `[x]` nếu chưa có evidence. `TASKS.md` hoàn thành không thay thế Human Final Review.

### 3.4 Kết quả validator và audit

- `PASS`: check đã chạy và đạt.
- `FAIL`: có lỗi; phải xử lý trước khi tiếp tục.
- `WARNING`: có vấn đề cần giải trình hoặc xử lý; với PR strict, warning chưa được chấp thuận sẽ block.
- `N/A (reason)`: không áp dụng, phải ghi lý do cụ thể; không được dùng để che việc chưa chạy.
- `READY`: chỉ do `/git-validate` phát hành khi không còn `FAIL`, diff đúng scope, mọi `N/A` có lý do. Team mode: PR không còn warning unresolved. Solo mode: WARNING là advisory, không block.

---

## 4. AI Recommendation và Human Final Review: thao tác cầm tay chỉ việc

### 4.1 Agent phải tạo block recommendation

Sau mỗi skill tạo, sửa, validate hoặc resume artifact, Agent phải ghi block theo format canonical trong [`.claude/skills/_shared/ai-review-protocol.md`](../.claude/skills/_shared/ai-review-protocol.md):

```markdown
## AI Agent Recommendation
- Status: PENDING HUMAN REVIEW
- Scope: <artifact, feature, or report>
- Recommendation: <đề xuất và bước tiếp theo>
- Evidence: <file, check, test hoặc quan sát>
- Risks and assumptions: <rủi ro và giả định>
- Alternatives considered: <phương án đã cân nhắc>
- Required human decision: <ranh giới cần phê duyệt>

## Human Final Review
- Status: PENDING
- Decision:
- Reviewer:
- Reviewed at:
- Follow-up:
```

Artifact của feature ghi trực tiếp trong artifact; report không thuộc feature ghi ở `.sdd/reviews/`. Không tạo feature giả chỉ để chứa review.

### 4.2 Con người review như thế nào?

Thực hiện theo thứ tự sau, không chỉ đọc dòng `Recommendation`:

1. **Xác định phạm vi:** đọc `Scope` và `Required human decision`; xác nhận Agent đang xin duyệt đúng việc.
2. **Kiểm tra bằng chứng:** mở các file, diff, test output hoặc report được nêu trong `Evidence`; không duyệt chỉ dựa trên lời tóm tắt.
3. **Kiểm tra rủi ro:** xem `Risks and assumptions`; câu hỏi nghiệp vụ chưa được trả lời phải trở thành open question hoặc quyết định rõ ràng.
4. **Kiểm tra phương án:** xem `Alternatives considered`; yêu cầu Agent bổ sung nếu trade-off quan trọng bị bỏ qua.
5. **Kiểm tra phạm vi:** đối chiếu `Out of Scope`, file boundary, security rule và các requirement bị ảnh hưởng.
6. **Chọn một quyết định:** `APPROVED`, `REVISE` hoặc `REJECTED`. Không để `PENDING` rồi yêu cầu Agent tự đoán.
7. **Gọi `/sdd-review`:** truyền đúng target, status, decision, reviewer và follow-up cụ thể; `reviewed-at` tùy chọn, mặc định lấy thời gian hiện tại nếu không điền. Skill sẽ từ chối nếu thiếu field bắt buộc hoặc target không hợp lệ.
8. **Kiểm tra trạng thái sau review:** nếu `REVISE`/`REJECTED`, Agent phải dừng; nếu `APPROVED`, chỉ chuyển pha khi DoD và prerequisite đều đạt.

### 4.3 Cách “lật cờ” approve đúng cách

Dùng `/sdd-review` để ghi quyết định. Skill này kiểm tra target, recommendation, đủ trường bắt buộc, timestamp và điều kiện lock trước khi sửa artifact. Không sửa block review thủ công nếu có thể gọi command.

```text
/sdd-review --feature=feat-user-register --artifact=context --status=APPROVED --decision="Đã duyệt problem, stakeholders, glossary và constraints; đủ cơ sở lập SPEC, chưa duyệt giải pháp kỹ thuật." --reviewer="Nguyen Van A, Product Owner" --reviewed-at="2026-08-22T00:45:00+07:00" --follow-up="/sdd-spec --feature=feat-user-register"
```

Skill sẽ ghi đủ:

```markdown
## Human Final Review
- Status: APPROVED
- Decision: <quyết định cụ thể và phạm vi đã review>
- Reviewer: <identity>
- Reviewed at: <ISO-8601 timestamp có timezone>
- Follow-up: <command hoặc điều kiện tiếp theo>
```

Đối với `SPEC.md`, gọi `/sdd-review` với `--status=APPROVED` sẽ đổi header sang `Status: APPROVED & LOCKED` chỉ khi recommendation hợp lệ và DoD tối thiểu đạt. Không đổi cờ chỉ vì Agent đã hoàn thành file.

Các trạng thái khác:

```text
/sdd-review --target=.sdd/features/feat-user-register/PLAN.md --status=REVISE --decision="Bổ sung rollback migration và dependency direction." --reviewer="Nguyen Van B, Tech Lead" --reviewed-at="2026-08-22T01:10:00+07:00" --follow-up="Cập nhật PLAN.md, tạo recommendation mới rồi review lại."

/sdd-review --target=.sdd/reviews/audit-feat-user-register.md --status=REJECTED --decision="Không chấp thuận disposition vì Layer 1 failure còn mở." --reviewer="Nguyen Van C, Human Director" --reviewed-at="2026-08-22T01:20:00+07:00" --follow-up="Sửa blocker, chạy lại /sdd-audit và tạo report review mới."
```

`REVISE` và `REJECTED` tiếp tục block downstream. Sau khi sửa artifact, Agent phải tạo recommendation mới; Human gọi lại `/sdd-review`. `/sdd-review` không thay thế `/sdd-rfc --approve=<rfc-number>` khi thay đổi `CONSTITUTION.md`.

Ví dụ yêu cầu sửa:

```markdown
## Human Final Review
- Status: REVISE
- Decision: Bổ sung behavior khi OTP hết hạn và giới hạn số lần gửi lại; cập nhật BDD,
  error table và bump patch version.
- Reviewer: Nguyen Van A, Tech Lead
- Reviewed at: 2026-08-21T23:35:00+07:00
- Follow-up: `/sdd-update --feature=feat-user-register --bump=patch --reason="Clarify OTP expiry and resend limit"`
```

Ví dụ từ chối:

```markdown
## Human Final Review
- Status: REJECTED
- Decision: Không chọn phương án lưu OTP trong database; chuyển sang phương án đã
  thống nhất dùng provider ngoài và tạo recommendation mới.
- Reviewer: Nguyen Van A, Human Director
- Reviewed at: 2026-08-21T23:40:00+07:00
- Follow-up: Tạo lại PLAN với phương án provider ngoài.
```

Không xóa recommendation cũ, không sửa timestamp của quyết định cũ để “hợp thức hóa” thay đổi mới. Khi artifact thay đổi sau approval, giữ evidence thay đổi và tạo recommendation/review mới.

### 4.4 Ai có quyền approve?

- **Business behavior, Context, execution và resume:** Human Director hoặc người được ủy quyền.
- **Requirement, acceptance và Spec lock:** Product Owner/Human Director phối hợp Tech Lead.
- **Architecture, governance và RFC:** Tech Lead hoặc Architecture Board theo `CONSTITUTION.md`.
- **Code/test evidence:** Developer/QA có thể góp ý và xác nhận evidence; không tự thay thế reviewer được chỉ định.

Agent chỉ ghi nội dung do reviewer cung cấp. Agent không tự điền tên người, thời gian hoặc quyết định của con người.

---

## 5. Vòng đời feature chuẩn

```text
CONTEXT -> /sdd-review APPROVED -> SPEC -> /sdd-review APPROVED + LOCK
-> PLAN -> /sdd-review APPROVED -> TASKS -> /sdd-review APPROVED
-> EXECUTE -> /sdd-review APPROVED -> VERIFY -> /sdd-review disposition
-> SYNC -> /sdd-review APPROVED -> COMMIT -> PR
```

| Pha | Command | Agent tạo ra | Con người phải làm | Điều kiện chuyển pha |
| :--- | :--- | :--- | :--- | :--- |
| 0. Context | `/sdd-context --feature=<slug>` | `CONTEXT.md` + recommendation | Xác nhận problem, glossary, stakeholder, constraint và open question | Review `APPROVED` |
| 1. Spec | `/sdd-spec --feature=<slug>` | `SPEC.md` + recommendation | Kiểm tra EARS, BDD, error, NFR, out-of-scope, SemVer; lock Spec | `APPROVED` + `APPROVED & LOCKED` |
| 2. Plan | `/sdd-plan --feature=<slug>` | `PLAN.md` + recommendation | Duyệt boundary, data flow, dependency, risk và câu hỏi kỹ thuật | Review `APPROVED` |
| 3. Tasks | `/sdd-tasks --feature=<slug>` | `TASKS.md` + recommendation | Kiểm tra task atomic, file boundary, dependency, verify command | Review `APPROVED` |
| 4. Execute | `/add-execute --feature=<slug>` | Code + tests + evidence | Review diff, self-check, test output, scope creep và Spec gap | Review execution `APPROVED` |
| 5. Verify | `/sdd-lint`, `/sdd-audit`, `/sdd-trace` | Lint/audit/trace reports | Xử lý blocker hoặc ghi disposition có lý do | Không còn blocker; warning được chấp thuận nếu applicable |
| 6. Sync | `/sdd-sync` | Registry + shared contracts | Kiểm tra feature/version/contract không drift | Review sync `APPROVED` |
| 7. Commit | `/git-validate`, `/git-commit` | Git commit | Xác nhận intended files và commit message | Validation `READY` |
| 8. Push / PR | `/git-pr` | Push trực tiếp (solo) hoặc Pull Request (team) | Solo: push lên branch hiện tại. Team: xác nhận nội dung outward-facing | Remote validation `READY`; checks được báo đúng trạng thái |

### 5.1 Pha 0 — Context

```text
/sdd-context --feature=feat-user-register
```

Con người cung cấp problem, user pain, desired behavior, glossary, stakeholder và ràng buộc. Không yêu cầu Agent chọn framework hoặc thiết kế database ở pha này.

Review `CONTEXT.md`:

- Nếu thuật ngữ còn hiểu khác nhau, sửa glossary trước khi approve.
- Nếu open question ảnh hưởng business behavior, trả lời hoặc ghi giả định kèm người chịu trách nhiệm.
- Nếu tài liệu đã bắt đầu mô tả giải pháp kỹ thuật, yêu cầu tách phần đó sang Plan.
- Chỉ ghi `APPROVED` khi đủ thông tin để viết requirement, không phải khi mọi chi tiết implementation đã xong.

### 5.2 Pha 1 — Spec

```text
/sdd-spec --feature=feat-user-register
```

Con người kiểm tra:

- Mỗi requirement có `REQ-XXX` duy nhất và dùng EARS.
- Có happy path, invalid input, unauthorized, timeout, duplicate và edge case phù hợp.
- BDD có thể chuyển thành test; error table có error code, behavior và mitigation; transport-specific status chỉ thêm khi binding đã được chọn.
- NFR có ngưỡng đo được; `Out of Scope` chặn Agent thêm tính năng ngoài yêu cầu.
- SemVer và changelog phản ánh đúng mức độ thay đổi.

Chạy lint trước khi lock nếu cần:

```text
/sdd-lint --feature=feat-user-register
```

Sau khi review đủ bằng chứng, gọi `/sdd-review --target=.sdd/features/feat-user-register/SPEC.md --status=APPROVED` với đủ `--decision`, `--reviewer` và `--follow-up`; `--reviewed-at` tùy chọn, mặc định lấy ISO-8601 timestamp hiện tại nếu không điền. Skill sẽ lock `SPEC.md` thành `Status: APPROVED & LOCKED` nếu DoD đạt. Nếu sửa Spec sau đó, phải `/sdd-update`, review lại và lock lại.

### 5.3 Pha 2 — Plan

```text
/sdd-plan --feature=feat-user-register
```

Con người đối chiếu:

- Dependency direction đúng: interface gọi usecase; usecase phụ thuộc domain và port; infra triển khai port; domain không phụ thuộc adapter.
- Controller không truy cập DB trực tiếp.
- Mỗi requirement có component xử lý và file boundary rõ.
- Data flow có input/event, validation khi binding yêu cầu, usecase, persistence/external service khi feature dùng và output/error contract phù hợp transport.
- Rủi ro security, race condition, performance, migration và rollback có mitigation.
- `Questions for Human` đã được trả lời hoặc được chấp thuận thành assumption.

### 5.4 Pha 3 — Tasks

```text
/sdd-tasks --feature=feat-user-register
```

Con người kiểm tra từng task:

- Có ID, file boundary, requirement reference và lệnh verify.
- Atomic: không chứa nhiều mục tiêu không liên quan.
- Independent hoặc có dependency rõ bằng `blockedBy`.
- Không đánh dấu `[x]` trước khi test pass.
- Không có task ngầm vượt `Out of Scope` hoặc sửa file ngoài quyền hạn.

### 5.5 Pha 4/5 — Execute và Verify

```text
/add-execute --feature=feat-user-register
/sdd-lint --feature=feat-user-register
/sdd-audit --feature=feat-user-register
/sdd-trace --feature=feat-user-register
```

Trước khi thực thi mỗi task, Agent BẮT BUỘC xuất **Shadow Plan** (Slide 10.6.1) theo format:

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

Human Director xác nhận Shadow Plan trước khi Agent thực thi. Nếu scope thay đổi trong khi thực thi, Agent dừng và xuất Shadow Plan mới.

Agent phải đọc `AGENTS.md`, `CONSTITUTION.md`, `.sdd/constraints/` (global, business, safety), `SPEC.md`, `PLAN.md` và `TASKS.md`; chạy self-check và test. Con người review diff theo thứ tự:

1. Có sửa đúng task và file boundary không?
2. Có thay đổi behavior nào không nằm trong Spec không?
3. Có secret, PII, auth, hard-delete hoặc vi phạm Clean Architecture không?
4. Business method có `@ears` trace không; test có evidence kiểm chứng requirement không?
5. Test output có thật sự pass; failure nào bị che hoặc đổi thành warning không?
6. Requirement nào chưa có code/test hoặc code nào mồ côi?

Nếu test fail:

1. Đọc failure và phân loại **code bug** hay **Spec gap**.
2. Nếu là Spec gap, không cho Agent vá code ngẫu nhiên; yêu cầu cập nhật Spec và bump SemVer.
3. Review Spec mới, cập nhật Plan/Tasks nếu bị ảnh hưởng.
4. Execute lại từ pha bị ảnh hưởng.
5. Chạy lại lint, audit, trace và ghi evidence mới.

### 5.6 Đồng bộ registry và shared contracts

```text
/sdd-sync
```

Dùng sau khi feature, API contract, DTO, event schema hoặc state dùng chung thay đổi. Con người đối chiếu `.sdd/README.md` và `.sdd/shared_context.md` với các feature thật; không chấp nhận placeholder hoặc contract đã cũ. Review recommendation trong `.sdd/reviews/sync.md` trước Git delivery.

---

## 6. Review theo từng loại thay đổi

### 6.1 Review Context

Duyệt **vấn đề**, chưa duyệt giải pháp. Câu hỏi cần trả lời:

- Ai gặp vấn đề và bằng chứng là gì?
- Behavior mong muốn khác hiện trạng ở điểm nào?
- Thuật ngữ/trạng thái nào có thể gây hiểu sai?
- Ai là người quyết định cuối?
- Ràng buộc nào là hard constraint?
- Còn câu hỏi nào nếu sai sẽ làm thay đổi phạm vi?

### 6.2 Review Spec

Duyệt **hợp đồng behavior**. Không approve nếu requirement chỉ nói “nhanh”, “linh hoạt”, “thân thiện” mà không có ngưỡng/điều kiện đo được. Kiểm tra cả behavior không mong muốn, permission, retry, timeout, duplicate, consistency và dữ liệu nhạy cảm.

### 6.3 Review Plan

Duyệt **cách thực hiện**, không âm thầm thay đổi business behavior. Nếu Plan cần behavior mới, quay lại Spec; không lén thêm vào Plan để tránh review.

### 6.4 Review Tasks

Duyệt **đơn vị giao việc**. Mỗi task phải có đầu ra kiểm chứng được. Nếu một task quá lớn, yêu cầu tách trước khi approve; nếu dependency vòng, sửa Plan/Tasks trước khi execute.

### 6.5 Review Execution

Duyệt **kết quả đã thực thi** dựa trên diff và evidence, không dựa vào câu “đã xong”. Bắt buộc xem test command/result, các file thay đổi, trace và các warning còn lại.

### 6.6 Disposition của lint/audit/trace

Human Director/Tech Lead chọn một trong ba cách:

- **Remediate:** yêu cầu sửa blocker/warning, chạy validator lại.
- **Accept with rationale:** chỉ dùng khi rule cho phép warning được giải trình; ghi rõ lý do, phạm vi và residual risk.
- **Reject delivery:** không cho commit/PR khi rủi ro hoặc broken trace chưa được xử lý.

Layer 1 failure, broken trace, orphan code và missing test trace không được coi là “đã chấp thuận” chỉ bằng comment chung chung.

---

## 7. Cập nhật artifact SDD đúng cách

`/sdd-update` cập nhật bất kỳ artifact SDD đã approved mà không sinh lại từ đầu. Dùng `--artifact=<spec|context|plan|tasks>` để chỉ định artifact cần sửa.

| Tình huống | Lệnh |
| :--- | :--- |
| Sửa/thêm requirement trong Spec đã lock | `/sdd-update --artifact=spec --bump=<patch\|minor\|major>` |
| Cập nhật stakeholder, constraint hoặc glossary trong Context | `/sdd-update --artifact=context` |
| Sửa component/risk trong Plan mà Spec không đổi | `/sdd-update --artifact=plan` |
| Thêm/sửa task mà Plan không đổi | `/sdd-update --artifact=tasks` |

Mặc định `--artifact=spec` nếu không truyền tham số.

### 7.1 Bug hoặc điều kiện biên nhỏ trong Spec

```text
/sdd-update --feature=feat-user-register --artifact=spec --bump=patch \
  --reason="[REQ-003] Add OTP rate-limit: max 5 attempts per 10 minutes, return 429"
```

Spec về `DRAFT`; review cũ bị invalidate. Human Director review recommendation mới và ghi `APPROVED & LOCKED` trước khi execute:

```text
/add-execute --feature=feat-user-register
/sdd-lint    --feature=feat-user-register
/sdd-trace   --feature=feat-user-register --diff
```

### 7.2 Behavior tương thích mới

```text
/sdd-update --feature=feat-user-register --artifact=spec --bump=minor \
  --reason="Add optional account recovery flow via email"
```

Review lại recommendation. Nếu Plan/Tasks bị ảnh hưởng, dùng `/sdd-update --artifact=plan` hoặc `/sdd-update --artifact=tasks` (hoặc sinh lại với `/sdd-plan`, `/sdd-tasks` nếu thay đổi lớn). Ghi `APPROVED`, rồi mới execute.

### 7.3 Thay đổi phá vỡ contract

```text
/sdd-update --feature=feat-user-register --artifact=spec --bump=major \
  --reason="Change registration response: remove token from body, use httpOnly cookie"
```

Phải ghi migration plan, rollback plan và risk trong Spec. Tech Lead/Human Director approve Spec mới → cập nhật Plan/Tasks → execute. Sau execute, chạy `/sdd-sync` nếu shared contract thay đổi.

### 7.4 Cập nhật Context, Plan hoặc Tasks (không đổi Spec)

```text
# Thêm compliance constraint vào Context
/sdd-update --feature=feat-user-register --artifact=context \
  --reason="Add GDPR constraint: user data must be deletable within 30 days"

# Sửa risk trong Plan sau security review
/sdd-update --feature=feat-user-register --artifact=plan \
  --reason="Add Redis session token risk and mitigation after security review"

# Thêm task edge case phát hiện lúc implement
/sdd-update --feature=feat-user-register --artifact=tasks \
  --reason="Add T009 for concurrent registration dedup check"
```

Mỗi loại artifact update đều invalidate review cũ và tạo recommendation mới cần Human Director approve trước khi tiếp tục.

---

## 8. Các kịch bản vận hành thường gặp

### 8.1 Greenfield — tạo dự án mới

```bash
git clone <template-url> my-project
cd my-project
/sdd-init --project-name="my-project" --stack="Node.js + TypeScript"
```

Sau đó đọc `CONSTITUTION.md`, `AGENTS.md`, `CLAUDE.md`, xác nhận binding và exact verification command cần thiết trong Architecture Profile, rồi chạy `/sdd-context` cho feature đầu tiên. HTTP framework, database, ORM/query layer và validation chỉ được thêm vào profile khi có evidence hoặc Human decision.

### 8.2 Brownfield — tích hợp repo có sẵn

Linux/macOS/Git Bash:

```bash
./scripts/adopt.sh /path/to/existing-repository
```

Windows PowerShell:

```powershell
.\scripts\adopt.ps1 -TargetPath C:\Projects\existing-repository
```

Sau migration, mở repo đích và chạy `/sdd-adopt`. Chỉ dùng `--force`/`-Force` sau khi con người đã xác nhận file đích được phép ghi đè.

### 8.3 Reverse Spec module legacy

```text
/sdd-adopt --reverse-feature=feat-legacy-auth --path=src/modules/auth
```

Reverse Spec chỉ mô tả behavior hiện tại; không chứng minh behavior đó đúng về business. Owner phải review trước khi refactor.

### 8.4 Bug hoặc test fail

Ví dụ thiếu rate limit OTP:

```text
/sdd-update --feature=feat-user-register --artifact=spec --bump=patch \
  --reason="[REQ-003] Add OTP rate-limit: max 5 attempts per 10 minutes"
/add-execute --feature=feat-user-register
/sdd-trace   --feature=feat-user-register --diff
/sdd-audit   --feature=feat-user-register
```

Nếu failure là code bug đã có Spec rõ, sửa code theo Spec. Nếu failure là business rule chưa được nêu, sửa Spec trước.

### 8.5 RFC thay đổi Constitution

```text
/sdd-rfc --title=soft-delete-policy
```

Tech Lead/Human Director ghi motivation, proposed change, risk và migration plan trong `.sdd/rfcs/RFC-XXX-*.md`. Sau khi reviewer có thẩm quyền approve, dùng:

```text
/sdd-rfc --approve=<rfc-number>
```

Lệnh `--approve` chỉ dành cho Tech Lead theo contract của `/sdd-rfc`. Trước khi chạy, reviewer phải kiểm tra RFC đã có recommendation, review block, decision, identity và timestamp; không dùng lệnh này để thay thế Human Final Review. Sau khi template phát hành, không sửa trực tiếp `CONSTITUTION.md`; Git Operator sẽ block thay đổi Constitution không có RFC approved. Một explicit Human authorization cho đợt phát hành template chỉ là ngoại lệ đúng phạm vi, không phải quyền mặc định của Agent.

### 8.6 Thay đổi xuyên bốn tầng

```text
/sdd-layer-edit --feature=feat-order-checkout --action=modify
```

Con người kiểm tra domain, usecase, interface, infra và test theo Plan. Không cho controller truy cập DB trực tiếp.

### 8.7 Handoff và resume

Khi dừng giữa chừng:

```text
/sdd-handoff --feature=feat-order-checkout
```

Xác nhận `TASKS.md` dùng đúng `[x]`, `[/]`, `[ ]`; kiểm tra `Current Handoff State` có file đã đổi, test evidence, blocker và next command. Phiên sau:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Continue
/sdd-resume --feature=feat-order-checkout
```

Review recommendation của handoff trước khi cho Agent tiếp tục execute.

### 8.8 Docs/skill/governance-only change

Khi không có source behavior:

```text
/sdd-audit
/git-validate --scope=commit
/git-commit --message="docs(guide): clarify SDD ADD human workflow"
```

Validator ghi `N/A` cho trace/test chỉ khi repository thực sự không có source/test tương ứng, kèm lý do.

### 8.9 Self-Healing Loop — tự động hóa test thất bại có kiểm soát

Dùng khi đã có exact test command trong Architecture Profile và cần vòng lặp test → phân tích lỗi → sửa → re-test:

```bash
# Bắt buộc truyền exact test command đã approved
./scripts/self-heal.sh --test-cmd="<approved test command>"

# --feature chỉ thêm context vào log/report, không thay đổi test command
./scripts/self-heal.sh --test-cmd="<approved test command>" --feature=feat-user-register

# Giới hạn số lần thử
./scripts/self-heal.sh --test-cmd="<approved test command>" --max-attempts=2

# Xem configuration mà không chạy test hoặc gọi Claude
./scripts/self-heal.sh --test-cmd="<approved test command>" --dry-run
```

**Flow tự động:**
1. Kiểm tra `--test-cmd`; thiếu command thì block ngay.
2. Chạy command; nếu `PASS`, dừng, không cần healing.
3. Nếu `FAIL`, trích xuất error summary rồi gọi `claude --print` để phân tích và áp dụng sửa đổi.
4. Chạy lại chính exact command đó, tối đa `--max-attempts` lần; mặc định là 3.
5. Nếu pass sau khi sửa, giữ toàn bộ thay đổi **uncommitted** để Human review.
6. Nếu cạn số lần thử, tạo incident report tại `.sdd/reviews/self-heal-incident-<timestamp>.md` và escalate Human Director.

**Không dùng self-heal khi:**
- Failure là Spec gap; phải `/sdd-update` Spec và review trước.
- Failure ảnh hưởng DB schema hoặc migration; cần Human Final Review trước execution.
- Không có approved test command hoặc command/profile evidence không khớp.
- Đang ở production; script không phải cơ chế deploy hoặc bypass review.

**Yêu cầu:** `claude` CLI phải được cài và authenticated. `self-heal.sh` không tự commit, không tự thêm test filter theo framework và không thay thế `/add-execute` hoặc Human Final Review. Xem `.sdd/constraints/safety.md` → `AGT-S-01..05` trước khi dùng.

### 8.10 Multi-Agent — orchestrate parallel sub-agents

Trước khi dispatch, Lead phải đọc approved `.sdd/architecture-profile.md`, kiểm tra `TASKS.md`, và xuất Shadow Plan gồm: profile version, selected bindings/evidence, task ownership, dependency batches, exact commands, và shared files. Human Director approve Shadow Plan trước execution.

Mỗi sub-agent chỉ nhận task IDs, file boundary, profile binding, MCP profile, và command đã verified. Agents update `.sdd/shared_context.md`; Lead verify contracts/bindings sau từng batch. Không sub-agent nào được introduce adapter hoặc package ngoài profile.

Sau integration: `/sdd-audit` → `/sdd-trace` → `/git-validate --scope=commit`. Xem [`multi-agent-orchestration-guide.md`](./multi-agent-orchestration-guide.md).

> **Solo mode:** Developer tự dispatch, tự verify, tự review. Shadow Plan đơn giản hơn — không parallel batch, không ownership boundary. Xem section 8 trong `multi-agent-orchestration-guide.md`.

### 8.11 Domain Technical Skill — audit chuyên sâu

```text
/sql-performance-tuner --feature=feat-order-checkout --mode=audit
/api-security-auditor --feature=feat-order-checkout
/error-handler-pattern --feature=feat-order-checkout --mode=audit
```

Skills chỉ tạo adapter-specific findings khi profile đã chọn stack; nếu không, report `CONFIGURATION GAP`. Xem [`architecture-profile-guide.md`](./architecture-profile-guide.md). CRITICAL phải sửa trước `/git-validate`; HIGH cần disposition.

---

## 9. Requirement Traceability và Impact Analysis

Ma trận truy vết chuẩn:

```text
SPEC.md (REQ-XXX)
  -> PLAN.md
  -> TASKS.md
  -> src/ (@ears)
  -> tests/ (@ears)
```

Truy vết một requirement:

```text
/sdd-trace --feature=feat-user-register --req=REQ-001
```

Kiểm tra toàn feature:

```text
/sdd-trace --feature=feat-user-register
```

Phân tích sau Spec change:

```text
/sdd-trace --feature=feat-user-register --diff
```

Các trạng thái phải xử lý trước PR:

- **Untraced requirement:** Spec có REQ nhưng thiếu code hoặc test.
- **Orphan code:** business method thiếu `@ears` hoặc trỏ tới REQ không tồn tại.
- **Outdated implementation:** code/test chưa theo version Spec mới.
- **Missing test:** có code nhưng chưa có test verify.

Human reviewer phải quyết định remediation hoặc dừng delivery; không đánh dấu covered chỉ vì Agent có nêu tên file.

---

## 10. EARS notation cheat sheet

| Loại | Mẫu | Ví dụ |
| :--- | :--- | :--- |
| Ubiquitous | `The <system> SHALL <action>` | `The system SHALL encrypt stored passwords.` |
| Event-driven | `WHEN <trigger>, the <system> SHALL <action>` | `WHEN user submits order, the system SHALL create a pending transaction.` |
| State-driven | `WHILE <state>, the <system> SHALL <action>` | `WHILE gateway is unavailable, the system SHALL show a maintenance notice.` |
| Optional | `WHERE <feature>, the <system> SHALL <action>` | `WHERE biometric login is enabled, the system SHALL request biometric verification.` |
| Unwanted | `IF <invalid condition>, THEN the <system> SHALL <action>` | `IF OTP attempts exceed the limit, THEN the system SHALL return 429.` |

Requirement cần tránh từ mơ hồ như “nhanh chóng”, “linh hoạt”, “đẹp”, “nếu cần thiết”. Thay bằng ngưỡng, trạng thái, input và output có thể test.

---

## 11. Quality gates trước khi báo hoàn thành

### 11.1 Checklist cho Human Director / Tech Lead

- [ ] Artifact hiện tại có recommendation và Human Final Review block canonical.
- [ ] Review status không còn `PENDING`, `REVISE` hoặc `REJECTED` trước khi chuyển pha.
- [ ] `APPROVED` có decision cụ thể, reviewer identity và timestamp.
- [ ] Nếu artifact đã sửa sau approval, review cũ đã bị invalidate và review mới ở `PENDING`.
- [ ] `SPEC.md` ở `APPROVED & LOCKED`, có SemVer và changelog.
- [ ] Requirement có EARS, acceptance, error/edge cases và out-of-scope.
- [ ] Plan/Tasks khớp Spec; task có dependency, file boundary và verify command.
- [ ] **Shadow Plan đã được xuất và confirmed trước mỗi task execution** (`/add-execute`).
- [ ] Business methods có `@ears` reference hợp lệ.
- [ ] Controller không truy cập DB trực tiếp; không có secret hoặc PII trong log.
- [ ] **Đã kiểm tra `.sdd/constraints/safety.md` trước mọi DB mutation hoặc delete operation.**
- [ ] Test happy path và error/edge cases đã chạy; failure không bị che.
- [ ] `/sdd-lint`, `/sdd-audit`, `/sdd-trace` đã chạy khi applicable.
- [ ] `/sdd-sync` đã chạy khi feature/contract/registry thay đổi.
- [ ] Mọi warning còn lại có disposition và residual risk rõ.
- [ ] `/git-validate` trả `READY` trước commit hoặc PR.

### 11.2 Git Operator rules

| Scope | Nguồn diff | Required gate |
| :--- | :--- | :--- |
| Commit | `git diff --cached` | `/git-validate --scope=commit` |
| Push (solo) | `origin/<base>...origin/<head>` | `/git-validate --scope=pr --strict` |
| PR (team) | `origin/<base>...origin/<head>` | `/git-validate --scope=pr --strict` |

**Solo mode**: Sau commit, `/git-commit` tự động push lên branch hiện tại. `/git-pr` push trực tiếp, không tạo PR. WARNING là advisory, chỉ FAIL block.

**Team mode**: Sau commit, cần `/git-pr` để tạo Pull Request. `--strict` bắt buộc; WARNING convert thành FAIL.

`READY` không được phát hành nếu diff rỗng, còn `FAIL`, (team) PR còn warning chưa giải trình, hoặc review artifact không hợp lệ.

### 11.3 Checklist kết thúc session

1. Mọi task intended có trạng thái rõ.
2. `[x]` chỉ dùng khi test/verify pass.
3. Evidence mới nhất được ghi trong handoff hoặc report.
4. Blocker, open question và giả định không bị che giấu.
5. Review pending được nêu rõ, không tự approve.
6. Next step có command cụ thể.

---

## 12. Nguyên tắc ghi nhớ nhanh

1. Con người quyết định **làm gì và chấp nhận rủi ro nào**; Agent đề xuất và thực thi **cách làm trong phạm vi đã duyệt**.
2. `PENDING` nghĩa là dừng, không phải “chờ Agent tự xử lý”.
3. `APPROVED` phải nằm trong artifact, có người, quyết định và timestamp.
4. `REVISE` và `REJECTED` đều block downstream; sửa xong phải tạo recommendation mới.
5. Sửa artifact sau approval làm review cũ mất hiệu lực.
6. `[x]` là trạng thái task có evidence; không phải approval của con người.
7. `PASS` là kết quả của một check; `READY` là quyết định cuối của Git validation.
8. Khi Spec chưa rõ, quay lại Spec; không vá code để che lỗ hổng yêu cầu.
9. Khi chưa đủ bằng chứng, báo thiếu bằng chứng; không báo hoàn thành giả.
10. **Shadow Plan trước mỗi task** — Agent xuất kế hoạch, Human xác nhận, rồi mới thực thi.
11. **Đọc `.sdd/constraints/`** — global (stack), business (auth/PII/rate-limit), safety (DB/git) trước khi code bất kỳ thứ gì.
12. **Self-heal có giới hạn** — max 3 attempts; Spec gap và DB change luôn cần Human review; không dùng trên production.

### Cheat Sheet — Kịch bản → Command

| Kịch bản | Command đầu tiên |
| :--- | :--- |
| Dự án mới | `./scripts/adopt.sh` hoặc `/sdd-init` |
| Feature mới | `/sdd-context --feature=<slug>` |
| Test thất bại (code bug) | `/add-execute` lại sau khi fix |
| Test thất bại (Spec gap) | `/sdd-update --artifact=spec --bump=patch --reason=...` |
| Sửa Context đã approved | `/sdd-update --artifact=context --reason=...` |
| Sửa Plan đã approved (Spec không đổi) | `/sdd-update --artifact=plan --reason=...` |
| Thêm task (Plan không đổi) | `/sdd-update --artifact=tasks --reason=...` |
| CI fail, muốn tự động sửa | `./scripts/self-heal.sh --test-cmd="<approved test command>" --feature=<slug>` |
| Audit SQL performance | `/sql-performance-tuner --feature=<slug>` |
| Audit API security | `/api-security-auditor --feature=<slug>` |
| Chuẩn hóa error handling | `/error-handler-pattern --mode=scaffold` |
| Feature lớn cần multi-agent | Đọc `docs/multi-agent-orchestration-guide.md` |
| Solo workflow (1 developer) | Dùng `--team-size=solo` khi init/adopt; xem `docs/multi-agent-orchestration-guide.md` section 8 |
| Thay đổi Constitution | `/sdd-rfc --title=<change>` → approve → `/sdd-rfc --approve=<number>` |
| Commit code (solo) | `/git-validate` → `READY` → `/git-commit` (auto-push) |
| Commit code (team) | `/git-validate` → `READY` → `/git-commit` → `/git-pr` |
