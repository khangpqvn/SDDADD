# Starter Template SDD + ADD

Template khởi tạo dự án theo **Spec-Driven Development (SDD)** và **Agent-Driven Development (ADD)**. Quy trình đảm bảo: requirement rõ ràng → Human duyệt → Agent thực thi có evidence.

## Bắt đầu ngay

Nếu bạn là người mới hoặc muốn triển khai feature đầu tiên, đi theo lộ trình:
**[Bắt đầu nhanh: làm feature đầu tiên](./docs/sdd-add-quickstart.md)**

## Catalog 26 skills

Mỗi command có contract chuẩn trong [`.claude/skills/`](./.claude/skills/); bảng dưới đây chỉ là bản đồ chọn route, không thay thế contract. Input bắt buộc được giữ ngắn; đọc contract trước khi chạy.

### Bootstrap và lifecycle

| Skill | Input chính | Route liên quan |
| :--- | :--- | :--- |
| [`/sdd-init`](./.claude/skills/sdd-init/SKILL.md) | `--project-name`, tùy chọn `--stack`, ownership/execution | [Quickstart](./docs/sdd-add-quickstart.md) |
| [`/sdd-adopt`](./.claude/skills/sdd-adopt/SKILL.md) | tùy chọn `--stack`, `--reverse-feature`, `--path` | [Quickstart](./docs/sdd-add-quickstart.md) |
| [`/sdd-context`](./.claude/skills/sdd-context/SKILL.md) | `--feature` | [Quickstart](./docs/sdd-add-quickstart.md#bước-1--chốt-ngữ-cảnh-context) |
| [`/sdd-spec`](./.claude/skills/sdd-spec/SKILL.md) | `--feature` | [Quickstart](./docs/sdd-add-quickstart.md#bước-2--viết-behavior-spec) |
| [`/sdd-lint`](./.claude/skills/sdd-lint/SKILL.md) | `--feature` | [Quickstart](./docs/sdd-add-quickstart.md#bước-2--viết-behavior-spec) |
| [`/sdd-plan`](./.claude/skills/sdd-plan/SKILL.md) | `--feature` | [Quickstart](./docs/sdd-add-quickstart.md#bước-4--lập-thiết-kế-plan) |
| [`/sdd-tasks`](./.claude/skills/sdd-tasks/SKILL.md) | `--feature` | [Quickstart](./docs/sdd-add-quickstart.md#bước-5--chia-task-tasks) |
| [`/sdd-review`](./.claude/skills/sdd-review/SKILL.md) | target hoặc `--feature` + `--artifact`, status, decision, reviewer, follow-up | [Hướng dẫn vận hành](./docs/sdd-add-guide.md) |
| [`/sdd-update`](./.claude/skills/sdd-update/SKILL.md) | `--feature`, `--artifact`, `--reason`; Spec thêm `--bump` | [Quickstart](./docs/sdd-add-quickstart.md#route-phụ-có-điều-kiện) |
| [`/sdd-trace`](./.claude/skills/sdd-trace/SKILL.md) | `--feature`, tùy chọn `--req`, `--diff` | [Tra cứu nhanh](./docs/sdd-add-field-guide.md) |
| [`/sdd-sync`](./.claude/skills/sdd-sync/SKILL.md) | tùy chọn `--feature`, `--reason` | [Tra cứu nhanh](./docs/sdd-add-field-guide.md) |
| [`/sdd-template-update`](./.claude/skills/sdd-template-update/SKILL.md) | `--check` hoặc `--review`, tùy chọn `--template` | [Sổ đăng ký](./.sdd/template-version.md) |

### Execution và recovery

| Skill | Input chính | Route liên quan |
| :--- | :--- | :--- |
| [`/add-execute`](./.claude/skills/add-execute/SKILL.md) | `--feature` và một `--task` hoặc `--all`; tùy chọn `--retry`/`--resume` | [Hướng dẫn execution](./docs/multi-agent-orchestration-guide.md) |
| [`/sdd-layer-edit`](./.claude/skills/sdd-layer-edit/SKILL.md) | `--feature`, `--action`, `--target` | [Hướng dẫn vận hành](./docs/sdd-add-guide.md) |
| [`/sdd-handoff`](./.claude/skills/sdd-handoff/SKILL.md) | tùy chọn `--feature` | [Sổ tay tình huống](./docs/sdd-add-scenario-playbook.md) |
| [`/sdd-resume`](./.claude/skills/sdd-resume/SKILL.md) | tùy chọn `--feature` | [Sổ tay tình huống](./docs/sdd-add-scenario-playbook.md) |

### Governance

| Skill | Input chính | Route liên quan |
| :--- | :--- | :--- |
| [`/sdd-agents-edit`](./.claude/skills/sdd-agents-edit/SKILL.md) | tùy chọn `--section`, bắt buộc `--reason` | [`AGENTS.md`](./AGENTS.md) |
| [`/sdd-claude-edit`](./.claude/skills/sdd-claude-edit/SKILL.md) | tùy chọn `--section`, `--reason` | [`CLAUDE.md`](./CLAUDE.md) |
| [`/sdd-rfc`](./.claude/skills/sdd-rfc/SKILL.md) | `--title` hoặc `--approve` | [`CONSTITUTION.md`](./CONSTITUTION.md) |

### Validation và delivery

| Skill | Input chính | Route liên quan |
| :--- | :--- | :--- |
| [`/sdd-audit`](./.claude/skills/sdd-audit/SKILL.md) | tùy chọn `--feature` | [Tra cứu nhanh](./docs/sdd-add-field-guide.md) |
| [`/git-validate`](./.claude/skills/git-validate/SKILL.md) | `--scope`; tùy chọn `--feature`, `--strict` | [Quickstart](./docs/sdd-add-quickstart.md#bước-7--validation-và-delivery) |
| [`/git-commit`](./.claude/skills/git-commit/SKILL.md) | tùy chọn message/type/scope/files | [Quickstart](./docs/sdd-add-quickstart.md#bước-7--validation-và-delivery) |
| [`/git-pr`](./.claude/skills/git-pr/SKILL.md) | tùy chọn `--base`, `--head`, `--feature`, `--draft` | [Sổ tay tình huống](./docs/sdd-add-scenario-playbook.md#8-delivery) |

### Technical audit

| Skill | Input chính | Route liên quan |
| :--- | :--- | :--- |
| [`/api-security-auditor`](./.claude/skills/api-security-auditor/SKILL.md) | `--file` hoặc `--feature`; tùy chọn `--owasp` | [Hướng dẫn vận hành](./docs/sdd-add-guide.md) |
| [`/error-handler-pattern`](./.claude/skills/error-handler-pattern/SKILL.md) | `--file` hoặc `--feature`; `--mode=audit\|scaffold` | [Hướng dẫn vận hành](./docs/sdd-add-guide.md) |
| [`/sql-performance-tuner`](./.claude/skills/sql-performance-tuner/SKILL.md) | `--file` hoặc `--query`; `--mode=audit\|fix\|index` | [Hồ sơ kiến trúc](./docs/architecture-profile-guide.md) |

Mọi route execution vẫn chịu gate trong artifact và skill contract. Không dùng catalog để bypass Human review, Architecture Profile hoặc exact command.

## Hệ thống tài liệu

Chọn tài liệu theo nhu cầu hiện tại, không cần đọc hết:

| Bạn cần làm gì? | Đọc tài liệu này | Mục tiêu |
| :--- | :--- | :--- |
| Đi từng bước làm feature | [Bắt đầu nhanh](./docs/sdd-add-quickstart.md) | Hoàn thành một feature từ ý tưởng đến Git delivery. |
| Hiểu artifact, gate, ownership và cách viết Spec | [Hướng dẫn vận hành](./docs/sdd-add-guide.md) | Hiểu vì sao cần Spec/Plan, ai duyệt, EARS và độ sâu Spec. |
| Tra cứu nhanh theo tình huống | [Tra cứu nhanh](./docs/sdd-add-field-guide.md) | Tìm đúng command và bảng quyết định cho tình huống cụ thể. |
| Xử lý lỗi, handoff, resume, ranh giới áp dụng | [Sổ tay tình huống](./docs/sdd-add-scenario-playbook.md) | Recovery khi bị block và biết khi nào không nên dùng full SDD. |
| Thiết lập tech stack, command và chọn công cụ | [Hồ sơ kiến trúc](./docs/architecture-profile-guide.md) | Định nghĩa binding, lệnh verify và tiêu chí chọn tool. |
| Điều phối nhiều Agent | [Hướng dẫn execution](./docs/multi-agent-orchestration-guide.md) | Route `direct` và `orchestrated` của `/add-execute`. |

## Chọn SDD hay ADD cho từng việc

SDD và ADD không loại trừ nhau. SDD bảo đảm *biết đúng việc cần làm*; ADD bảo đảm *thực thi hiệu quả*. Dùng SDD sâu cho phần đắt khi sai, dùng ADD cho phần lặp lại và dễ kiểm chứng.

| Loại việc | Độ sâu Spec | Ghi chú |
| :--- | :--- | :--- |
| Kiến trúc, public/shared contract, schema, bảo mật, thanh toán | Sâu nhất | Sai rất đắt; cần Spec đầy đủ và checkpoint. |
| Business logic cốt lõi của feature | Trung bình | Spec đủ 8 thành phần, EARS rõ ràng. |
| UI component, test, boilerplate, bug fix nhỏ | Nhẹ | Vẫn cần task boundary và exact command. |
| Prototype/throwaway, thăm dò chưa biết muốn gì | Không dùng full SDD | Xem [ranh giới áp dụng](./docs/sdd-add-scenario-playbook.md). |

Chi tiết cách chọn độ sâu theo rủi ro và độ phức tạp nằm trong [Hướng dẫn vận hành](./docs/sdd-add-guide.md).

## EARS trong một bảng

`SPEC.md` viết Functional Requirement bằng EARS để loại bỏ mơ hồ:

| Mẫu | Cú pháp | Dùng khi |
| :--- | :--- | :--- |
| Ubiquitous | `THE <system> SHALL <action>` | Luôn đúng, không điều kiện. |
| Event-driven | `WHEN <event>, THE <system> SHALL <action>` | Phản ứng tại một thời điểm. |
| State-driven | `WHILE <state>, THE <system> SHALL <action>` | Hành vi liên tục trong một trạng thái. |
| Optional | `WHERE <feature> IS ENABLED, THE <system> SHALL <action>` | Tính năng bật/tắt theo cấu hình. |
| Unwanted | `WHERE <error/condition>, THE <system> SHALL <response>` | Lỗi và edge case. |

`SHALL` là bắt buộc, `SHOULD` là khuyến nghị, `MAY` là tùy chọn. Giải thích đầy đủ và anti-pattern nằm trong [Hướng dẫn vận hành](./docs/sdd-add-guide.md).

## Nguồn chuẩn

Khi có mâu thuẫn, tin vào các tệp này thay vì prose trong docs:

- `.sdd/architecture-profile.md`: technology binding và exact verification command.
- `.claude/skills/`: contract của từng slash command.
- `.claude/skills/_shared/ai-review-protocol.md`: review, checkpoint, Action/Execution Record.
- `CONSTITUTION.md` và `AGENTS.md`: hard rule và quyền hạn Agent.
- `.sdd/shared_context.md`: `Project Ownership` và `Agent Execution`.
- `.sdd/constraints/`: global, business và safety constraints.

## Ba nguyên tắc sống còn

1. **Fix the Spec, not the Code.** Requirement thiếu hoặc sai thì update Spec, review lại, rồi mới đổi behavior.
2. **Không suy đoán kỹ thuật.** Chỉ dùng binding và command đã `APPROVED` trong Architecture Profile.
3. **Human quyết định.** Agent đề xuất và thực thi trong scope đã duyệt; chỉ Human ghi `APPROVED` và `git push`.

Các nguyên tắc này là quy ước governance, không phải enforcement: chúng không ràng buộc được một writer cố ý bỏ qua. Chỉ host-enforcement quan sát được mới được coi là đang áp dụng; nếu chưa có runtime evidence thì ghi `UNVERIFIED`.

## Giới hạn cần biết trước khi tin Agent

Agent mạnh trong phạm vi context được cung cấp, nhưng có điểm mù thật: context đầy thì bỏ quên chỉ dẫn, có thể lặp vòng sửa lỗi không hội tụ, và có thể bịa API của library ít phổ biến. Vì vậy template yêu cầu Shadow Plan, exact approved command, Action Record và Human checkpoint. Cách nhận biết và xử lý nằm trong [Hướng dẫn vận hành](./docs/sdd-add-guide.md).

## Tiện ích template

- `scripts/start-claude.sh` và `scripts/start-claude.ps1`: khởi chạy với permission mode mặc định. Bypass permission chỉ có khi truyền cờ explicit, bị khuyến cáo không dùng và không thuộc route chính của template.
- `scripts/self-heal.sh`: chạy một exact approved command để thu thập evidence; không sửa source, không retry.
- `scripts/template-smoke.sh` và `scripts/template-smoke.ps1`: static check file, token và link.
- `scripts/adopt.sh` và `scripts/adopt.ps1`: đưa template vào repository có sẵn.
- `scripts/update.sh` và `scripts/update.ps1`: nhận template-owned update; governance files được stage để Human review.
