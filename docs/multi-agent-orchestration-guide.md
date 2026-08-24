# Hướng dẫn Multi-Agent Orchestration
# Version: 1.1.0
# Tham chiếu: Slide 11.1–11.6 — Multi-Agent Architecture và MCP Access Control

> **Chưa quen với SDD+ADD?** Đọc [`sdd-add-quickstart.md`](./sdd-add-quickstart.md) trước.

---

## 1. Kiến trúc tổng quan

```text
Human Director
      │
      ▼
Lead Agent (@lead-architect)
  ├── đọc CONTEXT, SPEC, PLAN và Architecture Profile
  ├── phân chia task, ownership và MCP profile
  ├── tổng hợp output từ sub-agent
  └── cập nhật shared_context.md
      │
      ├── @backend-agent   src/domain/, src/usecase/
      ├── @infra-agent     src/infra/, tests/integration/
      ├── @interface-agent src/interface/
      └── @tester-agent    tests/unit/, tests/e2e/
```

Nguyên tắc:

- Mỗi Agent sở hữu file boundary rõ ràng; không có hai Agent cùng sửa một file.
- Giao tiếp qua `shared_context.md` và `TASKS.md`, không dựa vào conversation history.
- Lead Agent là nguồn sự thật cho API contract.
- `.sdd/architecture-profile.md` là nguồn sự thật cho tech binding. Lead phải gửi profile version, binding, evidence và exact command cùng task.
- Không Agent nào được suy đoán hoặc thêm HTTP framework, DB, ORM/query layer, validation package hay command ngoài profile đã approved.
- Dependency contract không đổi khi dispatch: interface gọi usecase; usecase phụ thuộc domain và port; infra triển khai port; domain không phụ thuộc adapter.

---

## 2. Vai trò và ownership

| Agent | Vai trò | Được ghi | Chỉ đọc |
| :--- | :--- | :--- | :--- |
| `@lead-architect` | Orchestrator và planner | `.sdd/`, `CLAUDE.md` | `CONSTITUTION.md`, `AGENTS.md` |
| `@backend-agent` | Domain và usecase | `src/domain/`, `src/usecase/` | `src/shared/`, `.sdd/features/` |
| `@infra-agent` | DB, cache, external service | `src/infra/`, `tests/integration/` | `src/domain/`, `src/usecase/` |
| `@interface-agent` | Transport adapter, DTO và presenter | `src/interface/` | `src/usecase/`, `src/shared/` |
| `@tester-agent` | Verification và E2E | `tests/unit/`, `tests/e2e/` | `src/**` |

Tester đọc implementation nhưng không sửa implementation. Nếu hai Agent cần cùng file, Lead giữ ownership hoặc tách task trước khi dispatch.

---

## 3. Giao tiếp và profile gate

`shared_context.md` chứa frozen API contract và trạng thái theo Agent. Sau task, Agent cập nhật đúng section của mình gồm task ID, file đã đổi, binding/evidence đã dùng, command đã chạy, kết quả và blocker.

Trước khi dispatch, Lead gửi:

- Profile version và review status.
- Binding liên quan: HTTP, DB, ORM/query, validation, test/build/lint.
- Evidence path hoặc Human decision.
- Exact verified command được phép chạy.
- Ownership boundary và MCP profile.

```text
1. Lead đọc TASKS.md + Architecture Profile đã approved.
2. Lead gửi task cho sub-agent; chỉ chạy parallel với task độc lập.
3. Sub-agent xác minh task không cần adapter/package/command ngoài profile.
4. Sub-agent cập nhật shared_context.md và báo kết quả cho Lead.
5. Lead xác minh contract, dependency và profile compatibility trước batch kế tiếp.
6. Sau integration, Human Final Review quyết định tiếp tục delivery hay không.
```

Nếu binding chưa chọn, evidence mâu thuẫn hoặc task cần package/command ngoài profile: sub-agent dừng, báo Lead; Lead lưu `PENDING HUMAN REVIEW` và escalate Human Director. Tool borrowing không được bypass technology gate.

---

## 4. Parallel và sequential execution

### Parallel: task độc lập

```text
T001 domain/entity  ──→ @backend-agent  ─┐
T002 infra/repo     ──→ @infra-agent    ─┼→ Lead tổng hợp → T004 test
T003 interface      ──→ @interface-agent─┘
```

### Sequential: có dependency

```text
T001 SPEC review      → Lead
T002 domain entity    → @backend-agent    [sau T001]
T003 repository       → @infra-agent      [sau T002]
T004 controller       → @interface-agent  [sau T002]
T005 integration test → @tester-agent     [sau T003 + T004]
```

---

## 5. Multi-Agent Shadow Plan

Trước khi dispatch, Lead xuất Shadow Plan và chờ Human Director xác nhận:

```text
MULTI-AGENT SHADOW PLAN — Feature: {slug}

ARCHITECTURE PROFILE
- Version/status: {approved profile version/status}
- Bindings/evidence: {relevant approved bindings and evidence}
- Commands: {exact approved commands}

PARALLEL BATCH 1
- @backend-agent: T001, T002
- @infra-agent: T003

SEQUENTIAL BATCH 2
- @interface-agent: T004 (cần output T001)

FINAL BATCH
- @tester-agent: T005, T006

SHARED FILES — Lead trực tiếp xử lý
- src/shared/errors/base-error.ts
```

Scope thay đổi, binding đổi hoặc evidence mất hiệu lực yêu cầu Shadow Plan mới và review mới.

---

## 6. Human Director touch point

| Checkpoint | Trigger | Hành động bắt buộc |
| :--- | :--- | :--- |
| Trước batch parallel | Lead xuất Shadow Plan | Approve hoặc điều chỉnh plan |
| Sau từng Agent | Agent báo `DONE`/`DONE_WITH_CONCERNS` | Review concern nếu có |
| Trước integration test | Lead đã tổng hợp | Spot-check API contract và profile compatibility |
| Sau test | Tester báo kết quả | `APPROVED`, `REVISE` hoặc `REJECTED` |

---

## 7. Escalation

Sub-agent báo Lead khi có file conflict, API contract cần đổi, profile mismatch hoặc dependency block. Lead báo Human Director khi conflict không giải quyết được, cần đổi DB schema/public contract, retry cạn hoặc thiếu Human approval.

Xem `.sdd/mcp-config.yaml` để áp dụng MCP access control và tool borrowing theo least privilege.
