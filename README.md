# SDD + ADD Starter Template

Template chuẩn hóa cho việc xây dựng dự án phần mềm theo phương pháp luận **SDD (Spec-Driven Development)** và **ADD (Agent-Driven Development)** với AI Coding Assistants (Claude Code, Roo Code, Cline, Cursor). Tích hợp sẵn hệ thống **Checkpoints DoD**, **Semantic Versioning Docs**, **Spec Hierarchy**, **AI Recommendation + Human Final Review** và **Native Shell Scripts cho Repo có sẵn**.

---

## 📖 TÀI LIỆU HƯỚNG DẪN CHI TIẾT (DOCUMENTATION)

Đọc tài liệu đầy đủ tại **[`docs/sdd-add-guide.md`](docs/sdd-add-guide.md)** — Cẩm nang vận hành chi tiết bao gồm:

- 💡 **[Khái niệm SDD + ADD](docs/sdd-add-guide.md#1-sdd--add-l%C3%A0-g%C3%AC)**: Hiểu vai trò của Spec, Human Director và Agent cùng nguyên tắc *"Fix the Spec, not the Code"*.
- 🔄 **[Vòng đời feature chuẩn](docs/sdd-add-guide.md#5-v%C3%B2ng-%C4%91%E1%BB%9Di-feature-chu%E1%BA%A9n)**: Chi tiết đầu vào, đầu ra và gate hoàn thành từ Context đến PR.
- ✏️ **[Cập nhật Spec đúng cách](docs/sdd-add-guide.md#7-c%E1%BA%ADp-nh%E1%BA%ADt-spec-%C4%91%C3%BAng-c%C3%A1ch)**: Cách xử lý bug, thay đổi tương thích và breaking change bằng SemVer.
- 🎬 **[Các kịch bản vận hành](docs/sdd-add-guide.md#8-c%C3%A1c-k%E1%BB%8Bch-b%E1%BA%A3n-v%E1%BA%ADn-h%C3%A0nh-th%C6%B0%E1%BB%9Dng-g%E1%BA%B7p)**: Hướng dẫn Greenfield, Brownfield, feature, bugfix, RFC, Git delivery và handoff/resume.
- 🔍 **[Requirement Traceability và Impact Analysis](docs/sdd-add-guide.md#9-requirement-traceability-v%C3%A0-impact-analysis)**: Cách dùng `/sdd-trace` để phát hiện requirement chưa được triển khai, code mồ côi và implementation lỗi thời.
- 👥 **[Review Human và cách approve/revise/reject](docs/sdd-add-guide.md#4-ai-recommendation-v%C3%A0-human-final-review-thao-t%C3%A1c-c%E1%BA%A7m-tay-ch%E1%BB%89-vi%E1%BB%87c)**: Đọc bằng chứng, lật cờ bền vững, xử lý trạng thái và điều kiện chuyển pha.
- 🤝 **[Handoff và resume protocol](docs/sdd-add-guide.md#87-handoff-v%C3%A0-resume)**: Lưu trạng thái dở dang và khôi phục phiên làm việc tiếp theo.
- 📐 **[EARS notation cheat sheet](docs/sdd-add-guide.md#10-ears-notation-cheat-sheet)**: Năm mẫu EARS để viết đặc tả có thể kiểm thử.

---

## 🚀 HƯỚNG DẪN BẮT ĐẦU

### Trường hợp 1: Khởi tạo Dự án MỚI từ Template (Greenfield)
```bash
# Bước 1: Clone Repository
git clone <repo-url-cua-ban> my-new-project
cd my-new-project

# Bước 2: Khởi tạo dữ liệu framework SDD+ADD
/sdd-init --project-name="my-new-project" --stack="Node.js + TypeScript"

# Bước 3: Triển khai Feature đầu tiên theo lifecycle SDD+ADD
/sdd-context --feature=feat-001-user-auth
/sdd-spec    --feature=feat-001-user-auth
/sdd-plan    --feature=feat-001-user-auth
/sdd-tasks   --feature=feat-001-user-auth
/add-execute --feature=feat-001-user-auth
```

---

### Trường hợp 2: Tích hợp SDD+ADD vào Repository CÓ SẴN (Brownfield / Legacy Codebase)
Nếu bạn đã có một dự án đang chạy ở bất kỳ đường dẫn nào trên máy tính và muốn tích hợp SDD+ADD mà **không cần cài thêm Node.js/Python hay công cụ ngoài**:

#### Cách 1: Tự động Migrate từ Template bằng Native Shell Scripts (Zero Dependencies)
Truyền đường dẫn repo target hiện tại của bạn vào script native phù hợp HĐH:

- **Linux / macOS / Git Bash (Windows)**:
  ```bash
  ./scripts/adopt.sh /path/to/your-existing-project
  ```
- **Windows (PowerShell)**:
  ```powershell
  .\scripts\adopt.ps1 -TargetPath C:\Projects\your-existing-project
  ```
- **Relative Path (Đường dẫn tương đối)**:
  ```bash
  ./scripts/adopt.sh ../your-existing-project
  ```

*Script native sẽ tự động copy bộ skills, governance files (`CONSTITUTION.md`, `AGENTS.md`, `CLAUDE.md`) và hạ tầng `.sdd/` vào project mục tiêu mà không đụng chạm hay ghi đè bất kỳ nguồn mã hiện tại nào.*

#### Cách 2: Kích hoạt & Đảo ngược Spec trong Project Mục tiêu
Sau khi đã chạy script migrate:
```bash
# 1. Mở repo mục tiêu của bạn trong Claude Code / AI IDE
cd /path/to/your-existing-project

# 2. Chạy lệnh tự động scout và tinh chỉnh Layer 1 Governance phù hợp với Tech Stack của repo cũ:
/sdd-adopt

# 3. (Tùy chọn) Đảo ngược đặc tả (Reverse Spec) cho một module cũ để refactor:
/sdd-adopt --reverse-feature=feat-legacy-auth --path=src/modules/auth
```

---

## 📂 THƯ MỤC CẤU TRÚC DỰ ÁN (DIRECTORY ANATOMY)

```text
.
├── AGENTS.md               # [Layer 1] Định danh Agent, Persona, Permitted Scope & Tool Permissions
├── CLAUDE.md               # [Layer 1] Project Memory, Architecture DNA & Clean Arch Rules
├── CONSTITUTION.md         # [Layer 1] Hard Quality Gates (3 Layer Rules: Hard, Arch, Eng) & RFC Process
├── .claude/
│   └── skills/             # 22 Custom Slash Commands cho SDD+ADD Workflow và Git Operator Gates
│       ├── sdd-init/SKILL.md         # /sdd-init (Greenfield Project Initializer)
│       ├── sdd-adopt/SKILL.md        # /sdd-adopt (Brownfield Legacy Adoption & Reverse Spec)
│       ├── sdd-context/SKILL.md      # /sdd-context --feature=<slug> (Pha 0: Context Discovery + DoD)
│       ├── sdd-review/SKILL.md       # /sdd-review (Ghi nhận Human Final Review và chuyển trạng thái)
│       ├── sdd-spec/SKILL.md         # /sdd-spec --feature=<slug> (Pha 1: Executable Spec EARS+BDD+SemVer + DoD)
│       ├── sdd-plan/SKILL.md         # /sdd-plan --feature=<slug> (Pha 2: Architecture & Risk Plan + DoD)
│       ├── sdd-tasks/SKILL.md        # /sdd-tasks --feature=<slug> (Pha 3: Atomic Task Breakdown + DoD)
│       ├── add-execute/SKILL.md      # /add-execute --feature=<slug> (Pha 4 & 5: Execution, Self-Check & DoD)
│       ├── sdd-update/SKILL.md       # /sdd-update --feature=<slug> (Nâng version SemVer, cập nhật EARS & ghi Changelog)
│       ├── sdd-trace/SKILL.md        # /sdd-trace --feature=<slug> (Requirement Traceability & Impact Analysis)
│       ├── sdd-handoff/SKILL.md      # /sdd-handoff (Lưu trạng thái dở dang & đóng bằng session)
│       ├── sdd-resume/SKILL.md       # /sdd-resume (Khôi phục ngữ cảnh phiên làm việc mới)
│       ├── sdd-audit/SKILL.md        # /sdd-audit (Kiểm tra tuân thủ 3 tầng Quality Gates trong CONSTITUTION.md)
│       ├── sdd-lint/SKILL.md         # /sdd-lint --feature=<slug> (Linter kiểm định chuẩn EARS & Unwanted Behavior)
│       ├── sdd-rfc/SKILL.md          # /sdd-rfc (Quản lý đề xuất RFC sửa đổi CONSTITUTION.md)
│       ├── sdd-sync/SKILL.md         # /sdd-sync (Đồng bộ Master Registry & Shared Contracts)
│       ├── sdd-layer-edit/SKILL.md   # /sdd-layer-edit (Chỉnh sửa đồng bộ mã nguồn qua 4 tầng Clean Arch)
│       ├── sdd-claude-edit/SKILL.md # /sdd-claude-edit (Quản lý & cập nhật CLAUDE.md - Project Memory & Arch DNA)
│       ├── sdd-agents-edit/SKILL.md # /sdd-agents-edit (Quản lý & cập nhật AGENTS.md - Persona, Scope & Permissions)
│       ├── git-validate/SKILL.md    # /git-validate (Validation gate trước commit/PR)
│       ├── git-commit/SKILL.md      # /git-commit (Commit sau khi validation đạt READY)
│       └── git-pr/SKILL.md          # /git-pr (Remote-first Pull Request sau khi validation đạt READY)
├── .sdd/                   # Thư mục quản lý Đặc tả Kỹ thuật (Source of Truth)
│   ├── README.md           # Master Feature Registry (Đăng ký danh sách features)
│   ├── shared_context.md   # Shared State & Active API Contracts giữa các features
│   ├── rfcs/               # Thư mục chứa các đề xuất RFC sửa đổi Hiến pháp
│   └── features/           # Nơi chứa bộ 4 file SDD cho từng feature riêng biệt
├── docs/
│   └── sdd-add-guide.md    # Handbook vòng đời SDD+ADD, DoD Checklist & Kịch bản vận hành
├── scripts/
│   ├── adopt.sh            # Native Bash Script cho Linux / macOS / Git Bash
│   ├── adopt.ps1           # Native PowerShell Script cho Windows
│   ├── start-claude.sh     # Script khởi động Claude Code ở chế độ bypass permission (Bash)
│   └── start-claude.ps1    # Script khởi động Claude Code ở chế độ bypass permission (PowerShell)
└── src/                    # Source code thực thi (Được sinh từ SPEC.md)
```

---

## 🛠️ DANH SÁCH SLASH COMMANDS (CUSTOM SKILLS)

Human review state phải được ghi bằng `/sdd-review` sau khi đọc recommendation và evidence. Command này không thay thế `/sdd-rfc --approve=<rfc-number>` cho thay đổi Constitution.

| Slash Command | File Skill | Công dụng |
| :--- | :--- | :--- |
| `/sdd-init` | `.claude/skills/sdd-init/SKILL.md` | Khởi tạo khung SDD+ADD cho dự án mới (Greenfield) |
| `/sdd-adopt` | `.claude/skills/sdd-adopt/SKILL.md` | Tích hợp SDD+ADD vào repo có sẵn (Brownfield) & Đảo ngược Spec từ code cũ |
| `/sdd-context` | `.claude/skills/sdd-context/SKILL.md` | **Pha 0**: Context Discovery ➔ `.sdd/features/{slug}/CONTEXT.md` |
| `/sdd-review` | `.claude/skills/sdd-review/SKILL.md` | Human ghi nhận `APPROVED`, `REVISE` hoặc `REJECTED` với đủ bằng chứng và thông tin reviewer |
| `/sdd-spec` | `.claude/skills/sdd-spec/SKILL.md` | **Pha 1**: Executable Spec (SemVer) ➔ `.sdd/features/{slug}/SPEC.md` |
| `/sdd-plan` | `.claude/skills/sdd-plan/SKILL.md` | **Pha 2**: Lập kế hoạch Clean Arch ➔ `.sdd/features/{slug}/PLAN.md` |
| `/sdd-tasks` | `.claude/skills/sdd-tasks/SKILL.md` | **Pha 3**: Atomic Tasks Breakdown ➔ `.sdd/features/{slug}/TASKS.md` |
| `/add-execute` | `.claude/skills/add-execute/SKILL.md` | **Pha 4 & 5**: AI Agent thực thi code, Self-check `CONSTITUTION.md` & Test |
| `/sdd-update` | `.claude/skills/sdd-update/SKILL.md` | Cập nhật đặc tả, nâng version SemVer (Major/Minor/Patch) & ghi Changelog |
| `/sdd-trace` | `.claude/skills/sdd-trace/SKILL.md` | Truy vết ma trận yêu cầu (RTM 5 tầng) & Phân tích tác động khi đổi Spec |
| `/sdd-handoff` | `.claude/skills/sdd-handoff/SKILL.md` | Lưu trạng thái feature và tạo handoff cho session tiếp theo |
| `/sdd-resume` | `.claude/skills/sdd-resume/SKILL.md` | Quét task dở dang và khôi phục context |
| `/sdd-audit` | `.claude/skills/sdd-audit/SKILL.md` | Kiểm tra tuân thủ 3 tầng quality gates |
| `/sdd-lint` | `.claude/skills/sdd-lint/SKILL.md` | Kiểm định EARS, SemVer và unwanted behavior |
| `/sdd-rfc` | `.claude/skills/sdd-rfc/SKILL.md` | Quản lý RFC thay đổi Constitution hoặc kiến trúc lớn |
| `/sdd-sync` | `.claude/skills/sdd-sync/SKILL.md` | Đồng bộ feature registry và shared contracts |
| `/sdd-layer-edit` | `.claude/skills/sdd-layer-edit/SKILL.md` | Chỉnh sửa xuyên bốn tầng Clean Architecture |
| `/sdd-claude-edit` | `.claude/skills/sdd-claude-edit/SKILL.md` | Cập nhật CLAUDE.md theo governance workflow |
| `/sdd-agents-edit` | `.claude/skills/sdd-agents-edit/SKILL.md` | Cập nhật AGENTS.md theo governance workflow |
| `/git-validate` | `.claude/skills/git-validate/SKILL.md` | Gate bắt buộc kiểm tra Git, secrets, Constitution, SDD trace và quality trước commit/PR |
| `/git-commit` | `.claude/skills/git-commit/SKILL.md` | Stage và tạo commit chỉ sau khi `/git-validate --scope=commit` đạt READY |
| `/git-pr` | `.claude/skills/git-pr/SKILL.md` | Kiểm tra remote-first và tạo Pull Request chỉ sau khi gate PR đạt READY |

---

### Git Operator Workflow

Mọi commit và Pull Request phải đi qua gate dùng chung:

```text
/git-commit --message="feat(scope): description"
# git-commit stages intended files, then invokes git-validate --scope=commit

/git-pr --base=main --head=feature/my-change
# git-pr invokes git-validate --scope=pr --strict before gh pr create
```

`/git-validate` dùng staged diff cho commit và `origin/<base>...origin/<head>` cho PR. Gate sẽ block secret, file nhạy cảm, Constitution thay đổi không có RFC approved, SDD lint/audit/trace failure, test failure, dirty worktree hoặc remote head chưa được push. Bước không áp dụng phải ghi rõ `N/A` kèm lý do; không được báo giả là `PASS`.

### AI Recommendation và Human Final Review

Mỗi skill SDD/ADD phải tạo recommendation có evidence, risks, assumptions, alternatives và next action theo [canonical protocol](.claude/skills/_shared/ai-review-protocol.md). Recommendation luôn bắt đầu ở `PENDING HUMAN REVIEW` và được lưu trong feature artifact hoặc `.sdd/reviews/` cho report không thuộc feature.

Agent chỉ được đề xuất. Human Director/Tech Lead ghi nhận review bằng `/sdd-review` với `APPROVED`, `REVISE` hoặc `REJECTED`, cùng decision, reviewer, timestamp và follow-up. Artifact pending/revised/rejected không được chuyển pha, lock, execute, complete, commit hoặc PR. Thay đổi sau approval phải invalidate review và tạo recommendation mới.

```text
AI RECOMMENDATION: PENDING HUMAN REVIEW
HUMAN DECISION REQUIRED: <specific approval boundary>
NEXT STEP: Human Director records APPROVED, REVISE, or REJECTED in the persisted review block.
```

Luồng feature có review:

```text
/sdd-context -> human APPROVED
/sdd-spec -> human APPROVED
/sdd-plan -> human APPROVED
/sdd-tasks -> human APPROVED
/add-execute -> AI recommendation -> human APPROVED
/sdd-lint /sdd-audit /sdd-trace -> human disposition
/sdd-sync -> human APPROVED
/git-validate -> /git-commit -> /git-pr
```

Chi tiết schema và state transition nằm trong `.claude/skills/_shared/ai-review-protocol.md`.

---

Luồng khuyến nghị:

1. Feature mới: `/sdd-context` → `/sdd-spec` → `/sdd-plan` → `/sdd-tasks` → `/add-execute` → `/sdd-lint` → `/sdd-audit` → `/sdd-trace` → `/sdd-sync` → `/git-commit` → `/git-pr`.
2. Docs/skill/governance: `/sdd-audit` → `/git-commit` → `/git-pr`.
3. Gate fail: đọc evidence → sửa đúng blocker → chạy lại validator; không dùng `--no-verify` hoặc force-push để bypass.
4. Kết thúc phiên: `/sdd-handoff` → mở lại bằng `scripts/start-claude.ps1 -Continue` → `/sdd-resume`.

---

## 📌 QUY TẮC CỐT LÕI (GOLDEN RULES)

1. **Fix the Spec, NOT the Code**: Khi test thất bại hoặc thiếu trường hợp biên ➔ Không vá code trực tiếp. Cập nhật bổ sung file `SPEC.md` (bump patch version) ➔ Re-generate code từ Spec mới.
2. **EARS Traceability**: Mọi function/method nghiệp vụ trong code bắt buộc có JSDoc tag `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
3. **Zero Hardcoded Secrets**: Tuyệt đối không commit API Keys, Tokens, Passwords vào Git.
4. **SemVer Spec Versioning**: Quản lý phiên bản đặc tả theo `MAJOR.MINOR.PATCH` và cập nhật Changelog đầy đủ.
