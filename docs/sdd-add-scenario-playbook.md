# Sổ tay kịch bản SDD + ADD

Tài liệu thao tác từng bước cho người dùng Starter Template SDD + ADD. Chọn đúng kịch bản, làm theo từng bước, dừng tại các checkpoint Human Final Review.

> **Lần đầu?** Đọc [`sdd-add-quickstart.md`](./sdd-add-quickstart.md) trước để hiểu mental model.  
> **Tra nhanh command?** Dùng [`sdd-add-field-guide.md`](./sdd-add-field-guide.md).

Tài liệu này là lớp điều hướng thực hành. Contract đầy đủ nằm tại [sdd-add-guide.md](./sdd-add-guide.md), quyết định tech stack nằm tại [architecture-profile-guide.md](./architecture-profile-guide.md), và quy trình nhiều Agent nằm tại [multi-agent-orchestration-guide.md](./multi-agent-orchestration-guide.md).

## 1. Quy tắc không được bỏ qua

1. Đọc `CONSTITUTION.md`, `AGENTS.md`, `.sdd/architecture-profile.md` và `.sdd/constraints/` trước khi thay đổi.
2. Agent đề xuất; Human Director hoặc reviewer được ủy quyền ghi quyết định bền vững bằng `/sdd-review`.
3. `PENDING`, `REVISE`, `REJECTED`, profile `BLOCKED`, hoặc thiếu exact verification command đều là điểm dừng.
4. `CONTEXT.md` và `SPEC.md` có thể technology-neutral. `PLAN.md`, `TASKS.md`, execution và adapter code cần các binding liên quan đã `APPROVED`.
5. Test fail vì rule nghiệp vụ thiếu: cập nhật Spec trước. Test fail vì code trái Spec: sửa code theo Spec.
6. Không tự thêm framework, package, ORM, migration, command, credential hoặc phạm vi ngoài artifact đã duyệt.

## 2. Chọn kịch bản

```text
Bạn đang bắt đầu ở đâu?

Repository mới hoàn toàn
  └─ Kịch bản 1 hoặc 2

Repository đã có source code
  └─ Kịch bản 3

Module legacy cần hiểu trước khi sửa
  └─ Kịch bản 4

Feature mới đã có repository sẵn sàng
  └─ Kịch bản 5

Requirement hoặc public contract thay đổi
  └─ Kịch bản 6

Test/CI thất bại
  └─ Kịch bản 7

Thiếu stack, approval hoặc command
  └─ Kịch bản 8

Cần sửa nhiều layer
  └─ Kịch bản 9

Feature lớn, cần nhiều Agent
  └─ Kịch bản 10

Cần kiểm tra security, SQL hoặc error handling
  └─ Kịch bản 11

Dừng phiên hoặc tiếp tục phiên cũ
  └─ Kịch bản 12

Chỉ đổi tài liệu, skill hoặc governance
  └─ Kịch bản 13 hoặc 14

Muốn vòng lặp tự sửa test có kiểm soát
  └─ Kịch bản 15

Sẵn sàng commit hoặc tạo Pull Request
  └─ Kịch bản 16
```

## 3. Checkpoint chung: Human Final Review

Sau mỗi artifact hoặc report, kiểm tra có block sau:

```markdown
## Human Final Review
- Status: APPROVED | PENDING | REVISE | REJECTED
- Decision: <quyết định cụ thể>
- Reviewer: <người có thẩm quyền>
- Reviewed at: <ISO-8601 có timezone> (mặc định lấy thời gian hiện tại nếu không điền)
- Follow-up: <lệnh hoặc điều kiện tiếp theo>
```

Dùng `/sdd-review`, không sửa thủ công nếu command có thể áp dụng. Ví dụ phê duyệt Context:

```text
/sdd-review --feature=feat-user-register --artifact=context --status=APPROVED --decision="Đã duyệt problem, stakeholders, glossary và constraints; đủ cơ sở lập SPEC." --reviewer="<reviewer>" --reviewed-at="2026-08-24T13:00:00+07:00" --follow-up="/sdd-spec --feature=feat-user-register"
```

`APPROVED` chỉ cho phép bước tiếp theo trong đúng phạm vi `Decision`. Sửa artifact sau approval làm review cũ mất hiệu lực; tạo recommendation và review mới.

## 4. Kịch bản 1 — Greenfield, chưa biết stack

**Dùng khi:** bắt đầu dự án mới nhưng chưa chọn HTTP framework, database, ORM/query layer, validation hoặc command kiểm chứng.

1. Clone template, mở thư mục dự án.
2. Khởi tạo core-only baseline:

   ```text
   /sdd-init --project-name="my-project"
   ```

3. Mở `.sdd/architecture-profile.md`. Xác nhận baseline TypeScript + Node.js + Clean Architecture; các binding chưa chọn phải là `BLOCKED` hoặc `OPTIONAL` đúng ngữ cảnh.
4. Human Director review bootstrap tại `.sdd/reviews/init.md`.
5. Tạo Context cho feature đầu tiên:

   ```text
   /sdd-context --feature=feat-user-register
   ```

6. Review và approve `CONTEXT.md`, rồi tạo Spec:

   ```text
   /sdd-spec --feature=feat-user-register
   ```

7. Review, approve và lock `SPEC.md`.
8. Khi cần lập Plan hoặc code adapter, chuyển sang Kịch bản 2 hoặc 8 để chọn binding.

**Không làm:** gọi `/sdd-plan`, `/sdd-tasks`, `/add-execute` hoặc tạo controller/repository khi profile còn thiếu binding/command cần thiết.

## 5. Kịch bản 2 — Greenfield, đã biết một phần hoặc toàn bộ stack

**Dùng khi:** đã biết stack từ quyết định dự án nhưng chưa có source evidence.

1. Khởi tạo và chỉ nêu điều đã biết:

   ```text
   /sdd-init --project-name="my-project" --stack="Node.js + TypeScript + PostgreSQL"
   ```

2. Kiểm tra profile: input này không tự chọn HTTP framework, ORM, validation, test/build/lint command.
3. Ghi các binding còn thiếu, evidence hoặc Human decision vào `.sdd/architecture-profile.md`.
4. Human Director review profile bằng `/sdd-review --target=.sdd/architecture-profile.md ...`.
5. Chỉ sau `APPROVED`, tạo/duyệt `PLAN.md`, `TASKS.md` và thực thi các task cần binding đó.

**Đầu ra cần có:** profile ghi version, binding, evidence/Human Decision, exact test/build/lint command và review `APPROVED`.

## 6. Kịch bản 3 — Brownfield, tích hợp base vào repository đang có

**Dùng khi:** repository có source, manifest, CI hoặc test hiện hữu.

1. Từ template, sao chép base vào repository đích:

   ```bash
   ./scripts/adopt.sh /path/to/existing-repository
   ```

   Windows PowerShell:

   ```powershell
   .\scripts\adopt.ps1 -TargetPath C:\Projects\existing-repository
   ```

2. Không dùng `--force` hoặc `-Force` nếu chưa kiểm tra và cho phép ghi đè file đích.
3. Mở repository đích, chạy:

   ```text
   /sdd-adopt
   ```

4. Kiểm tra evidence agent tìm được: manifest, lockfile, runtime bootstrap, DB/migration config, CI, test config và source layout.
5. Đối chiếu từng binding trong Architecture Profile với evidence. Conflict phải là `PENDING HUMAN REVIEW`, không chọn theo phỏng đoán.
6. Review report adoption tại `.sdd/reviews/adopt-*.md`; approve scope trước feature work.
7. Chạy Kịch bản 5 cho feature mới, hoặc Kịch bản 4 nếu cần hiểu module legacy.

## 7. Kịch bản 4 — Reverse Spec cho module legacy

**Dùng khi:** cần mô tả behavior hiện tại trước refactor, sửa lỗi hoặc thay thế module.

1. Chọn module và slug feature:

   ```text
   /sdd-adopt --reverse-feature=feat-legacy-auth --path=src/modules/auth
   ```

2. Đọc `CONTEXT.md`, `SPEC.md`, `PLAN.md`, `TASKS.md` được tạo từ quan sát source/test.
3. Kiểm tra mỗi requirement mô tả evidence hiện tại, không biến implementation hiện có thành business decision mặc định.
4. Human owner review: behavior nào giữ, thay đổi hoặc loại bỏ.
5. Chỉ sau approval mới thêm `@ears`, lập task refactor hoặc thực thi.

**Điểm dừng:** Reverse Spec mô tả cái đang có; không chứng minh nó đúng, an toàn hoặc còn phù hợp business.

## 8. Kịch bản 5 — Làm một feature chuẩn từ đầu đến delivery

**Dùng khi:** profile/binding liên quan đã được duyệt, hoặc feature chỉ mới ở pha business-neutral.

1. Tạo Context:

   ```text
   /sdd-context --feature=feat-order-checkout
   ```

2. Human review `CONTEXT.md`, rồi tạo Spec:

   ```text
   /sdd-spec --feature=feat-order-checkout
   /sdd-lint --feature=feat-order-checkout
   ```

3. Human review, approve và lock Spec.
4. Xác nhận Architecture Profile có mọi binding feature cần và exact verification commands.
5. Tạo Plan, review rồi approve:

   ```text
   /sdd-plan --feature=feat-order-checkout
   ```

6. Tạo Tasks, review rồi approve:

   ```text
   /sdd-tasks --feature=feat-order-checkout
   ```

7. Trước **mỗi task**, Agent xuất Shadow Plan; Human xác nhận file scope, profile evidence, command và risk.
8. Thực thi:

   ```text
   /add-execute --feature=feat-order-checkout
   ```

9. Kiểm định:

   ```text
   /sdd-lint --feature=feat-order-checkout
   /sdd-audit --feature=feat-order-checkout
   /sdd-trace --feature=feat-order-checkout
   /sdd-sync
   ```

10. Review execution, audit disposition và sync. Sau đó làm Kịch bản 16.

**Checklist trước execution:** Spec `APPROVED & LOCKED`; Plan/Tasks `APPROVED`; binding/command `APPROVED`; Shadow Plan được xác nhận.

## 9. Kịch bản 6 — Requirement hoặc contract thay đổi

**Dùng khi:** có Spec gap, thêm behavior, sửa condition biên, hoặc thay đổi phá vỡ tương thích.

1. Chọn SemVer:

   | Loại thay đổi | Bump |
   | :--- | :--- |
   | Làm rõ/sửa behavior tương thích | `patch` |
   | Thêm behavior tương thích | `minor` |
   | Phá vỡ API, data hoặc behavior contract | `major` |

2. Cập nhật Spec:

   ```text
   /sdd-update --feature=feat-order-checkout --artifact=spec --bump=patch \
     --reason="[REQ-005] Clarify duplicate payment behavior"
   ```

3. Bổ sung EARS, BDD, error, acceptance, Out of Scope và changelog.
4. Review lại và lock Spec. Approval cũ không còn hợp lệ.
5. Nếu Plan/Tasks bị ảnh hưởng, dùng `/sdd-update --artifact=plan` hoặc `--artifact=tasks` để sửa targeted (hoặc sinh lại với `/sdd-plan`, `/sdd-tasks` nếu thay đổi lớn). Với `major`, có migration plan, rollback plan và risk trước execution.
6. Sau execute, chạy `/sdd-sync` nếu shared contract thay đổi.

**Cập nhật artifact khác không liên quan Spec:**

```text
/sdd-update --feature=feat-order-checkout --artifact=context --reason="Add compliance stakeholder"
/sdd-update --feature=feat-order-checkout --artifact=plan   --reason="Add Redis risk mitigation"
/sdd-update --feature=feat-order-checkout --artifact=tasks  --reason="Add T009 for dedup check"
```

**Không làm:** sửa code để đáp ứng rule chưa có trong Spec, rồi bổ sung Spec sau.

## 10. Kịch bản 7 — Test hoặc CI thất bại

1. Lưu exact output, command, commit/diff và feature bị ảnh hưởng.
2. Phân loại failure:

   | Câu hỏi | Hành động |
   | :--- | :--- |
   | Spec đã mô tả behavior rõ nhưng code sai? | Sửa code theo Spec, rồi chạy lại exact command. |
   | Business rule/edge case chưa có trong Spec? | Dừng sửa code; chuyển sang Kịch bản 6. |
   | Profile/command sai hoặc chưa approved? | Chuyển sang Kịch bản 8. |
   | Có thể là security/data migration? | Escalate Human Director trước execution. |

3. Sau code fix hợp lệ, re-run exact approved command; không thêm filter, skip, mock hoặc biến failure thành warning chỉ để pass.
4. Chạy `/sdd-trace --feature=<slug> --diff` và `/sdd-audit --feature=<slug>` khi code behavior đổi.
5. Review evidence mới trước delivery.

## 11. Kịch bản 8 — Bị block vì thiếu binding, approval hoặc command

**Dấu hiệu:** `CONFIGURATION GAP`, profile `BLOCKED`, review `PENDING`, hoặc task không có exact verification command.

1. Dừng tại artifact hiện tại. Không viết adapter code hay command giả định.
2. Ghi recommendation cần quyết định trong `.sdd/architecture-profile.md`:
   - binding cần chọn;
   - feature/task cần binding;
   - evidence đã kiểm tra;
   - risk nếu tiếp tục;
   - exact command cần được xác nhận.
3. Human Director chọn giá trị và reviewer ghi `APPROVED` bằng `/sdd-review`.
4. Đồng bộ `CLAUDE.md` từ profile approved bằng `/sdd-claude-edit` khi kiến trúc human-readable thay đổi.
5. Sinh lại Plan/Tasks hoặc Shadow Plan bị invalidated, rồi tiếp tục kịch bản phù hợp.

## 12. Kịch bản 9 — Thay đổi xuyên Domain, Usecase, Interface, Infra

**Dùng khi:** một business flow chạm nhiều layer và task/Plan đã approved.

1. Kiểm tra `SPEC.md`, `PLAN.md`, `TASKS.md`, profile và `.sdd/constraints/`.
2. Gọi:

   ```text
   /sdd-layer-edit --feature=feat-order-checkout --action=modify --target=CreateOrder
   ```

3. Xác nhận Shadow Plan trước edit.
4. Giữ dependency direction:
   - `src/domain/`: entity/value object/event thuần TypeScript.
   - `src/usecase/`: business workflow, port và `@ears`.
   - `src/interface/`: transport/DTO/presenter; chỉ gọi usecase.
   - `src/infra/`: DB/cache/external adapter đã approved.
5. Không để controller/interface truy cập DB/repository trực tiếp.
6. Chạy command xác minh approved, trace và audit trước review execution.

## 13. Kịch bản 10 — Feature lớn, dùng nhiều Agent

1. Đọc [multi-agent-orchestration-guide.md](./multi-agent-orchestration-guide.md).
2. Lead kiểm tra profile `APPROVED`, `TASKS.md`, dependency và shared files.
3. Lead xuất Multi-Agent Shadow Plan: batch parallel/sequential, ownership, MCP profile, binding evidence và exact command.
4. Human Director approve Shadow Plan.
5. Giao mỗi Agent task ID và file boundary không chồng lấn. Shared file do Lead xử lý.
6. Mỗi Agent cập nhật `.sdd/shared_context.md` với file đổi, command/result và blocker.
7. Lead kiểm tra API contract và profile compatibility sau mỗi batch.
8. Sau integration, chạy `/sdd-audit`, `/sdd-trace`, `/git-validate --scope=commit`.

**Dừng ngay:** file conflict, API contract cần đổi, binding mismatch hoặc Agent muốn thêm package/adapter ngoài profile.

## 14. Kịch bản 11 — Audit chuyên sâu

### 11.1 API security

```text
/api-security-auditor --feature=feat-order-checkout
```

Dùng khi feature có identity, authorization, PII, request boundary hoặc public API. CRITICAL phải remediation trước delivery.

### 11.2 SQL performance

```text
/sql-performance-tuner --feature=feat-order-checkout --mode=audit
```

Dùng khi feature có query/persistence performance. Cần DB/ORM/query binding đã approved để đưa guidance adapter-specific.

### 11.3 Error handling

```text
/error-handler-pattern --feature=feat-order-checkout --mode=audit
```

Dùng khi error contract, typed error hoặc transport error handling không nhất quán.

Nếu binding chưa chọn, expected result là `CONFIGURATION GAP`, không phải `PASS` hoặc `FAIL` suy đoán.

## 15. Kịch bản 12 — Dừng và tiếp tục phiên

### Dừng giữa chừng

1. Chạy:

   ```text
   /sdd-handoff --feature=feat-order-checkout
   ```

2. Kiểm tra `TASKS.md`:
   - `[x]`: exact verification command pass hoặc `N/A` có lý do;
   - `[/]`: đang làm;
   - `[ ]`: chưa làm.
3. Kiểm tra `Current Handoff State` có file đổi, task tiếp theo, profile/evidence, command/result, blocker và open question.
4. Review recommendation handoff trước khi giao execution cho phiên sau.

### Tiếp tục phiên

```text
/sdd-resume --feature=feat-order-checkout
```

Chỉ gọi `/add-execute` khi task scope, Human Final Review, binding và command đều `APPROVED`.

## 16. Kịch bản 13 — Chỉ thay đổi docs, skill hoặc cấu hình governance

**Dùng khi:** không thay đổi source behavior hoặc public contract.

1. Xác định file có phải `CONSTITUTION.md` không.
2. Nếu không phải Constitution, cập nhật đúng file trong `docs/`, `.claude/skills/`, `AGENTS.md`, `CLAUDE.md` hoặc configuration được phép.
3. Chạy:

   ```text
   /sdd-audit
   /git-validate --scope=commit
   ```

4. `N/A` cho trace/test chỉ hợp lệ khi repository thật sự không có source/test tương ứng và có reason cụ thể.
5. Nếu `READY`, tiếp tục Kịch bản 16.

## 17. Kịch bản 14 — Thay đổi Constitution hoặc kiến trúc governance

**Dùng khi:** cần đổi hard rule, architecture rule hoặc policy bắt buộc.

1. Không sửa trực tiếp `CONSTITUTION.md` sau khi template phát hành.
2. Tạo RFC:

   ```text
   /sdd-rfc --title=soft-delete-policy
   ```

3. Viết motivation, proposed change, alternatives, security/risk, migration và rollback trong RFC được tạo tại `.sdd/rfcs/`.
4. Reviewer có thẩm quyền review durable decision.
5. Chỉ sau approval, Tech Lead gọi:

   ```text
   /sdd-rfc --approve=<rfc-number>
   ```

6. Đồng bộ artifact/profile/docs bị ảnh hưởng, audit rồi delivery.

## 18. Kịch bản 15 — Self-healing test có kiểm soát

**Dùng khi:** exact test command đã approved, failure là code-level và không thuộc DB migration/Spec gap/production incident.

```bash
./scripts/self-heal.sh --test-cmd="<approved test command>" --feature=feat-order-checkout
```

Tùy chọn an toàn:

```bash
./scripts/self-heal.sh --test-cmd="<approved test command>" --max-attempts=2
./scripts/self-heal.sh --test-cmd="<approved test command>" --dry-run
```

1. Script chạy exact command.
2. Pass: dừng; thay đổi, nếu có, vẫn uncommitted để Human review.
3. Fail: phân tích và thử sửa tối đa `--max-attempts` lần; mặc định 3.
4. Cạn lượt: xem incident report tại `.sdd/reviews/self-heal-incident-<timestamp>.md`, rồi escalate Human Director.

**Không dùng:** production, Spec gap, DB schema/migration, profile/command chưa approved, hoặc để bypass review.

## 19. Kịch bản 16 — Commit và Pull Request

1. Kiểm tra diff chỉ chứa intended files, không có secret/credential/PII.
2. Xác nhận tất cả artifact/review, test, audit, trace và sync cần thiết đã có evidence.
3. Validate commit:

   ```text
   /git-validate --scope=commit
   ```

4. Chỉ khi kết quả `READY`, tạo commit:

   ```text
   /git-commit --message="feat(order): add checkout flow"
   ```

5. Trước Pull Request, validate strict theo source diff:

   ```text
   /git-validate --scope=pr --strict
   ```

6. Khi remote validation `READY`, tạo Pull Request:

   ```text
   /git-pr
   ```

`PASS` là kết quả một check. `READY` là quyết định delivery của `/git-validate`; không thay thế bằng lời xác nhận miệng.

## 20. Bảng xử lý nhanh blocker

| Hiện tượng | Không được làm | Việc cần làm |
| :--- | :--- | :--- |
| Profile thiếu HTTP/DB/ORM/test command | Đoán package, command hoặc adapter | Ghi recommendation, lấy Human approval, sinh lại downstream artifact. |
| Spec `DRAFT` hoặc review `PENDING` | Execute code | Hoàn thiện artifact và gọi `/sdd-review`. |
| Test fail do edge case không có trong Spec | Vá code tạm | `/sdd-update`, review/lock Spec, cập nhật Plan/Tasks rồi execute. |
| Test fail do code trái Spec | Đổi requirement để khớp code | Sửa code và chạy lại exact command. |
| Task có file ownership conflict | Để nhiều Agent sửa cùng file | Lead giữ shared file hoặc tách task. |
| Cần DB migration/delete | Chạy tự động không review | Đọc `constraints/safety.md`, có plan/rollback và Human review. |
| Có CRITICAL audit finding | Commit/PR với rationale chung chung | Remediate và audit lại. |
| Git validation chưa `READY` | Commit/PR | Sửa failure/warning hoặc ghi disposition hợp lệ. |

## 21. Tài liệu tham chiếu

- [Hướng dẫn vận hành SDD + ADD](./sdd-add-guide.md)
- [Hướng dẫn Architecture Profile](./architecture-profile-guide.md)
- [Hướng dẫn Multi-Agent Orchestration](./multi-agent-orchestration-guide.md)
- [Constitution](../CONSTITUTION.md)
- [Agent governance](../AGENTS.md)
- [Architecture Profile](../.sdd/architecture-profile.md)
- [Safety constraints](../.sdd/constraints/safety.md)
