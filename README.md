# SDD + ADD Starter Template

Template chuẩn hóa cho việc xây dựng dự án phần mềm theo phương pháp luận **SDD (Spec-Driven Development)** và **ADD (Agent-Driven Development)** với AI Coding Assistants (Claude Code, Roo Code, Cline, Cursor). Tích hợp sẵn hệ thống **Checkpoints DoD**, **Semantic Versioning Docs**, **Spec Hierarchy** và **Native Shell Scripts cho Repo có sẵn**.

---

## 📖 TÀI LIỆU HƯỚNG DẪN CHI TIẾT (DOCUMENTATION)

Đọc tài liệu đầy đủ tại **[`docs/sdd-add-guide.md`](docs/sdd-add-guide.md)** — Cẩm nang vận hành chi tiết bao gồm:

- 💡 **[Triết lý Cốt lõi & Khái niệm SDD+ADD](docs/sdd-add-guide.md#1-sdd--add-l%C3%A0-g%C3%AC-%C3%BD-ngh%C4%A9a--tri%E1%BA%BFt-l%C3%BD-c%E1%BB%91t-l%C3%B5i)**: Hiểu về Spec là Compiler Interface và nguyên tắc *"Fix the Spec, NOT the Code"*.
- 🔄 **[Quy trình 5 Bước & Definition of Done (DoD)](docs/sdd-add-guide.md#2-quy-tr%C3%ACnh-5-b%C6%B0%E1%BB%9Bc-th%E1%BB%B1c-thi-5-step-workflow)**: Chi tiết đầu vào/đầu ra và tiêu chuẩn hoàn thành cho từng pha từ Context đến Code.
- ✏️ **[Giao thức Sửa Spec Thủ công (Manual Spec Fix Protocol)](docs/sdd-add-guide.md#3-h%C6%B0%E1%BB%9Bng-d%E1%BA%AFn-s%E1%BB%ADa-spec-th%E1%BB%A7-c%C3%B4ng-manual-spec-fix-protocol)**: 4 bước cập nhật Spec, bump version SemVer (`vX.Y.Z`) và đồng bộ lại Code/Test.
- 🎬 **[6 Kịch bản Thực tế (Real-World Scenarios)](docs/sdd-add-guide.md#4-c%C3%A1c-k%E1%BB%8Bch-b%E1%BA%A3n-th%E1%BB%B1c-t%E1%BA%BF-khi-l%C3%A0m-vi%E1%BB%87c-theo-sdd--add-real-world-scenarios)**: Hướng dẫn xử lý khi làm tính năng mới, fix bug, PO đổi yêu cầu, test fail, sửa Hiến pháp (RFC) hoặc tích hợp vào Repo cũ (Brownfield).
- 🔍 **[Truy vết Ma trận Yêu cầu & Phân tích Tác động](docs/sdd-add-guide.md#5-truy-v%E1%BA%BFt--ph%C3%A2n-t%C3%ADch-t%C3%A1c-%C4%91%E1%BB%99ng-thay-%C4%91%E1%BB%95i-y%C3%AAu-c%E1%BA%A7u-requirement-traceability--impact-analysis)**: Cách dùng `/sdd-trace` để phát hiện Untraced Requirements, Code mồ côi và Code bị lỗi thời.
- 🤝 **[Quy trình Hàn thủ & Khôi phục Ngữ cảnh (Handoff & Resume Protocol)](docs/sdd-add-guide.md#8-quy-tr%C3%ACnh-h%C3%A0n-th%E1%BB%A7-v%C3%A0-l%C6%B0u-tr%E1%BA%A1ng-th%C3%A1i-d%E1%BB%9F-dang-handoff--resume-protocol)**: 3 bước tự lưu trạng thái dở dang và resume phiên làm việc tiếp theo với `-c` / `-Continue`.
- 📐 **[EARS Notation Cheat Sheet](docs/sdd-add-guide.md#6-b%E1%BA%A3ng-ti%C3%AAu-chu%E1%BA%A9n-%C4%91%E1%BB%8Bnh-d%E1%BA%A1ng-ears-notation-cheat-sheet)**: 5 mẫu câu EARS (Ubiquitous, Event-driven, State-driven, Optional, Unwanted) để viết đặc tả chuẩn.

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
│   └── skills/             # 9 Custom Slash Commands cho SDD+ADD Workflow (tích hợp Checkpoint DoD)
│       ├── sdd-init/SKILL.md     # /sdd-init (Greenfield Project Initializer)
│       ├── sdd-adopt/SKILL.md    # /sdd-adopt (Brownfield Legacy Adoption & Reverse Spec)
│       ├── sdd-context/SKILL.md  # /sdd-context --feature=<slug> (Pha 0: Context Discovery + DoD)
│       ├── sdd-spec/SKILL.md     # /sdd-spec --feature=<slug> (Pha 1: Executable Spec EARS+BDD+SemVer + DoD)
│       ├── sdd-plan/SKILL.md     # /sdd-plan --feature=<slug> (Pha 2: Architecture & Risk Plan + DoD)
│       ├── sdd-tasks/SKILL.md    # /sdd-tasks --feature=<slug> (Pha 3: Atomic Task Breakdown + DoD)
│       ├── add-execute/SKILL.md  # /add-execute --feature=<slug> (Pha 4 & 5: Execution, Self-Check & DoD)
│       ├── sdd-update/SKILL.md   # /sdd-update --feature=<slug> (Nâng version SemVer, cập nhật EARS & ghi Changelog)
│       └── sdd-trace/SKILL.md    # /sdd-trace --feature=<slug> (Requirement Traceability & Impact Analysis)
├── .sdd/                   # Thư mục quản lý Đặc tả Kỹ thuật (Source of Truth)
│   ├── README.md           # Master Feature Registry (Đăng ký danh sách features)
│   ├── shared_context.md   # Shared State & Active API Contracts giữa các features
│   ├── rfcs/               # Thư mục chứa các đề xuất RFC sửa đổi Hiến pháp
│   └── features/           # Nơi chứa bộ 4 file SDD cho từng feature riêng biệt
├── docs/
│   └── sdd-add-guide.md    # Hướng dẫn chi tiết quy trình 5 bước SDD+ADD, DoD Checklist & Kịch bản thực tế
├── scripts/
│   ├── adopt.sh            # Native Bash Script cho Linux / macOS / Git Bash
│   ├── adopt.ps1           # Native PowerShell Script cho Windows
│   ├── start-claude.sh     # Script khởi động Claude Code ở chế độ bypass permission (Bash)
│   └── start-claude.ps1    # Script khởi động Claude Code ở chế độ bypass permission (PowerShell)
└── src/                    # Source code thực thi (Được sinh từ SPEC.md)
```

---

## 🛠️ DANH SÁCH SLASH COMMANDS (CUSTOM SKILLS)

| Slash Command | File Skill | Công dụng |
| :--- | :--- | :--- |
| `/sdd-init` | `.claude/skills/sdd-init/SKILL.md` | Khởi tạo khung SDD+ADD cho dự án mới (Greenfield) |
| `/sdd-adopt` | `.claude/skills/sdd-adopt/SKILL.md` | Tích hợp SDD+ADD vào repo có sẵn (Brownfield) & Đảo ngược Spec từ code cũ |
| `/sdd-context` | `.claude/skills/sdd-context/SKILL.md` | **Pha 0**: Context Discovery ➔ `.sdd/features/{slug}/CONTEXT.md` |
| `/sdd-spec` | `.claude/skills/sdd-spec/SKILL.md` | **Pha 1**: Executable Spec (SemVer) ➔ `.sdd/features/{slug}/SPEC.md` |
| `/sdd-plan` | `.claude/skills/sdd-plan/SKILL.md` | **Pha 2**: Lập kế hoạch Clean Arch ➔ `.sdd/features/{slug}/PLAN.md` |
| `/sdd-tasks` | `.claude/skills/sdd-tasks/SKILL.md` | **Pha 3**: Atomic Tasks Breakdown ➔ `.sdd/features/{slug}/TASKS.md` |
| `/add-execute` | `.claude/skills/add-execute/SKILL.md` | **Pha 4 & 5**: AI Agent thực thi code, Self-check `CONSTITUTION.md` & Test |
| `/sdd-update` | `.claude/skills/sdd-update/SKILL.md` | Cập nhật đặc tả, nâng version SemVer (Major/Minor/Patch) & ghi Changelog |
| `/sdd-trace` | `.claude/skills/sdd-trace/SKILL.md` | Truy vết ma trận yêu cầu (RTM 5 tầng) & Phân tích tác động khi đổi Spec |

---

## 📌 QUY TẮC CỐT LÕI (GOLDEN RULES)

1. **Fix the Spec, NOT the Code**: Khi test thất bại hoặc thiếu trường hợp biên ➔ Không vá code trực tiếp. Cập nhật bổ sung file `SPEC.md` (bump patch version) ➔ Re-generate code từ Spec mới.
2. **EARS Traceability**: Mọi function/method nghiệp vụ trong code bắt buộc có JSDoc tag `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
3. **Zero Hardcoded Secrets**: Tuyệt đối không commit API Keys, Tokens, Passwords vào Git.
4. **SemVer Spec Versioning**: Quản lý phiên bản đặc tả theo `MAJOR.MINOR.PATCH` và cập nhật Changelog đầy đủ.
