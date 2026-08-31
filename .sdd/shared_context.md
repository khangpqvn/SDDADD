# Multi-Agent shared context và API contract

# Version: 1.1.0
# Last-Updated: 2026-08-31
# Lead Agent: Orchestrator (@main-agent)
# Collaboration Mode: team

> `Collaboration Mode` là nguồn duy nhất cho default dispatch mode: `team` hoặc `solo`. `--team-size=solo|team` chỉ override explicit cho invocation hiện tại. Solo mode không bỏ qua review, Architecture Profile, shared-contract ownership hoặc delivery safety gate.

---

## 1A. Solo Developer Context *(solo mode)*

| Owned | Files |
| :--- | :--- |
| `@developer` | Toàn bộ project |

Developer đọc profile, tự dispatch task, tự verify. Human Final Review vẫn bắt buộc trước khi approve artifact. Khi thay đổi shared/public contract, developer ghi frozen contract record và Action Record trước task completion.

---

## 1. Active Agent và ownership boundary *(team mode)*

| Tên Agent | Vai trò / chuyên môn | Ownership boundary |
| :--- | :--- | :--- |
| `@lead-architect` | Governance Plan và shared contract | `.sdd/`, `CLAUDE.md`; sau khi template phát hành, `CONSTITUTION.md` chỉ thay đổi qua RFC đã `APPROVED` |
| `@backend-agent` | Usecase và domain | `src/domain/`, `src/usecase/` |
| `@infra-agent` | DB, cache và integration | `src/infra/`, `tests/integration/` |
| `@interface-agent` | HTTP/event adapter, DTO và presenter | `src/interface/` |
| `@tester-agent` | Verification và E2E | `tests/unit/`, `tests/e2e/` |

Lead phải gửi mỗi Agent frozen contract version, profile version, binding liên quan, evidence, exact command được phép chạy, ownership/file boundary, allowed action/checkpoint và MCP policy profile. Agent không được thêm package, adapter, path hoặc command ngoài profile đã approved.

## 2. Shared-contract mutation rule

1. Mọi agent đọc frozen contract record trước khi đổi interface, event, DTO, state hoặc shared behavior.
2. Chỉ contract owner hoặc Lead được sửa contract. Sub-agent phát hiện drift hoặc cần thay đổi ngoài ownership phải dừng, ghi evidence và gửi change request cho owner.
3. Shared contract chỉ dùng technology-neutral shape cho đến khi adapter binding được Architecture Profile approve.
4. Contract change phải cập nhật producer, consumers, compatibility và linked evidence; sau đó quyết định `/sdd-trace` và `/sdd-sync` theo Action Record.

## 3. Frozen shared-contract record

Dùng một record cho từng contract đã fixed. Giữ placeholder khi chưa có contract thay vì suy đoán API syntax.

```markdown
### Contract: <contract-id>
- Version: <version>
- Status: DRAFT | FROZEN | SUPERSEDED
- Producer: <feature or component>
- Consumers: <feature/component list or none>
- Owner: <Lead or named role>
- Shape and semantics: <technology-neutral data/behavior contract>
- Compatibility: compatible | migration required | pending decision
- Linked requirements/tasks: <REQ-XXX, T00X>
- Review and execution evidence: <review/action-record reference>
- Last sync: <date and reason>
- Unresolved decision: <none or decision owner>
```

*(Chưa có shared contract cố định. `/sdd-tasks` hoặc `/sdd-sync` chỉ thêm record sau khi approved feature evidence xác định contract.)*
