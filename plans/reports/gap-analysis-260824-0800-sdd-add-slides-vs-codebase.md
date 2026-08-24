# SDD & ADD Methodology Gap Analysis Report

**Date:** 2026-08-24  
**Status:** COMPLETED  
**Scope:** Compare methodology in `./slides` with current codebase implementation (`.sdd/`, `.claude/skills/`, `CONSTITUTION.md`, `AGENTS.md`, `CLAUDE.md`, `docs/`)

---

## Executive Summary

Hệ thống codebase hiện tại đã bao phủ rất tốt hầu hết các nguyên lý cốt lõi của **SDD (Spec-Driven Development)** và **ADD (Agent-Driven Development)** theo bộ bài giảng `./slides`. 

Tuy nhiên, qua so sánh chi tiết, phát hiện **6 điểm/tính năng quan trọng trong Slide chưa được hỗ trợ hoàn chỉnh hoặc thiếu cấu trúc/tự động hóa** trong codebase hiện tại.

---

## Detailed Gap Analysis (Các điểm chưa được hỗ trợ hoặc thiếu sót)

### 1. Thiếu cấu trúc quản lý Constraint Documents phân tầng (3-Layer Hierarchy)
- **Slide (10.4):** Yêu cầu cấu trúc Constraint Documents theo 3 tầng rõ ràng:
  - `Layer 1 (Global):` `.sdd/constraints/global.md` (Tech stack, approved/banned packages, file naming)
  - `Layer 2 (Business):` `.sdd/constraints/business.md` (Auth rules, PII masking, rate-limit, soft delete)
  - `Layer 3 (Safety):` `.sdd/constraints/safety.md` (Cấm drop DB, cấm delete data không WHERE, commit rules)
- **Codebase:**
  - Quy tắc rải rác ở `CONSTITUTION.md` và `AGENTS.md`.
  - Chưa có thư mục `.sdd/constraints/` chứa 3 file tiêu chuẩn này.
  - Chưa có skill tự động check/enforce Constraint Compliance sau khi agent sinh code.

### 2. Thiếu quy tắc `.agentignore` (Context Hygiene)
- **Slide (10.6.3):** Đặt ra quy tắc `.agentignore` (hoặc cấu hình exclude patterns cho Agent) để loại bỏ file rác (`node_modules/`, `dist/`, `*.log`, `*.pb.go`, build artifacts) giúp tiết kiệm context window và tránh context pollution.
- **Codebase:** Chưa có file `.agentignore` hoặc hướng dẫn cấu hình chi tiết cho Claude Code/Cline trong repo.

### 3. Thiếu cơ chế/protocol cho Kỹ thuật "Shadowing" (Shadow Plan)
- **Slide (10.6.1):** Yêu cầu Agent "nói to kế hoạch" (Shadow Plan) về danh sách file sẽ READ/CREATE/MODIFY và commands sẽ RUN *trước khi* thực hiện action thật để kiểm soát rủi ro và tiết kiệm token.
- **Codebase:** Các skill `/sdd-plan` và `/sdd-tasks` đã tạo PLAN/TASKS, nhưng trong bước `/add-execute` chưa có prompt pattern bắt buộc Agent xuất `SHADOW PLAN` ngắn gọn trước từng task thực thi nhỏ.

### 4. Thiếu hệ thống Skill Sets mở rộng chuyên biệt (10 Must-have Technical Skills)
- **Slide (11.3):** Đề xuất 10 SKILL.md chuyên biệt (như *SQL Performance Tuner*, *API Security Auditor*, *React Component Architect*, *Go Error Handler*, *Frontend Performance Optimizer*, v.v.) đóng gói tri thức Senior.
- **Codebase:** Hệ thống skill trong `.claude/skills/` hiện tập trung vào quy trình SDD/Git (`sdd-*`, `git-*`, `add-execute`). Thiếu các kỹ thuật chuyên môn sâu (Deep Technical Skills) đóng gói cho agent ở level code/architecture.

### 5. Thiếu Tự động hóa Self-Healing Loop bằng Lifecycle Hooks
- **Slide (11.4):** Hướng dẫn dựng Self-Healing Loop tự động (chạy test -> bắt log lỗi -> gọi agent sửa tối đa 3 lần -> re-test -> tự động commit nếu pass).
- **Codebase:** Chưa có file script `.claude/settings.json` hook hoặc `scripts/self_heal.sh` để tự động hóa vòng lặp sửa lỗi này.

### 6. Chưa có hướng dẫn/kịch bản Multi-Agent Orchestration & Tool Borrowing (MCP Access Control)
- **Slide (11.1 - 11.6):** Mô tả kiến trúc Multi-Agent (Lead + Sub-agents UI/Logic/Worker), giao tiếp qua `shared_context.md` và phân quyền MCP tools per-agent (`.sdd/mcp-config.yaml`).
- **Codebase:** Tài liệu `docs/sdd-add-guide.md` tập trung vào Single Agent + Human Director. Chưa có hướng dẫn chi tiết kịch bản phối hợp Multi-Agent song song và cấu hình phân quyền MCP cho từng sub-agent.

---

## Matrix So Sánh Tổng Hợp

| Hạng mục / Kỹ thuật | Slide tham chiếu | Codebase hiện tại | Trạng thái hỗ trợ |
| :--- | :--- | :--- | :--- |
| **Quy trình 5 pha SDD** | Slide 6.1 | Đã hỗ trợ đầy đủ (`/sdd-context`, `/sdd-spec`, `/sdd-plan`, `/sdd-tasks`, `/add-execute`) | ✅ HOÀN THIỆN |
| **EARS Notation & Traceability** | Slide 5, 6 | `@ears` tag bắt buộc trong code & skill `/sdd-trace` | ✅ HOÀN THIỆN |
| **Human Final Review Gate** | Slide 10.1 | Khóa cứng qua `/sdd-review` & `ai-review-protocol.md` | ✅ HOÀN THIỆN |
| **Fix the Spec, Not Code** | Slide 6.1, 10.1 | Đã đưa vào `AGENTS.md` & `CONSTITUTION.md` | ✅ HOÀN THIỆN |
| **Constraint Docs (3-Layer)** | Slide 10.4 | Rải rác ở CONSTITUTION/AGENTS, chưa có `.sdd/constraints/` | ⚠️ THIẾU CẤU TRÚC |
| **.agentignore (Context Hygiene)** | Slide 10.6.3 | Chưa có cấu hình `.agentignore` | ❌ CHƯA CÓ |
| **Shadowing Protocol** | Slide 10.6.1 | Chưa tích hợp bước `Shadow Plan` bắt buộc vào execution | ⚠️ THIẾU PROTOCOL |
| **10 Technical Skills Set** | Slide 11.3 | Mới có SDD/Git skills, thiếu technical domain skills | ⚠️ THIẾU DOMAIN SKILLS |
| **Self-Healing Loop Script** | Slide 11.4 | Chưa có script/hook tự động hóa `self_heal.sh` | ❌ CHƯA CÓ |
| **Multi-Agent Orchestration & MCP** | Slide 11.1 - 11.6 | Mới hỗ trợ Single-Agent workflow | ⚠️ CẦN BỔ SUNG GUIDE |

---

## Unresolved Questions

1. Dự án có cần bổ sung ngay thư mục chuẩn `.sdd/constraints/` (global.md, business.md, safety.md) không?
2. Có cần bổ sung thêm các Domain Technical Skills (như Security Auditor, Performance Tuner) vào `.claude/skills/` hay không?
3. Có nên tích hợp script Self-Healing Loop (`self_heal.sh`) vào thư mục `scripts/` của repo không?
