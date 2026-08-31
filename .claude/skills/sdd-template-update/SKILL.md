---
name: sdd-template-update
description: Kiểm tra version template đã adopt, so sánh với template nguồn và hướng dẫn merge governance files đã staged
user-invocable: true
---

# SDD Template Updater (`/sdd-template-update`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`, `SAFE`, `STAGED`, `NEVER`, `UP-TO-DATE`, `OUTDATED`), file paths, and CLI commands are language-invariant.

Dùng sau khi chạy `scripts/update.sh` hoặc `scripts/update.ps1` để kiểm tra kết quả và hướng dẫn merge governance files.

## Tham số

- `--template=<path>`: Tùy chọn; path tới template nguồn. Không truyền thì dùng `template-source` trong `.sdd/template-version.md`.
- `--check`: Chỉ so sánh version và báo cáo drift — không chạy update script.
- `--review`: So sánh staged governance files (`.sdd/updates/`) với bản hiện tại và đề xuất merge.

## Phân loại file theo chiến lược update

| Loại | Files | Hành động |
| :--- | :--- | :--- |
| **SAFE** — template-owned | `.claude/skills/**`, `docs/sdd-add-quickstart.md`, `docs/sdd-add-guide.md`, `docs/sdd-add-field-guide.md`, `docs/sdd-add-scenario-playbook.md`, `docs/architecture-profile-guide.md`, `docs/multi-agent-orchestration-guide.md`, `scripts/adopt.sh`, `scripts/adopt.ps1`, `scripts/self-heal.sh`, `scripts/template-smoke.sh`, `scripts/template-smoke.ps1`, `scripts/start-claude.sh`, `scripts/start-claude.ps1`, `scripts/update.sh`, `scripts/update.ps1` | Overwrite trực tiếp; không chứa customization của user. |
| **STAGED** — cần review | `CONSTITUTION.md`, `AGENTS.md`, `CLAUDE.md`, `.agentignore` | Copy vào `.sdd/updates/`; user merge thủ công sau khi AI review diff. |
| **NEVER** — user-owned | `.sdd/architecture-profile.md`, `.sdd/README.md`, `.sdd/shared_context.md`, `.sdd/mcp-config.yaml`, `.sdd/features/`, `.sdd/reviews/`, `.sdd/rfcs/`, `.sdd/constraints/` | Không bao giờ overwrite; chứa quyết định kiến trúc và feature work của user. |

## Quy trình

### 1. `--check` — kiểm tra version drift

1. Đọc `.sdd/template-version.md`: `template-version`, `adopted-at`, `last-updated`, `template-source`.
2. Nếu có `--template` hoặc `template-source` hợp lệ, đọc `.sdd/template-version.md` của template nguồn và so sánh version.
3. Báo cáo version đang dùng vs template, số ngày từ `last-updated`, lệnh update theo OS.

```text
TEMPLATE VERSION CHECK
Installed : v{installed}  (last updated: {last-updated})
Template  : v{template}   (source: {template-source})
Status    : UP-TO-DATE | OUTDATED
Next step : {update command}
```

### 2. (không flag) — chạy update script

1. Xác định OS (Windows → PowerShell, Linux/macOS → Bash).
2. Xác nhận `template-source` từ `.sdd/template-version.md` hoặc `--template`.
3. Hiển thị lệnh update và chờ Human Director xác nhận trước khi chạy.
4. Sau khi chạy, kiểm tra `.sdd/updates/` và tự động chuyển sang `--review` nếu có staged files.

```bash
# Linux / macOS
./scripts/update.sh <template-path>

# Windows PowerShell
.\scripts\update.ps1 <template-path>
```

Thêm `--dry-run` để xem trước. `--force-governance` chỉ overwrite `AGENTS.md`, `CLAUDE.md` và `.agentignore` với backup; `CONSTITUTION.md` luôn stage và chỉ được merge sau RFC `APPROVED`.

### 3. `--review` — review staged governance files

1. Kiểm tra `.sdd/updates/` có file không; nếu không có, báo không cần merge.
2. Với mỗi staged file, so sánh với bản hiện tại và liệt kê:
   - Section/block mới trong template.
   - Section/block hiện tại có thể bị ảnh hưởng.
   - Đề xuất merge action: **keep**, **replace**, **merge-manually**.
3. Tạo AI recommendation theo `.claude/skills/_shared/ai-review-protocol.md`.
4. Human Director quyết định merge action; Agent không tự merge hoặc overwrite governance files.

```text
STAGED GOVERNANCE REVIEW
─────────────────────────────────────────────
File: AGENTS.md
  Current version  : v{x}
  Template version : v{y}
  New in template  : {description}
  Conflict risk    : LOW | MEDIUM | HIGH
  Recommendation   : {keep | replace | merge-manually}
  Action required  : {next command or manual step}
─────────────────────────────────────────────
Next step: Merge manually → delete .sdd/updates/ → commit
```

## AI Recommendation và Human Final Review

Sau khi chạy `--review`, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm staged files, diff summary, merge risk, action đề xuất và NEVER-file nào không nên đụng tới. Lưu tại `.sdd/reviews/update-<timestamp>.md` với `PENDING HUMAN REVIEW`. Human Director quyết định merge action; Agent không tự merge, overwrite hoặc xoá staged files.

## Safety gates

- Không bao giờ đề xuất ghi vào NEVER files.
- `CONSTITUTION.md` luôn chỉ stage, kể cả `--force-governance`; thay đổi Layer 1/2 cần RFC qua `/sdd-rfc` trước khi merge.
- `AGENTS.md` thay đổi permission cần Human Director approval theo `/sdd-agents-edit`.
- Agent không tự chạy update script mà không có xác nhận explicit của Human Director.
- Nếu `template-source` không xác định được và không có `--template`, dừng và yêu cầu Human cung cấp path.
