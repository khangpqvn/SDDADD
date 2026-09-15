# Ngữ cảnh ownership, execution và API contract

# Version: 2.0.0
# Last-Updated: 2026-09-16
# Lead Agent: Orchestrator (@main-agent)
# Project Ownership: team
# Agent Execution: orchestrated

> `Project Ownership` là nguồn canonical cho human governance và delivery: `solo` có một Human project owner; `team` có nhiều Human collaborator và là mặc định. `Agent Execution` là nguồn canonical cho cách thực thi: `direct` chạy task trong session hiện tại; `orchestrated` cho phép `/add-execute` điều phối một hoặc nhiều worker sau khi runtime capability được quan sát. Hai trục độc lập; không suy số Human từ số Agent hoặc ngược lại.
>
> Trong một transition release, legacy `# Collaboration Mode: solo|team` chỉ được đọc khi **cả hai** header mới không tồn tại: `solo` map thành `solo/direct`, `team` map thành `team/orchestrated`. Legacy state phải báo migration warning và không được tự rewrite. Invocation mới không nhận `--team-size`, `--project-ownership` hoặc `--agent-execution`.
>
> **Resolver bắt buộc cho mọi consumer:** (1) chỉ dùng canonical khi có đúng một header hợp lệ cho mỗi trục. (2) Khi cả hai canonical header vắng mặt, chỉ dùng đúng một legacy header `# Collaboration Mode: solo|team`; header duplicate hoặc malformed là `BLOCKED`. Map header hợp lệ thành legacy pair rồi báo migration warning. (3) Thiếu, trùng hoặc malformed canonical header là `BLOCKED`; không fallback legacy. (4) Khi có canonical header, legacy header không được dùng để resolve và phải được ghi migration cleanup. `/add-execute` persist source của resolution trong Execution Record, không ghi invocation override.

---

## 1. Human ownership và Agent execution

| Project ownership | Human accountability | Delivery policy |
| :--- | :--- | :--- |
| `solo` | Một Human project owner; họ có thể tự persist Human Final Review. | Human-owned direct delivery sau validation/review; không bắt buộc PR. |
| `team` | Nhiều Human collaborator; collaborator được project ủy quyền có thể persist Human Final Review. | Remote PR/review flow. |

| Agent execution | Hành vi |
| :--- | :--- |
| `direct` | Agent hiện tại thực thi `/add-execute`; vẫn cần Shadow Plan, Action Record, checkpoint, exact command và validation. |
| `orchestrated` | `/add-execute` điều phối worker sau khi runtime Claude Code `Agent` availability được quan sát; unavailable là `BLOCKED`, không fallback sang direct. |

Human Final Review, Architecture Profile, shared-contract ownership, material-state checkpoint, validation và delivery safety không bị nới bởi bất kỳ combination nào. Agent không self-approve hoặc `git push`.

---

## 2. Agent roles và ownership boundary

Các role dưới đây là mẫu cho `Agent Execution: orchestrated`, dùng được trong cả `solo` và `team`. Project ownership chỉ quyết định Human accountability; không giới hạn số Agent.

| Tên Agent | Vai trò / chuyên môn | Ownership boundary |
| :--- | :--- | :--- |
| `@lead-architect` | Governance Plan và shared contract | `.sdd/`, `CLAUDE.md`; sau khi template phát hành, `CONSTITUTION.md` chỉ thay đổi qua RFC đã `APPROVED` |
| `@backend-agent` | Usecase và domain | `src/domain/`, `src/usecase/` |
| `@infra-agent` | DB, cache và integration | `src/infra/`, `tests/integration/` |
| `@interface-agent` | HTTP/event adapter, DTO và presenter | `src/interface/` |
| `@tester-agent` | Verification và E2E | `tests/unit/`, `tests/e2e/` |

`/add-execute` tạo Execution Record, chọn task hoặc feature snapshot, cấp task execution grant, invoke worker khi route orchestrated được persisted và runtime capability đã observed, rồi validate integration. Chỉ contract owner được mutate shared artifact. Mỗi grant có opaque consumer reference do `/add-execute` cấp trước direct action hoặc handoff; mỗi worker nhận feature, task ID, task execution grant ID/attempt, consumer reference, `DISPATCHED` lifecycle eligibility, `UNCONSUMED` consumption state, host execution-claim evidence bound to feature/task/grant/route/consumer khi có, frozen contract version, profile version, binding liên quan, evidence, exact command được phép chạy, ownership/file boundary, allowed action/checkpoint, audit evidence reference và MCP policy profile. Markdown record chỉ là cooperative evidence; consumer reference không chứng minh host đã ngăn replay. Khi host claim unavailable, runtime enforcement phải ghi `UNVERIFIED` và không claim host-level replay prevention; stale/mismatch recorded claim là `BLOCKED`. Worker trả consumer và consumption evidence; chỉ `/add-execute` được allocate, revoke, retire hoặc renew grant. Worker chỉ request contract change, không tự apply; Agent không được thêm package, adapter, path hoặc command ngoài profile đã approved.

Execution evidence lưu dưới `## Current Handoff State` của feature `TASKS.md`. Runtime identity/enforcement phải ghi `VERIFIED` hoặc `UNVERIFIED` theo observed host evidence; `.sdd/mcp-config.yaml` là policy specification, không phải chứng cứ enforcement. Historical Dispatch Record giữ immutable evidence nhưng không cấp authority cho invocation mới.

## 2. Quy tắc thay đổi shared contract (Shared-contract mutation rule)

1. Mọi agent đọc frozen contract record trước khi đổi interface, event, DTO, state hoặc shared behavior.
2. Chỉ contract owner hoặc Lead được sửa contract. Sub-agent phát hiện drift hoặc cần thay đổi ngoài ownership phải dừng, ghi evidence và gửi change request cho owner.
3. Shared contract chỉ dùng technology-neutral shape cho đến khi adapter binding được Architecture Profile approve.
4. Contract change phải cập nhật producer, consumers, compatibility và linked evidence; sau đó quyết định `/sdd-trace` và `/sdd-sync` theo Action Record.

## 3. Bản ghi shared contract đã đóng băng (Frozen shared-contract record)

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
