# Multi-Agent Orchestration Guide
# Version: 1.0.0
# Reference: Slide 11.1 - 11.6 — Multi-Agent Architecture & MCP Access Control

---

## 1. Kiến trúc Tổng quan

```
Human Director
      │
      ▼
┌─────────────────────────────────────────────┐
│  Lead Agent (@lead-architect)               │
│  • Đọc CONTEXT, SPEC, PLAN                 │
│  • Phân chia tasks & file ownership        │
│  • Tổng hợp output từ sub-agents           │
│  • Cập nhật shared_context.md              │
└────────────┬───────────────┬───────────────┘
             │               │               │
             ▼               ▼               ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │ @backend-    │ │ @infra-      │ │ @tester-     │
    │  agent       │ │  agent       │ │  agent       │
    │ (usecase/    │ │ (infra/,     │ │ (tests/      │
    │  domain/)    │ │  tests/int.) │ │  unit/, e2e) │
    └──────────────┘ └──────────────┘ └──────────────┘
```

**Nguyên tắc cốt lõi:**
- Mỗi agent sở hữu **file boundary rõ ràng** — không overlap edits
- Giao tiếp qua `shared_context.md` và `TASKS.md` — không qua conversation history
- Lead Agent là **single source of truth** cho API contracts

---

## 2. Agent Roles & File Ownership

| Agent               | Role                      | Owns (Write)                    | Reads (Read-only)               |
| :------------------ | :------------------------ | :------------------------------ | :------------------------------ |
| `@lead-architect`   | Orchestrator & Planner    | `.sdd/`, `CLAUDE.md`            | `CONSTITUTION.md`, `AGENTS.md`  |
| `@backend-agent`    | Domain & Usecase Dev      | `src/domain/`, `src/usecase/`   | `src/shared/`, `.sdd/features/` |
| `@infra-agent`      | DB, Cache, External Svcs  | `src/infra/`, `tests/integration/` | `src/domain/`, `src/usecase/` |
| `@interface-agent`  | HTTP Controllers, DTOs    | `src/interface/`                | `src/usecase/`, `src/shared/`   |
| `@tester-agent`     | Verification & E2E        | `tests/unit/`, `tests/e2e/`     | `src/**` (read-only)            |

---

## 3. Communication Protocol

### 3.1 shared_context.md — Single Source of Truth

Mỗi agent CẬP NHẬT phần của mình trong `.sdd/shared_context.md` sau khi hoàn thành task:

```markdown
## Frozen API Contracts (Updated by @lead-architect)
### POST /orders
- Request: { userId, items: [{productId, qty}], idempotencyKey }
- Response: { orderId, status, total }
- Errors: ValidationError, ConflictError (duplicate idempotencyKey)

## Backend Agent Status (Updated by @backend-agent)
- OrderUsecase: ✅ DONE — createOrder, cancelOrder
- OrderEntity: ✅ DONE — validate(), toDTO()

## Infra Agent Status (Updated by @infra-agent)
- OrderRepository: 🔄 IN PROGRESS — findByIdAndUser, save
```

### 3.2 Coordination Flow

```
1. Lead đọc TASKS.md → giao task cho sub-agents (parallel nếu không có dependency)
2. Sub-agent hoàn thành → cập nhật shared_context.md section của mình
3. Lead đọc shared_context.md → kiểm tra dependencies → unblock task tiếp theo
4. Sau khi tất cả pass → Lead tổng hợp → Human Final Review
```

### 3.3 Conflict Resolution

- **File conflict**: Nếu 2 agent cần cùng 1 file → Lead xử lý file đó, không delegate
- **API contract change**: Chỉ Lead được thay đổi frozen contracts trong `shared_context.md`
- **Test failure after integration**: `@tester-agent` báo cáo cho Lead → Lead quyết định agent nào fix

---

## 4. Parallel vs Sequential Execution

### Parallel (khi tasks độc lập):
```
Task T001 (domain/entity)  ──→ @backend-agent  ─┐
Task T002 (infra/repo)     ──→ @infra-agent    ──┼→ Lead tổng hợp → T004 (tests)
Task T003 (interface/ctrl) ──→ @interface-agent─┘
```

### Sequential (khi có dependency):
```
T001 (SPEC review)     → Lead
T002 (domain entities) → @backend-agent    [blocked until T001 done]
T003 (repository)      → @infra-agent      [blocked until T002 done]
T004 (controller)      → @interface-agent  [blocked until T002 done]
T005 (integration test)→ @tester-agent     [blocked until T003+T004 done]
```

---

## 5. Shadow Plan trong Multi-Agent Context

Trước khi Lead dispatch task đến sub-agent, Lead PHẢI xuất Shadow Plan tổng thể:

```
╔══════════════════════════════════════════════════════════╗
║  MULTI-AGENT SHADOW PLAN — Feature: {slug}              ║
╠══════════════════════════════════════════════════════════╣
║  PARALLEL BATCH 1 (no dependencies):                    ║
║    @backend-agent  → T001, T002                         ║
║    @infra-agent    → T003                               ║
║                                                          ║
║  SEQUENTIAL BATCH 2 (after Batch 1):                    ║
║    @interface-agent → T004 (needs T001 output)          ║
║                                                          ║
║  FINAL BATCH:                                           ║
║    @tester-agent   → T005, T006                         ║
║                                                          ║
║  SHARED FILES (Lead handles directly):                  ║
║    src/shared/errors/base-error.ts                      ║
╚══════════════════════════════════════════════════════════╝
```

---

## 6. Human Director Touch Points

| Checkpoint              | Trigger                              | Action Required          |
| :---------------------- | :----------------------------------- | :----------------------- |
| Before parallel start   | Lead xuất Multi-Agent Shadow Plan    | Approve/adjust plan      |
| After each agent done   | Agent báo DONE/DONE_WITH_CONCERNS    | Review concerns nếu có   |
| Before integration test | Lead tổng hợp xong                   | Spot-check API contracts |
| After all tests pass    | Tester báo DONE                      | Final APPROVED / REJECTED|

---

## 7. Escalation Rules (Multi-Agent)

Sub-agent escalate lên Lead (không trực tiếp lên Human) khi:
1. Phát hiện conflict với file của agent khác
2. API contract cần thay đổi so với `shared_context.md`
3. Task blocked > 10 phút chờ dependency

Lead escalate lên Human Director khi:
1. Conflict không giải quyết được giữa sub-agents
2. Schema DB cần thay đổi
3. Tất cả retry attempts thất bại
