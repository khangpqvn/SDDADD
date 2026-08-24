# Cầm Tay Chỉ Việc — SDD + ADD Field Guide
# Version: 1.1.0

Thẻ thao tác nhanh — dùng khi bạn đã hiểu quy trình và chỉ cần tra command.  
Chọn kịch bản → thực hiện từng bước → dừng tại Human Final Review.

> **Lần đầu?** Đọc [`sdd-add-quickstart.md`](./sdd-add-quickstart.md) trước.  
> **Cần giải thích đầy đủ?** Xem [`sdd-add-guide.md`](./sdd-add-guide.md).  
> **Cần thao tác chi tiết từng kịch bản?** Xem [`sdd-add-scenario-playbook.md`](./sdd-add-scenario-playbook.md).

---

## Quy tắc bất biến

1. Agent đề xuất; Human ghi quyết định bền vững bằng `/sdd-review`.
2. `PENDING / REVISE / REJECTED` → dừng, không chuyển pha.
3. Profile `BLOCKED` hoặc thiếu exact command → Kịch bản 8.
4. Test fail vì Spec thiếu rule → sửa Spec, không vá code.
5. Không tự thêm package, ORM, framework, migration ngoài profile đã duyệt.
6. Shadow Plan trước mỗi task `/add-execute`.

---

## Chọn kịch bản

| Tình huống | Kịch bản |
| :--- | :--- |
| Dự án mới, chưa chọn stack | **1** |
| Dự án mới, đã biết một phần stack | **2** |
| Repository có sẵn source code | **3** |
| Module legacy cần mô tả trước khi sửa | **4** |
| Feature mới, profile sẵn sàng | **5** |
| Requirement hoặc contract thay đổi | **6** |
| Test / CI thất bại | **7** |
| Thiếu binding, approval hoặc command | **8** |
| Thay đổi xuyên Domain → Infra | **9** |
| Feature lớn, nhiều Agent | **10** |
| Audit chuyên sâu (security / SQL / error) | **11** |
| Dừng / tiếp tục phiên | **12** |
| Chỉ đổi docs / skill / governance | **13** |
| Thay đổi Constitution hoặc governance rule | **14** |
| Vòng lặp tự sửa test có kiểm soát | **15** |
| Commit và Pull Request | **16** |

---

## Kịch bản 1 — Greenfield, chưa biết stack

```text
/sdd-init --project-name="my-project"
```

→ Mở `.sdd/architecture-profile.md`, xác nhận binding còn thiếu là `BLOCKED`.
→ Human review `.sdd/reviews/init.md`.
→ Kịch bản 5 cho feature đầu tiên; Kịch bản 2 khi cần chọn stack.

**Không làm:** `/sdd-plan`, `/sdd-tasks`, `/add-execute` khi profile còn thiếu binding/command.

---

## Kịch bản 2 — Greenfield, đã biết một phần stack

```text
/sdd-init --project-name="my-project" --stack="Node.js + TypeScript + PostgreSQL"
```

→ Kiểm tra binding còn thiếu (HTTP framework, ORM, validation, test command).
→ Ghi evidence hoặc Human decision vào profile.
→ `/sdd-review --target=.sdd/architecture-profile.md ...` → `APPROVED`.
→ Chỉ sau đó mới tạo `PLAN.md`, `TASKS.md` và thực thi.

---

## Kịch bản 3 — Brownfield, tích hợp vào repo có sẵn

```bash
./scripts/adopt.sh /path/to/existing-repository
# Windows:
.\scripts\adopt.ps1 -TargetPath C:\Projects\existing-repository
```

→ Mở repo đích, chạy `/sdd-adopt`.
→ Đối chiếu binding evidence với profile. Conflict → `PENDING HUMAN REVIEW`.
→ Approve scope tại `.sdd/reviews/adopt-*.md` trước feature work.

---

## Kịch bản 4 — Reverse Spec module legacy

```text
/sdd-adopt --reverse-feature=feat-legacy-auth --path=src/modules/auth
```

→ Đọc `CONTEXT.md`, `SPEC.md`, `PLAN.md`, `TASKS.md` từ source quan sát.
→ Owner review: behavior nào giữ / sửa / bỏ.
→ Chỉ sau approval mới refactor hoặc execute.

---

## Kịch bản 5 — Feature chuẩn, từ đầu đến delivery

```text
/sdd-context  --feature=feat-order-checkout
              → Human review CONTEXT.md
/sdd-spec     --feature=feat-order-checkout
/sdd-lint     --feature=feat-order-checkout
              → Human review + lock SPEC.md
/sdd-plan     --feature=feat-order-checkout
              → Human review PLAN.md
/sdd-tasks    --feature=feat-order-checkout
              → Human review TASKS.md
              [Mỗi task: Shadow Plan → Human confirm → thực thi]
/add-execute  --feature=feat-order-checkout
/sdd-lint     --feature=feat-order-checkout
/sdd-audit    --feature=feat-order-checkout
/sdd-trace    --feature=feat-order-checkout
/sdd-sync
              → Kịch bản 16
```

**Checklist trước execute:** Spec `APPROVED & LOCKED` · Plan/Tasks `APPROVED` · binding/command `APPROVED` · Shadow Plan confirmed.

---

## Kịch bản 6 — Requirement hoặc contract thay đổi

| Loại thay đổi | Bump |
| :--- | :--- |
| Làm rõ / sửa behavior tương thích | `patch` |
| Thêm behavior tương thích | `minor` |
| Phá vỡ API / data / behavior contract | `major` |

```text
/sdd-update --feature=feat-order-checkout --bump=patch --reason="Clarify duplicate payment"
```

→ Bổ sung EARS, BDD, error, acceptance, Out of Scope, changelog.
→ Review lại + lock. Approval cũ không còn hợp lệ.
→ `major`: phải có migration plan, rollback plan, risk trước execute.

---

## Kịch bản 7 — Test / CI thất bại

| Câu hỏi | Hành động |
| :--- | :--- |
| Code sai so với Spec rõ? | Sửa code → chạy lại exact command |
| Business rule chưa có trong Spec? | **Kịch bản 6** trước |
| Profile / command sai hoặc chưa approved? | **Kịch bản 8** |
| Security hoặc DB migration? | Escalate Human Director trước |

```text
/sdd-trace --feature=<slug> --diff
/sdd-audit --feature=<slug>
```

**Không làm:** thêm filter, skip, mock hoặc biến failure thành warning để pass.

---

## Kịch bản 8 — Thiếu binding, approval hoặc command

Dấu hiệu: `CONFIGURATION GAP`, profile `BLOCKED`, review `PENDING`, task không có exact verification command.

1. Dừng tại artifact hiện tại.
2. Ghi recommendation vào `.sdd/architecture-profile.md`: binding cần chọn, feature cần binding, evidence, risk, exact command.
3. Human Director chọn → reviewer ghi `APPROVED` bằng `/sdd-review`.
4. Đồng bộ `CLAUDE.md` với `/sdd-claude-edit` khi kiến trúc human-readable thay đổi.
5. Sinh lại Plan/Tasks hoặc Shadow Plan bị invalidated.

---

## Kịch bản 9 — Thay đổi xuyên Domain → Infra

```text
/sdd-layer-edit --feature=feat-order-checkout --action=modify --target=CreateOrder
```

→ Xác nhận Shadow Plan trước edit.

Dependency direction bắt buộc:
- `src/domain/`: entity / value object / event — thuần TypeScript.
- `src/usecase/`: business workflow, port, `@ears`.
- `src/interface/`: transport / DTO / presenter — chỉ gọi usecase.
- `src/infra/`: DB / cache / external adapter đã approved.
- Controller **không truy cập DB/repository trực tiếp**.

---

## Kịch bản 10 — Feature lớn, nhiều Agent

1. Đọc [multi-agent-orchestration-guide.md](./multi-agent-orchestration-guide.md).
2. Lead kiểm tra profile `APPROVED`, `TASKS.md`, dependency, shared files.
3. Lead xuất Multi-Agent Shadow Plan: batch parallel/sequential, ownership, MCP profile, binding evidence, exact command.
4. Human Director approve Shadow Plan.
5. Mỗi Agent nhận task ID + file boundary không chồng lấn; shared file do Lead xử lý.
6. Mỗi Agent cập nhật `.sdd/shared_context.md`.
7. Lead kiểm tra API contract + profile compatibility sau mỗi batch.
8. Sau integration:

```text
/sdd-audit
/sdd-trace
/git-validate --scope=commit
```

**Dừng ngay:** file conflict, API contract cần đổi, binding mismatch, Agent muốn thêm package ngoài profile.

---

## Kịch bản 11 — Audit chuyên sâu

```text
# API security (feature có identity, auth, PII, public API)
/api-security-auditor --feature=feat-order-checkout

# SQL performance (feature có query / persistence)
/sql-performance-tuner --feature=feat-order-checkout --mode=audit

# Error handling (error contract không nhất quán)
/error-handler-pattern --feature=feat-order-checkout --mode=audit
```

CRITICAL → remediation trước delivery.
Binding chưa chọn → expected: `CONFIGURATION GAP`, không phải `PASS/FAIL` suy đoán.

---

## Kịch bản 12 — Dừng và tiếp tục phiên

### Dừng

```text
/sdd-handoff --feature=feat-order-checkout
```

Kiểm tra `TASKS.md`: `[x]` = evidence pass · `[/]` = đang làm · `[ ]` = chưa làm.
Kiểm tra `Current Handoff State`: file đổi, task tiếp theo, profile/evidence, command/result, blocker.

### Tiếp tục

```bash
./scripts/start-claude.sh --continue
# Windows:
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Continue
```

```text
/sdd-resume --feature=feat-order-checkout
```

Chỉ gọi `/add-execute` khi task scope, review, binding và command đều `APPROVED`.

---

## Kịch bản 13 — Chỉ thay đổi docs / skill / cấu hình governance

1. Xác định file **không phải** `CONSTITUTION.md`.
2. Cập nhật đúng file trong `docs/`, `.claude/skills/`, `AGENTS.md`, `CLAUDE.md`.
3. Chạy:

```text
/sdd-audit
/git-validate --scope=commit
```

`N/A` cho trace/test chỉ hợp lệ khi không có source/test tương ứng và có reason cụ thể.

---

## Kịch bản 14 — Thay đổi Constitution / governance rule

```text
/sdd-rfc --title=soft-delete-policy
```

→ Ghi motivation, proposed change, alternatives, security/risk, migration, rollback trong RFC tại `.sdd/rfcs/`.
→ Reviewer có thẩm quyền approve.
→ Sau approval:

```text
/sdd-rfc --approve=<rfc-number>
```

→ Đồng bộ artifact / profile / docs bị ảnh hưởng → audit → delivery.
**Không sửa trực tiếp `CONSTITUTION.md`** sau khi template phát hành.

---

## Kịch bản 15 — Self-healing test có kiểm soát

```bash
./scripts/self-heal.sh --test-cmd="<approved test command>"
./scripts/self-heal.sh --test-cmd="<approved test command>" --feature=feat-order-checkout
./scripts/self-heal.sh --test-cmd="<approved test command>" --max-attempts=2
./scripts/self-heal.sh --test-cmd="<approved test command>" --dry-run
```

Flow: chạy command → pass: dừng (uncommitted) → fail: phân tích + sửa tối đa `--max-attempts` lần → cạn lượt: incident report tại `.sdd/reviews/self-heal-incident-<timestamp>.md` → escalate Human Director.

**Không dùng khi:** Spec gap · DB schema/migration · profile/command chưa approved · production.

---

## Kịch bản 16 — Commit và Pull Request

```text
# Kiểm tra diff: chỉ intended files, không có secret/credential/PII
/git-validate --scope=commit
              → Kết quả READY
/git-commit   --message="feat(order): add checkout flow"

# Trước Pull Request
/git-validate --scope=pr --strict
              → Kết quả READY
/git-pr
```

`PASS` = kết quả một check. `READY` = quyết định delivery của `/git-validate`. Không thay thế bằng lời xác nhận miệng.

---

## Human Final Review — cú pháp chuẩn

```text
/sdd-review
  --feature=<slug>
  --artifact=<context|spec|plan|tasks|execution>
  --status=<APPROVED|REVISE|REJECTED>
  --decision="<quyết định cụ thể và phạm vi>"
  --reviewer="<tên, vai trò>"
  --reviewed-at="<ISO-8601 có timezone>"
  --follow-up="<command hoặc điều kiện tiếp theo>"

# Ví dụ
/sdd-review --feature=feat-user-register --artifact=context --status=APPROVED \
  --decision="Đã duyệt problem, stakeholders, glossary, constraints." \
  --reviewer="Nguyen Van A, Product Owner" \
  --reviewed-at="2026-08-24T13:00:00+07:00" \
  --follow-up="/sdd-spec --feature=feat-user-register"
```

---

## Bảng xử lý blocker nhanh

| Hiện tượng | Không làm | Làm |
| :--- | :--- | :--- |
| Profile thiếu HTTP/DB/ORM/test command | Đoán package hoặc adapter | Ghi recommendation → Human approval → sinh lại downstream |
| Spec `DRAFT` hoặc review `PENDING` | Execute code | Hoàn thiện artifact → `/sdd-review` |
| Test fail — edge case chưa có trong Spec | Vá code tạm | `/sdd-update` → review/lock → cập nhật Plan/Tasks → execute |
| Test fail — code trái Spec | Đổi requirement để khớp code | Sửa code → chạy lại exact command |
| Task conflict nhiều Agent sửa cùng file | Để conflict tự giải quyết | Lead giữ shared file hoặc tách task |
| Cần DB migration / delete | Chạy tự động không review | Đọc `constraints/safety.md` → plan/rollback → Human review |
| CRITICAL audit finding | Commit với rationale chung | Remediate → audit lại |
| Git validation chưa `READY` | Commit / PR | Sửa failure / ghi disposition hợp lệ |

---

## Tham chiếu nhanh command → kịch bản

| Lệnh / script | Kịch bản |
| :--- | :--- |
| `./scripts/adopt.sh` hoặc `/sdd-init` | 1, 2, 3 |
| `/sdd-adopt` | 3, 4 |
| `/sdd-context` | 5 |
| `/sdd-spec` + `/sdd-lint` | 5 |
| `/sdd-plan` + `/sdd-tasks` | 5, 8 |
| `/add-execute` + `/sdd-layer-edit` | 5, 9 |
| `/sdd-update --bump=patch/minor/major` | 6 |
| `/sdd-audit` + `/sdd-trace` + `/sdd-sync` | 5, 7, 10 |
| `/api-security-auditor` | 11 |
| `/sql-performance-tuner` | 11 |
| `/error-handler-pattern` | 11 |
| `/sdd-handoff` + `/sdd-resume` | 12 |
| `/sdd-rfc` | 14 |
| `./scripts/self-heal.sh` | 15 |
| `/git-validate` + `/git-commit` + `/git-pr` | 16 |

---

## Tài liệu tham chiếu

- [Hướng dẫn vận hành SDD + ADD](./sdd-add-guide.md)
- [Sổ tay kịch bản SDD + ADD](./sdd-add-scenario-playbook.md)
- [Hướng dẫn Architecture Profile](./architecture-profile-guide.md)
- [Hướng dẫn Multi-Agent Orchestration](./multi-agent-orchestration-guide.md)
- [Constitution](../CONSTITUTION.md)
- [Agent governance](../AGENTS.md)
- [Architecture Profile](../.sdd/architecture-profile.md)
- [Safety constraints](../.sdd/constraints/safety.md)
