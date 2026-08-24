# Multi-Agent shared context và API contract

# Version: 1.0.0
# Last-Updated: 2026-08-21 14:40 UTC
# Lead Agent: Orchestrator (@main-agent)

---

## 1. Active Agent và ownership boundary

| Tên Agent | Vai trò / chuyên môn | Ownership boundary |
| :--- | :--- | :--- |
| `@lead-architect` | Governance Plan và contract | `.sdd/`, `CLAUDE.md`; sau khi template phát hành, `CONSTITUTION.md` chỉ thay đổi qua RFC đã `APPROVED` |
| `@backend-agent` | Usecase và domain | `src/domain/`, `src/usecase/` |
| `@infra-agent` | DB, cache và integration | `src/infra/`, `tests/integration/` |
| `@interface-agent` | HTTP/event adapter, DTO và presenter | `src/interface/` |
| `@tester-agent` | Verification và E2E | `tests/unit/`, `tests/e2e/` |

Lead phải gửi mỗi Agent profile version, binding liên quan, evidence, exact command được phép chạy, ownership boundary và MCP profile. Agent không được thêm package, adapter, path hoặc command ngoài profile đã approved.

---

## 2. Frozen API contract

*(Chưa có API contract cố định. `/sdd-tasks` cập nhật phần này cho từng feature sau khi review.)*
