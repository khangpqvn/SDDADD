# HƯỚNG DẪN SDD + ADD VÀ VẬN HÀNH TEMPLATE

# Version: 4.0.0
# Target: Developers, Tech Leads, QA, AI Assistants

Tài liệu này là runbook vận hành cho Starter Template SDD + ADD. Template cung cấp governance files, đặc tả theo feature, slash commands và Git Operator gates. Quy tắc bất biến nằm ở [`CONSTITUTION.md`](../CONSTITUTION.md); phạm vi và quyền của Agent nằm ở [`AGENTS.md`](../AGENTS.md).

---

## 1. SDD + ADD là gì?

### 1.1 SDD — Spec-Driven Development

SDD coi đặc tả là nguồn sự thật cho hành vi nghiệp vụ. Trước khi viết code, team mô tả:

- bài toán và thuật ngữ trong `CONTEXT.md`;
- yêu cầu có thể kiểm chứng trong `SPEC.md`;
- kiến trúc và rủi ro trong `PLAN.md`;
- công việc nguyên tử và tiêu chí hoàn thành trong `TASKS.md`.

Code và test là artifacts được sinh/triển khai từ đặc tả. Khi behavior chưa rõ hoặc test cho thấy thiếu trường hợp, cập nhật Spec trước rồi mới đồng bộ code.

### 1.2 ADD — Agent-Driven Development

ADD dùng AI Agent như executor dưới sự chỉ đạo của Human Director:

- Human Director quyết định business behavior, trade-off, approval và ngoại lệ.
- Agent đọc Context/Spec/Plan/Tasks, thực thi trong phạm vi được phép và báo evidence.
- Agent không tự sửa `CONSTITUTION.md`, không tự bypass quality gate và không tự push/deploy.

### 1.3 Ba nguyên tắc bắt buộc

1. **Fix the Spec, not the Code**: test fail do thiếu hoặc mơ hồ về nghiệp vụ thì sửa `.sdd/features/{slug}/SPEC.md` trước.
2. **Traceability 100%**: business method trong `src/usecase/` phải có `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
3. **Fail closed trước Git delivery**: `/git-commit` và `/git-pr` chỉ thực hiện sau khi `/git-validate` trả `READY`.

---

## 2. Thành phần của template

### 2.1 Governance files

| File | Vai trò | Quy tắc sử dụng |
| :--- | :--- | :--- |
| `CONSTITUTION.md` | Hard security, architecture và engineering rules | Không sửa trực tiếp; thay đổi Layer 1/2 phải qua RFC approved |
| `AGENTS.md` | Persona, permitted paths, tool permissions và escalation | Agent phải đọc trước khi thực thi |
| `CLAUDE.md` | Architecture DNA, naming và anti-patterns | Cập nhật khi kiến trúc hoặc tech stack thay đổi |

### 2.2 SDD feature files

Mỗi feature nằm tại `.sdd/features/{feature-slug}/`:

| File | Nội dung | DoD chính |
| :--- | :--- | :--- |
| `CONTEXT.md` | Problem, pain points, glossary, stakeholders, constraints | Không còn open question quan trọng chưa được ghi nhận |
| `SPEC.md` | Functional requirements theo EARS, SemVer, trạng thái review | Requirement rõ, duy nhất, có error/edge cases |
| `PLAN.md` | Clean Architecture, component boundary, data flow, risk | Có mapping từ requirement tới component |
| `TASKS.md` | Atomic tasks, dependencies, files, verification commands | Mỗi task independent hoặc có dependency rõ và verifiable |

### 2.3 Skills theo vòng đời

Các skill local nằm trong `.claude/skills/`. Nhóm chính:

- Khởi tạo: `/sdd-init`, `/sdd-adopt`.
- Đặc tả: `/sdd-context`, `/sdd-spec`, `/sdd-plan`, `/sdd-tasks`.
- Thực thi: `/add-execute`, `/sdd-layer-edit`.
- Đồng bộ và kiểm định: `/sdd-update`, `/sdd-trace`, `/sdd-lint`, `/sdd-audit`, `/sdd-sync`.
- Governance và session: `/sdd-claude-edit`, `/sdd-agents-edit`, `/sdd-handoff`, `/sdd-resume`.
- Git delivery: `/git-validate`, `/git-commit`, `/git-pr`.

Skill file là owner của command contract. Tài liệu này chỉ mô tả thứ tự vận hành và quyết định khi nào dùng command.

---

## 3. Bắt đầu với template

### 3.1 Greenfield — tạo dự án mới

Dùng khi repository chưa có cấu trúc SDD + ADD:

```bash
# Clone template hoặc tạo repository từ template
git clone <template-url> my-project
cd my-project

# Khởi tạo/điều chỉnh bộ khung
/sdd-init --project-name="my-project" --stack="Node.js + TypeScript + PostgreSQL"
```

Sau khi khởi tạo:

1. Đọc `CONSTITUTION.md`, `AGENTS.md`, `CLAUDE.md`.
2. Xác nhận stack, clean architecture và test command phù hợp repository.
3. Kiểm tra `.sdd/README.md`, `.sdd/shared_context.md` và `.claude/skills/`.
4. Chạy `/sdd-context --feature=<slug>` để bắt đầu feature đầu tiên.

Không coi việc tạo thư mục là feature đã hoàn thành. Feature chỉ bắt đầu khi có Context và Spec được review.

### 3.2 Brownfield — tích hợp vào repository có sẵn

Dùng script native khi cần copy framework vào repository đang tồn tại. Script không ghi đè file đích mặc định.

**Linux, macOS hoặc Git Bash:**

```bash
./scripts/adopt.sh /path/to/existing-repository
./scripts/adopt.sh ../existing-repository
```

**Windows PowerShell:**

```powershell
.\scripts\adopt.ps1 -TargetPath C:\Projects\existing-repository
.\scripts\adopt.ps1 ..\existing-repository
```

Chỉ dùng `--force` khi đã xác nhận file đích có thể bị ghi đè:

```bash
./scripts/adopt.sh /path/to/existing-repository --force
```

```powershell
.\scripts\adopt.ps1 -TargetPath C:\Projects\existing-repository -Force
```

Sau migration, mở repository đích và chạy:

```text
/sdd-adopt
```

`/sdd-adopt` phải được dùng để điều chỉnh governance theo tech stack thực tế, không giả định repository legacy đã tuân thủ Clean Architecture.

### 3.3 Reverse Spec cho module legacy

Dùng khi cần refactor module cũ nhưng behavior hiện tại chưa có Spec:

```text
/sdd-adopt --reverse-feature=feat-legacy-auth --path=src/modules/auth
```

Review reverse Spec với owner trước khi sửa code. Reverse Spec mô tả behavior đang tồn tại; nó không tự động chứng minh behavior đó đúng về business.

### 3.4 Khởi động session

**Windows PowerShell:**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1
```

**Bash:**

```bash
./scripts/start-claude.sh
```

Tiếp tục session gần nhất:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Continue
```

```bash
./scripts/start-claude.sh -c
```

Các script khởi động dùng chế độ `--dangerously-skip-permissions`. Chỉ chạy trong repository và môi trường đã được kiểm soát; không đặt secrets trong prompt hoặc file log.

---

## 4. Vòng đời feature chuẩn

Mỗi feature đi qua các pha sau. Không chuyển pha khi DoD của pha hiện tại chưa đạt. Mỗi pha phải tạo AI recommendation và chờ Human Director/Tech Lead review theo [AI Recommendation & Human Final Review Protocol](../.claude/skills/_shared/ai-review-protocol.md). Recommendation được lưu bền vững trong artifact hoặc `.sdd/reviews/`; trạng thái `PENDING HUMAN REVIEW`, `REVISE` và `REJECTED` đều chặn bước downstream.

```text
CONTEXT -> HUMAN REVIEW -> SPEC -> HUMAN REVIEW -> PLAN -> HUMAN REVIEW -> TASKS -> HUMAN REVIEW -> EXECUTE -> HUMAN REVIEW -> VERIFY -> HUMAN DISPOSITION -> SYNC -> HUMAN REVIEW -> COMMIT -> PR
```

| Pha | Command | Input | Output | Gate chuyển pha |
| :--- | :--- | :--- | :--- | :--- |
| 0. Context | `/sdd-context --feature=<slug>` | Problem statement | `CONTEXT.md` + recommendation | Human Director `APPROVED` |
| 1. Spec | `/sdd-spec --feature=<slug>` | `CONTEXT.md` | `SPEC.md` + recommendation | Human Director `APPROVED` (`APPROVED & LOCKED`) |
| 2. Plan | `/sdd-plan --feature=<slug>` | `SPEC.md` | `PLAN.md` + recommendation | Human Director `APPROVED` |
| 3. Tasks | `/sdd-tasks --feature=<slug>` | `PLAN.md`, `SPEC.md` | `TASKS.md` + recommendation | Human Director `APPROVED` |
| 4. Execute | `/add-execute --feature=<slug>` | `TASKS.md`, `SPEC.md` | Code + tests + recommendation | Human Director `APPROVED` |
| 5. Verify | `/sdd-lint`, `/sdd-audit`, `/sdd-trace` | Spec + code + tests | Quality report + recommendation | Human disposition; blockers resolved |
| 6. Sync | `/sdd-sync` | `.sdd/features/` | Registry + contracts + recommendation | Human Director `APPROVED` |
| 7. Commit | `/git-commit` | Intended changes | Git commit | `/git-validate --scope=commit` = `READY` + reviews valid |
| 8. PR | `/git-pr` | Pushed source branch | Pull Request | Remote validation `--strict` = `READY` + reviews valid |

### 4.1 Pha 0 — Context

```text
/sdd-context --feature=feat-user-register
```

Cung cấp problem, user pain, domain glossary, stakeholder và hard constraints. Không yêu cầu agent chọn framework hoặc thiết kế database ở pha này.

### 4.2 Pha 1 — Spec

```text
/sdd-spec --feature=feat-user-register
```

Review `SPEC.md` với Product Owner/Tech Lead. Chỉ coi Spec là implementation-ready khi:

- status là `APPROVED & LOCKED`;
- version có dạng `vX.Y.Z`;
- mỗi requirement có `REQ-XXX` duy nhất;
- happy path có unwanted/error behavior;
- acceptance behavior có thể chuyển thành test.

### 4.3 Pha 2 — Plan

```text
/sdd-plan --feature=feat-user-register
```

Plan phải chỉ rõ hướng dependency:

```text
domain <- usecase <- interface <- infra
```

Controller không gọi DB trực tiếp. Domain không import third-party library ngoài standard utilities theo `CLAUDE.md` và `CONSTITUTION.md`.

### 4.4 Pha 3 — Tasks

```text
/sdd-tasks --feature=feat-user-register
```

Mỗi task cần có ID, file boundary, requirement reference, dependency nếu có và command verify. Không đánh dấu `[x]` nếu test chưa pass.

### 4.5 Pha 4/5 — Execute và Verify

```text
/add-execute --feature=feat-user-register
```

Agent đọc `AGENTS.md`, `CONSTITUTION.md`, `TASKS.md`, `SPEC.md`, sau đó thực thi từng task. Sau code generation, chạy:

```text
/sdd-lint --feature=feat-user-register
/sdd-audit --feature=feat-user-register
/sdd-trace --feature=feat-user-register
```

Nếu yêu cầu vừa thay đổi, dùng `--diff` để tìm broken trace:

```text
/sdd-trace --feature=feat-user-register --diff
```

### 4.6 Đồng bộ registry và contracts

```text
/sdd-sync
```

Dùng sau khi feature hoặc shared contract thay đổi. Xác nhận `.sdd/README.md` và `.sdd/shared_context.md` phản ánh đúng feature hiện có; không thêm dữ liệu placeholder để làm đẹp registry.

---

## 5. Cập nhật Spec đúng cách

Khi behavior thay đổi, không patch code trước khi quyết định business đã được ghi vào Spec.

### 5.1 Bug hoặc điều kiện biên nhỏ

```text
/sdd-update --feature=feat-user-register --bump=patch --reason="Add OTP rate-limit behavior"
```

Thêm requirement/error case và changelog vào `SPEC.md`, sau đó:

```text
/add-execute --feature=feat-user-register
/sdd-lint --feature=feat-user-register
/sdd-trace --feature=feat-user-register --diff
```

### 5.2 Tính năng tương thích mới

Dùng `--bump=minor` khi thêm behavior không phá vỡ contract hiện tại:

```text
/sdd-update --feature=feat-user-register --bump=minor --reason="Reduce OTP expiration window"
```

Kiểm tra lại `PLAN.md`, `TASKS.md`, code và test trước khi commit.

### 5.3 Thay đổi phá vỡ contract

Dùng `--bump=major` khi thay đổi API/DB hoặc behavior không tương thích ngược:

```text
/sdd-update --feature=feat-user-register --bump=major --reason="Change registration contract"
```

Phải ghi risk và migration plan; breaking change cần Tech Lead/Human Director review trước implementation.

---

## 6. Các kịch bản vận hành

### Kịch bản 1 — Feature mới từ đầu

**Bối cảnh:** xây dựng đăng ký tài khoản bằng email/OTP.

```text
/sdd-context --feature=feat-user-register
/sdd-spec --feature=feat-user-register
# Human review, sau đó xác nhận APPROVED và chuyển Spec sang APPROVED & LOCKED
/sdd-plan --feature=feat-user-register
/sdd-tasks --feature=feat-user-register
/add-execute --feature=feat-user-register
/sdd-lint --feature=feat-user-register
/sdd-audit --feature=feat-user-register
/sdd-trace --feature=feat-user-register
/sdd-sync
```

Kết quả mong đợi: có đủ `CONTEXT.md`, `SPEC.md`, `PLAN.md`, `TASKS.md`, source, tests và traceability trước Git delivery.

### Kịch bản 2 — Bug phát hiện từ test hoặc production

**Bối cảnh:** OTP có thể bị gửi lại không giới hạn.

Không sửa trực tiếp `src/usecase/send-otp.ts` nếu Spec chưa mô tả rate limit. Thực hiện:

```text
/sdd-update --feature=feat-user-register --bump=patch --reason="Add OTP rate-limit behavior"
```

Bổ sung requirement, ví dụ:

```markdown
### REQ-011: Rate Limit Gửi OTP
IF người dùng gửi lại OTP quá 3 lần trong 60 giây,
THEN hệ thống SHALL từ chối với HTTP 429 và error_code `ERR_OTP_RATE_LIMIT`.
```

Sau đó:

```text
/add-execute --feature=feat-user-register
/sdd-trace --feature=feat-user-register --diff
/sdd-audit --feature=feat-user-register
```

### Kịch bản 3 — Product Owner thay đổi yêu cầu

**Bối cảnh:** thời hạn OTP đổi từ 5 phút xuống 2 phút.

```text
/sdd-update --feature=feat-user-register --bump=minor --reason="Reduce OTP expiration window"
```

Review changelog, update plan/tasks nếu affected, regenerate code/test và chạy trace diff. Không chỉ sửa hằng số trong code rồi bỏ qua Spec.

### Kịch bản 4 — Test fail hoặc Agent lặp lỗi

Agent phải dừng sau khi đã phân tích đủ nguyên nhân, không vá ngẫu nhiên.

1. Đọc failure và xác định code bug hay Spec gap.
2. Nếu Spec mơ hồ, báo Human Director.
3. Cập nhật `SPEC.md`, bump version nếu cần.
4. Đồng bộ `PLAN.md`, `TASKS.md`, code và tests.
5. Chạy lại validation từ pha bị ảnh hưởng.

### Kịch bản 5 — RFC thay đổi Constitution

**Bối cảnh:** team muốn thêm hoặc sửa hard rule.

```text
/sdd-rfc --title=soft-delete-policy
```

Tech Lead điền motivation, proposed change, risk và migration plan trong `.sdd/rfcs/RFC-XXX-*.md`. Chỉ sau approval mới chạy:

```text
/sdd-rfc --approve=<rfc-number>
```

Không sửa trực tiếp `CONSTITUTION.md`. Git Operator sẽ block thay đổi Constitution không có RFC approved.

### Kịch bản 6 — Brownfield adoption

**Bối cảnh:** repository Node.js/Python/Go đang chạy nhưng chưa có SDD.

```bash
# Từ thư mục template
./scripts/adopt.sh /path/to/legacy-repo
```

Hoặc Windows:

```powershell
.\scripts\adopt.ps1 -TargetPath C:\Projects\legacy-repo
```

Trong repo đích:

```text
/sdd-adopt
```

Nếu cần refactor module cũ:

```text
/sdd-adopt --reverse-feature=feat-legacy-module --path=src/modules/legacy
```

Sau reverse Spec, chạy `/sdd-lint` và review với owner trước khi dùng `/sdd-layer-edit` hoặc `/add-execute`.

### Kịch bản 7 — Thay đổi xuyên bốn tầng

**Bối cảnh:** thêm `discount_code` vào checkout.

```text
/sdd-layer-edit --feature=feat-order-checkout --action=modify
```

Kiểm tra kết quả theo boundary:

1. `src/domain/`: value object/entity.
2. `src/usecase/`: business workflow và `@ears` tag.
3. `src/interface/`: DTO/controller boundary.
4. `src/infra/`: repository/external integration.

Sau đó chạy audit architecture và test integration. Không để controller truy cập DB trực tiếp.

### Kịch bản 8 — Validation trước commit

Dùng khi thay đổi đã sẵn sàng nhưng chưa commit:

```text
/git-validate --scope=commit
/git-commit --message="feat(auth): add OTP rate limit"
```

`/git-commit` phải stage đúng file intended và chạy lại validator ngay trước `git commit`. Gate block secret, forbidden files, empty staged diff, unresolved Git operation, Constitution change không có RFC hoặc quality failure.

### Kịch bản 9 — Tạo PR remote-first

Source branch phải được push và remote diff phải là nguồn kết luận:

```text
/git-pr --base=main --head=feature/user-register --push
```

Chỉ dùng `--push` khi người dùng yêu cầu rõ. `/git-pr` phải:

1. fetch remote;
2. xác nhận `origin/main` và `origin/feature/user-register` tồn tại;
3. kiểm tra local HEAD khớp remote HEAD;
4. kiểm tra `origin/main...origin/feature/user-register`;
5. chạy `/git-validate --scope=pr --strict`;
6. chỉ sau `READY` mới gọi `gh pr create`.

Không dùng `git diff main...HEAD` để kết luận PR. Không merge, force-push hoặc bypass required checks.

### Kịch bản 10 — Documentation, skill hoặc governance-only change

Khi không có source behavior:

```text
/sdd-audit
/git-commit --message="feat(skill): improve validation gate"
/git-pr --base=main --head=feature/git-operator
```

Validator ghi `N/A` cho trace/test không áp dụng nếu repository không có source/test tương ứng, nhưng vẫn kiểm tra secret, path policy, Git state và docs consistency. Không báo `PASS` giả cho command chưa chạy.

### Kịch bản 11 — Handoff và resume

Khi còn task dở:

```text
/sdd-handoff --feature=feat-order-checkout
```

Handoff phải ghi current task, file đã đổi, test evidence, blocker và next command. Session mới:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Continue
```

Sau đó:

```text
/sdd-resume --feature=feat-order-checkout
```

Nếu repository chưa có feature active hoặc chưa có `TASKS.md`, không tạo feature giả. Ghi handoff ở report cấp repository trong `plans/reports/`.

---

## 7. Requirement Traceability và Impact Analysis

Traceability map:

```text
SPEC.md (REQ-XXX)
  -> PLAN.md
  -> TASKS.md
  -> src/ (@ears)
  -> tests/ (@ears)
```

### Truy vết một requirement

```text
/sdd-trace --feature=feat-user-register --req=REQ-001
```

### Kiểm tra toàn feature

```text
/sdd-trace --feature=feat-user-register
```

### Phân tích sau Spec change

```text
/sdd-trace --feature=feat-user-register --diff
```

Các trạng thái cần xử lý trước PR:

- **Untraced requirement**: Spec có REQ nhưng chưa có code/test.
- **Orphan code**: business method không có `@ears` hoặc trỏ tới REQ không tồn tại.
- **Outdated implementation**: code/test chưa theo version Spec mới.
- **Missing test**: requirement có code nhưng không có test verify.

---

## 8. EARS notation cheat sheet

| Loại | Mẫu | Ví dụ |
| :--- | :--- | :--- |
| Ubiquitous | `The <system> SHALL <action>` | `The system SHALL encrypt stored passwords.` |
| Event-driven | `WHEN <trigger>, the <system> SHALL <action>` | `WHEN user submits order, the system SHALL create a pending transaction.` |
| State-driven | `WHILE <state>, the <system> SHALL <action>` | `WHILE gateway is unavailable, the system SHALL show a maintenance notice.` |
| Optional | `WHERE <feature>, the <system> SHALL <action>` | `WHERE biometric login is enabled, the system SHALL request biometric verification.` |
| Unwanted | `IF <invalid condition>, THEN the <system> SHALL <action>` | `IF OTP attempts exceed the limit, THEN the system SHALL return 429.` |

Requirement cần tránh từ mơ hồ như “nhanh chóng”, “linh hoạt”, “đẹp”, “nếu cần thiết”. Thay bằng ngưỡng, trạng thái, input và output có thể test.

---

## 9. Quality gates trước khi báo hoàn thành

### 9.1 Self-check

- [ ] `SPEC.md` ở trạng thái `APPROVED & LOCKED` và có SemVer.
- [ ] Business methods có `@ears` reference hợp lệ.
- [ ] Controller không truy cập DB trực tiếp.
- [ ] Hardcoded secret và PII trong log đã bị loại bỏ/mask.
- [ ] Error response tuân thủ contract trong `CONSTITUTION.md`.
- [ ] Test happy path và error/edge cases đều pass.
- [ ] `/sdd-lint`, `/sdd-audit`, `/sdd-trace` đã chạy khi applicable.
- [ ] `/sdd-sync` đã chạy khi feature/contract/registry thay đổi.
- [ ] `/git-validate` trả `READY` trước commit hoặc PR.

### 9.2 Git Operator rules

| Scope | Nguồn diff | Required gate |
| :--- | :--- | :--- |
| Commit | `git diff --cached` | `/git-validate --scope=commit` |
| PR | `origin/<base>...origin/<head>` | `/git-validate --scope=pr --strict` |

Kết quả hợp lệ của validator là `PASS`, `FAIL` hoặc `N/A` có lý do. `READY` không được phát hành nếu còn `FAIL`, diff rỗng hoặc PR còn warning chưa giải trình.

---

## 10. Handoff và resume protocol

### 10.1 Kết thúc phiên

Với feature active:

```text
/sdd-handoff --feature=<slug>
```

Kiểm tra `TASKS.md`:

- `[x]`: task hoàn thành và test pass;
- `[/]`: task đang làm dở;
- `[ ]`: task chưa bắt đầu.

Với repository-level work không có feature, tạo report trong `plans/reports/` chứa current status, changed files, evidence, blockers và resume commands. Không tạo `CONTEXT.md`, `SPEC.md` hoặc `TASKS.md` placeholder.

### 10.2 Khởi động lại

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Continue
```

```bash
./scripts/start-claude.sh -c
```

Sau đó chạy `/sdd-resume --feature=<slug>` khi feature có `TASKS.md`. Đọc lại `CONTEXT.md`, `SPEC.md`, `PLAN.md` và `TASKS.md` trước khi tiếp tục execute.

### 10.3 Điều kiện kết thúc

Session chỉ được báo hoàn thành khi:

1. mọi task intended đã có trạng thái rõ;
2. evidence test/quality được ghi;
3. blocker và open question không bị che giấu;
4. thay đổi đã qua Git validation nếu chuẩn bị commit/PR;
5. next step có command cụ thể.
