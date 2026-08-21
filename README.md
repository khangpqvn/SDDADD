# SDD + ADD Starter Template

Template chuẩn hóa cho việc xây dựng dự án phần mềm theo phương pháp luận **SDD (Spec-Driven Development)** và **ADD (Agent-Driven Development)** với AI Coding Assistants (Claude Code, Roo Code, Cline, Cursor). Tích hợp sẵn hệ thống **Checkpoints DoD**, **Semantic Versioning Docs**, **Spec Hierarchy** và **Native Shell Scripts cho Repo có sẵn**.

---

## 🚀 HƯỚNG DẪN BẮT ĐẦU

### Trường hợp 1: Khởi tạo Dự án MỚI từ Template (Greenfield)
```bash
# Bước 1: Clone Repository
git clone <repo-url-cua-ban> my-new-project
cd my-new-project

# Bước 2: Khởi tạo dữ liệu framework SDD+ADD
/sdd-init --project-name="my-new-project" --stack="Node.js + TypeScript"

# Bước 3: Triển khai Feature đầu tiên qua 5 bước SDD+ADD
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
│   └── skills/             # 8 Custom Slash Commands cho SDD+ADD Workflow (tích hợp Checkpoint DoD)
│       ├── sdd-init.md     # /sdd-init (Greenfield Project Initializer)
│       ├── sdd-adopt.md    # /sdd-adopt (Brownfield Legacy Adoption & Reverse Spec)
│       ├── sdd-context.md  # /sdd-context --feature=<slug> (Pha 0: Context Discovery + DoD)
│       ├── sdd-spec.md     # /sdd-spec --feature=<slug> (Pha 1: Executable Spec EARS+BDD+SemVer + DoD)
│       ├── sdd-plan.md     # /sdd-plan --feature=<slug> (Pha 2: Architecture & Risk Plan + DoD)
│       ├── sdd-tasks.md    # /sdd-tasks --feature=<slug> (Pha 3: Atomic Task Breakdown + DoD)
│       ├── add-execute.md  # /add-execute --feature=<slug> (Pha 4 & 5: Execution, Self-Check & DoD)
│       └── sdd-trace.md    # /sdd-trace --feature=<slug> (Requirement Traceability & Impact Analysis)
├── .sdd/                   # Thư mục quản lý Đặc tả Kỹ thuật (Source of Truth)
│   ├── README.md           # Master Feature Registry (Đăng ký danh sách features)
│   ├── shared_context.md   # Shared State & Active API Contracts giữa các features
│   ├── rfcs/               # Thư mục chứa các đề xuất RFC sửa đổi Hiến pháp
│   └── features/           # Nơi chứa bộ 4 file SDD cho từng feature riêng biệt
├── docs/
│   └── sdd-add-guide.md    # Hướng dẫn chi tiết quy trình 5 bước SDD+ADD, DoD Checklist & Kịch bản thực tế
├── scripts/
│   ├── adopt.sh            # Native Bash Script cho Linux / macOS / Git Bash
│   └── adopt.ps1           # Native PowerShell Script cho Windows
└── src/                    # Source code thực thi (Được sinh từ SPEC.md)
```

---

## 🛠️ DANH SÁCH SLASH COMMANDS (CUSTOM SKILLS)

| Slash Command | File Skill | Công dụng |
| :--- | :--- | :--- |
| `/sdd-init` | `.claude/skills/sdd-init.md` | Khởi tạo khung SDD+ADD cho dự án mới (Greenfield) |
| `/sdd-adopt` | `.claude/skills/sdd-adopt.md` | Tích hợp SDD+ADD vào repo có sẵn (Brownfield) & Đảo ngược Spec từ code cũ |
| `/sdd-context` | `.claude/skills/sdd-context.md` | **Pha 0**: Context Discovery ➔ `.sdd/features/{slug}/CONTEXT.md` |
| `/sdd-spec` | `.claude/skills/sdd-spec.md` | **Pha 1**: Executable Spec (SemVer) ➔ `.sdd/features/{slug}/SPEC.md` |
| `/sdd-plan` | `.claude/skills/sdd-plan.md` | **Pha 2**: Lập kế hoạch Clean Arch ➔ `.sdd/features/{slug}/PLAN.md` |
| `/sdd-tasks` | `.claude/skills/sdd-tasks.md` | **Pha 3**: Atomic Tasks Breakdown ➔ `.sdd/features/{slug}/TASKS.md` |
| `/add-execute` | `.claude/skills/add-execute.md` | **Pha 4 & 5**: AI Agent thực thi code, Self-check `CONSTITUTION.md` & Test |
| `/sdd-trace` | `.claude/skills/sdd-trace.md` | Truy vết ma trận yêu cầu (RTM 5 tầng) & Phân tích tác động khi đổi Spec |

---

## 📌 QUY TẮC CỐT LÕI (GOLDEN RULES)

1. **Fix the Spec, NOT the Code**: Khi test thất bại hoặc thiếu trường hợp biên ➔ Không vá code trực tiếp. Cập nhật bổ sung file `SPEC.md` (bump patch version) ➔ Re-generate code từ Spec mới.
2. **EARS Traceability**: Mọi function/method nghiệp vụ trong code bắt buộc có JSDoc tag `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
3. **Zero Hardcoded Secrets**: Tuyệt đối không commit API Keys, Tokens, Passwords vào Git.
4. **SemVer Spec Versioning**: Quản lý phiên bản đặc tả theo `MAJOR.MINOR.PATCH` và cập nhật Changelog đầy đủ.
