# SDD + ADD Starter Template

Template xây dựng dự án theo **SDD** (Spec-Driven Development) và **ADD** (Agent-Driven Development). Template giữ đặc tả, quyết định Human, evidence thực thi và contract dùng chung trong Git; Agent thực thi trong phạm vi đã duyệt.

## Đọc theo nhu cầu

| Mục đích | Tài liệu |
| :--- | :--- |
| **Bắt đầu lần đầu** | [`docs/sdd-add-quickstart.md`](docs/sdd-add-quickstart.md) |
| Vận hành đầy đủ | [`docs/sdd-add-guide.md`](docs/sdd-add-guide.md) |
| Tra command nhanh | [`docs/sdd-add-field-guide.md`](docs/sdd-add-field-guide.md) |
| Làm theo kịch bản | [`docs/sdd-add-scenario-playbook.md`](docs/sdd-add-scenario-playbook.md) |
| Chọn stack và command | [`docs/architecture-profile-guide.md`](docs/architecture-profile-guide.md) |
| Điều phối nhiều Agent hoặc solo | [`docs/multi-agent-orchestration-guide.md`](docs/multi-agent-orchestration-guide.md) |

## Lifecycle

```text
CONTEXT → SPEC → PLAN → TASKS → execute → verify → sync
```

- `CONTEXT.md` giữ Intent Packet: WHAT, WHY, Definition of Done, boundaries, exclusions và decision owner.
- `SPEC.md` giữ requirement EARS, Methodology Profile và Feature Lock cho phạm vi feature/sprint.
- `PLAN.md` và `TASKS.md` map `REQ-XXX`, architecture/profile evidence, state-change category và verification command.
- Mỗi task có Shadow Plan và Action Record.
- `/sdd-trace` kiểm tra consistency; `/sdd-sync` đồng bộ registry và shared contract khi cần.

## Bắt đầu

### Greenfield

```text
/sdd-init --project-name="my-project"
/sdd-context --feature=feat-user-auth
/sdd-spec --feature=feat-user-auth
```

Sau khi Context và Spec được review, chọn binding cần thiết và exact verification commands trong `.sdd/architecture-profile.md`, rồi ghi Human Final Review `APPROVED` bằng `/sdd-review`.

```text
/sdd-plan --feature=feat-user-auth
/sdd-tasks --feature=feat-user-auth
/add-execute --feature=feat-user-auth
/sdd-lint --feature=feat-user-auth
/sdd-audit --feature=feat-user-auth
/sdd-trace --feature=feat-user-auth
/sdd-sync --feature=feat-user-auth --reason="feature delivery"
```

Baseline chỉ xác nhận TypeScript, Node.js và Clean Architecture. Agent không suy đoán HTTP framework, database, ORM/query layer, validation library, package hoặc test/build/lint command.

### Brownfield

```bash
# Linux/macOS/Git Bash
./scripts/adopt.sh /path/to/existing-repository

# Windows PowerShell
.\scripts\adopt.ps1 -TargetPath C:\Projects\existing-repository
```

Mở repository đích rồi chạy `/sdd-adopt`. Profile chỉ dùng binding tìm được có evidence; conflict giữ `PENDING HUMAN REVIEW`.

## Checkpoint và evidence

Human Final Review là durable decision, không phải chat acknowledgement. Agent chỉ tiếp tục khi artifact prerequisite có `APPROVED` hợp lệ.

Material state change cần checkpoint persisted **trước action**:

- shared/public contract;
- persistence schema hoặc business-data mutation;
- permission, security, dependency hoặc runtime configuration;
- external hoặc irreversible side effect.

Read-only hoặc low-risk task vẫn cần Shadow Plan và Action Record, nhưng baseline không yêu cầu checkpoint trước task. Dùng `/add-execute --strict-checkpoint` nếu project muốn xác nhận mọi task.

## Git delivery

`/git-validate` phải trả `READY` trước commit. Agent chỉ commit khi Human yêu cầu và **không chạy `git push`**.

- Solo: không cần Pull Request. Sau validation/commit, Human chạy `git push -u origin <head>`.
- Team: Agent chỉ tạo Pull Request sau remote branch, strict validation và Human xác nhận nội dung outward-facing. Human vẫn push branch.

## Template utilities

| Utility | Purpose |
| :--- | :--- |
| `scripts/self-heal.sh` | Opt-in, evidence-only bounded recovery. Bắt buộc feature, task, Architecture Profile và task approval, `--max-attempts=1` và `implementation-defect`; không sửa source, commit, push hoặc deploy. |
| `scripts/template-smoke.sh` / `.ps1` | Static release checks: files, links, policy tokens và distribution coverage. Không chạy application command hay mutate repository. |
| `scripts/adopt.*` | Sao chép template vào brownfield repository mà không overwrite target file nếu không explicit force. |
| `scripts/update.*` | Update safe template-owned files, stage governance files, không overwrite `NEVER` adoptee-owned artifacts. |

## Repository structure

```text
.
├── AGENTS.md
├── CLAUDE.md
├── CONSTITUTION.md
├── .claude/skills/
├── .sdd/
│   ├── architecture-profile.md
│   ├── shared_context.md
│   ├── mcp-config.yaml
│   ├── constraints/
│   ├── features/
│   ├── reviews/
│   └── rfcs/
├── docs/
├── scripts/
├── src/
└── tests/
```

## Core rules

1. **Fix the Spec, not the Code.** Requirement thiếu hoặc mơ hồ phải quay lại `/sdd-update` trước khi sửa behavior.
2. **EARS traceability.** Business method dùng `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.
3. **Architecture Profile gate.** Context/Spec có thể technology-neutral; Plan/Tasks/execute phải có binding và exact command đã approved.
4. **Feature-scoped lock.** Feature Lock không khóa project; thay đổi qua `/sdd-update` và review lại.
5. **No self-approval.** Agent không tự approve, push, deploy hoặc tự quyết change material/high-risk.
6. **No secrets.** Không ghi, log hoặc commit credential, token, password hay connection string.

Chi tiết contract của từng command nằm tại `.claude/skills/`; hard rules nằm tại [`CONSTITUTION.md`](CONSTITUTION.md), quyền Agent tại [`AGENTS.md`](AGENTS.md).
