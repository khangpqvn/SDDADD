# Architecture Profile Protocol

Mọi SDD/ADD skill tạo hoặc thay đổi artifact dự án phải dùng protocol này.

## Preflight bắt buộc

1. Đọc `CONSTITUTION.md`, `CLAUDE.md`, `.sdd/architecture-profile.md` và `.sdd/constraints/{global,business,safety}.md`.
2. Kiểm tra repository evidence phù hợp: manifest, lockfile, runtime/bootstrap configuration, DB configuration, migration, CI configuration và source layout.
3. Resolve technology binding theo thứ tự:
   1. `.sdd/architecture-profile.md` đã `APPROVED`.
   2. Repository evidence rõ ràng.
   3. Input explicit của command.
   4. Core-only baseline: TypeScript + Node.js + Clean Architecture.
4. Nếu evidence mâu thuẫn, dừng. Không chọn HTTP framework, database, ORM/query layer, validation library hoặc test/build command.
5. Nếu artifact yêu cầu binding chưa resolve, lưu canonical recommendation `PENDING HUMAN REVIEW` trong profile/artifact đích và yêu cầu Human quyết định cụ thể.

## Quan hệ với Methodology Profile

`Methodology Profile` theo [AI Review Protocol](ai-review-protocol.md) chỉ calibrate depth, risk posture và review route. Nó không thay đổi precedence binding, không tự chọn technology, và không thay thế evidence hoặc exact verification command trong profile.

## Quy tắc artifact

- `CONTEXT.md` và `SPEC.md` có thể tạo với core-only baseline. Reference profile, chỉ ghi binding chưa resolve liên quan feature và giữ requirement framework-/ORM-neutral.
- `PLAN.md`, `TASKS.md`, `/add-execute` và `/sdd-layer-edit` phải dừng khi feature cần HTTP framework, persistence binding, validation library hoặc runnable test/build command chưa resolve.
- Không được tự tạo package name, source adapter, migration, decorator, config file hoặc CLI command.
- Generated path phải khớp Clean Architecture layout và profile binding đã approved.
- Profile approved mất hiệu lực khi manifest/config evidence nền tảng không còn khớp. Tạo recommendation `PENDING HUMAN REVIEW` mới.

## Exact verification command

`PLAN.md`, `TASKS.md`, `/add-execute` và `/sdd-layer-edit` chỉ dùng exact command đã được profile approve; không suy đoán từ package manager hoặc framework.

Khi command đủ điều kiện chạy, profile ghi trong `## Approved verification commands`:

```markdown
- Command: <exact plain executable and arguments>
- Status: APPROVED
- Evidence: <manifest/CI/profile evidence>
```

`scripts/self-heal.sh` chỉ chấp nhận exact `Command` entry từ profile có persisted `Human Final Review: APPROVED`, đồng thời command đó phải khớp task đã approved.

## Output Language

All skill output that reads this protocol must mirror the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`APPROVED`, `PENDING`, `PENDING HUMAN REVIEW`, `CONFIGURATION GAP`, `FAIL`, `PASS`), code identifiers, file paths, and CLI commands are language-invariant.

## Block message bắt buộc

```text
AI RECOMMENDATION: PENDING HUMAN REVIEW
HUMAN DECISION REQUIRED: Select <missing binding(s)> for <feature/task> in .sdd/architecture-profile.md.
EVIDENCE: <files inspected and absence/conflict found>.
NEXT STEP: Record an APPROVED Human Final Review on the architecture profile, then regenerate the affected artifact.
```
