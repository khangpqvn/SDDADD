# SDD + ADD Starter Template

Template chuẩn để xây dựng dự án phần mềm theo **SDD** (Spec-Driven Development) và **ADD** (Agent-Driven Development) với AI Coding Assistants như Claude Code, Roo Code, Cline và Cursor. Template gồm quality gate, SemVer cho đặc tả, Spec hierarchy, Architecture Profile, AI Recommendation + Human Final Review và script hỗ trợ tích hợp repository có sẵn.

---

## Tài liệu hướng dẫn

- [`docs/sdd-add-guide.md`](docs/sdd-add-guide.md) — Cẩm nang vòng đời feature, review gate và các kịch bản vận hành.
- [`docs/architecture-profile-guide.md`](docs/architecture-profile-guide.md) — Chọn, xác minh và review tech stack trước khi sinh Plan, Tasks hoặc adapter code.
- [`docs/multi-agent-orchestration-guide.md`](docs/multi-agent-orchestration-guide.md) — Phân quyền, ownership, MCP và quy trình phối hợp Multi-Agent.

---

## Bắt đầu

### Dự án mới (Greenfield)

```bash
# 1. Clone template
git clone <repo-url-cua-ban> my-new-project
cd my-new-project

# 2. Khởi tạo SDD + ADD
/sdd-init --project-name="my-new-project" --stack="Node.js + TypeScript"

# 3. Tạo Context và Spec không phụ thuộc công nghệ
/sdd-context --feature=feat-001-user-auth
/sdd-spec --feature=feat-001-user-auth

# 4. Chọn HTTP, DB, ORM/query layer, validation và exact test/build/lint commands trong
#    .sdd/architecture-profile.md, sau đó Human Director ghi APPROVED qua /sdd-review.

# 5. Chỉ tiếp tục khi profile và artifact tiền đề đã APPROVED
/sdd-plan --feature=feat-001-user-auth
/sdd-tasks --feature=feat-001-user-auth
/add-execute --feature=feat-001-user-auth
```

Baseline của template chỉ xác nhận TypeScript, Node.js và Clean Architecture. Agent không được tự suy đoán HTTP framework, database, ORM/query layer, validation library hoặc verification command.

### Repository có sẵn (Brownfield)

```bash
# Linux, macOS hoặc Git Bash
./scripts/adopt.sh /path/to/existing-repository
```

```powershell
# Windows PowerShell
.\scripts\adopt.ps1 -TargetPath C:\Projects\existing-repository
```

Script sao chép skills, governance, Architecture Profile, constraints, tài liệu và `self-heal.sh`. Script không ghi đè tệp đích trừ khi dùng `--force` hoặc `-Force`.

Sau đó mở repository đích và chạy:

```text
/sdd-adopt
```

`/sdd-adopt` khảo sát evidence hiện có, đề xuất Architecture Profile và chờ Human Final Review trước technical planning hoặc execution.

---

## Cấu trúc repository

```text
.
├── AGENTS.md                    # Quyền hạn, phạm vi và quy tắc vận hành Agent
├── CLAUDE.md                    # Bộ nhớ kiến trúc dành cho con người
├── CONSTITUTION.md              # Hard rule, architecture rule và RFC process
├── .agentignore                 # Context hygiene cho AI Agent
├── .claude/skills/              # 25 slash commands SDD/ADD, Git và technical skills
├── .sdd/
│   ├── architecture-profile.md  # Nguồn sự thật cho binding công nghệ
│   ├── constraints/             # Global, business và safety constraints
│   ├── mcp-config.yaml          # Quyền MCP theo vai trò Agent
│   ├── shared_context.md        # API contract và trạng thái dùng chung
│   ├── features/                # CONTEXT.md, SPEC.md, PLAN.md, TASKS.md
│   ├── reviews/                 # Report và Human Final Review ngoài feature
│   └── rfcs/                    # RFC thay đổi Constitution hoặc kiến trúc lớn
├── docs/                        # Hướng dẫn vận hành
├── scripts/
│   ├── adopt.sh / adopt.ps1     # Tích hợp template vào repository có sẵn
│   ├── self-heal.sh             # Test → sửa tối đa ba lần → Human review
│   └── start-claude.*           # Khởi động Claude Code với --dangerously-skip-permissions
├── src/                         # Mã nguồn theo Clean Architecture
└── tests/                       # Test suite
```

---

## Slash commands

| Command | Mục đích |
| :--- | :--- |
| `/sdd-init`, `/sdd-adopt` | Khởi tạo Greenfield hoặc tích hợp Brownfield. |
| `/sdd-context`, `/sdd-spec`, `/sdd-plan`, `/sdd-tasks` | Tạo bốn artifact SDD theo thứ tự. |
| `/sdd-review` | Ghi Human Final Review bền vững. |
| `/add-execute`, `/sdd-layer-edit` | Thực thi theo profile, Plan và Tasks đã duyệt. |
| `/sdd-update`, `/sdd-lint`, `/sdd-audit`, `/sdd-trace`, `/sdd-sync` | Cập nhật, kiểm định, truy vết và đồng bộ đặc tả. |
| `/sdd-handoff`, `/sdd-resume` | Lưu và khôi phục trạng thái phiên làm việc. |
| `/sdd-rfc`, `/sdd-claude-edit`, `/sdd-agents-edit` | Quản lý governance. |
| `/git-validate`, `/git-commit`, `/git-pr` | Kiểm tra và thực hiện Git delivery. |
| `/api-security-auditor`, `/sql-performance-tuner`, `/error-handler-pattern` | Technical skill theo Architecture Profile. |

Mỗi recommendation bắt đầu tại `PENDING HUMAN REVIEW`. Agent chỉ đề xuất; Human Director hoặc reviewer được ủy quyền ghi `APPROVED`, `REVISE` hoặc `REJECTED` bằng `/sdd-review`.

---

## Quy tắc cốt lõi

1. **Fix the Spec, not the Code**: Khi requirement thiếu hoặc mơ hồ, cập nhật `SPEC.md` trước khi sửa behavior.
2. **EARS traceability**: Business method phải có `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
3. **Profile trước technical planning**: Chỉ dùng binding và exact command đã approved/evidenced.
4. **Shadow Plan trước execution**: Human Director xác nhận phạm vi trước mỗi task.
5. **Git delivery có gate**: `/git-validate` phải trả `READY` trước commit hoặc Pull Request.
6. **Không có secret**: Không ghi, log hoặc commit credential, token, password hay connection string.

Xem [`docs/sdd-add-guide.md`](docs/sdd-add-guide.md) để có kịch bản chi tiết.
