# Multi-Agent shared context và API contract

# Version: 1.0.0
# Last-Updated: 2026-08-21 14:40 UTC
# Lead Agent: Orchestrator (@main-agent)

> **Solo mode?** Khi `--team-size=solo`, dùng section 1A thay vì section 1. Developer vừa là Human Director vừa là sole agent, không có multi-agent role division.

---

## 1A. Solo Developer Context *(solo mode)*

| Owned | Files |
| :--- | :--- |
| `@developer` | Toàn bộ project |

Developer đọc profile, tự dispatch task, tự verify. Không có Lead→sub-agent flow. Human Final Review vẫn bắt buộc trước khi approve artifact.

---

## 1. Active Agent và ownership boundary *(team mode)*

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
