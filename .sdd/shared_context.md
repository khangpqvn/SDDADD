# MULTI-AGENT SHARED CONTEXT & API CONTRACTS

# Version: 1.0.0
# Last-Updated: 2026-08-21 14:40 UTC
# Lead Agent: Orchestrator (@main-agent)

---

## 1. Active Agents & Bounded Context Ownership

| Agent Name | Role / Specialist | Ownership Boundary |
| :--- | :--- | :--- |
| **`@lead-architect`** | Plan & Contract Governance | `.sdd/`, `CONSTITUTION.md`, `CLAUDE.md` |
| **`@backend-agent`** | Usecase & Domain Developer | `src/domain/`, `src/usecase/` |
| **`@infra-agent`** | DB, Redis & Integration Dev | `src/infra/`, `tests/integration/` |
| **`@tester-agent`** | Verification & E2E Tester | `tests/unit/`, `tests/e2e/` |

---

## 2. Frozen API Contracts (Single Source of Truth)

*(Chưa có API contract tĩnh. Sẽ được tự động cập nhật khi chạy `/sdd-tasks` cho từng feature)*
