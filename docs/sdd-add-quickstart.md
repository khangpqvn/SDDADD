# Bắt đầu nhanh SDD + ADD

Tài liệu này là đường đi chính để đưa một feature từ ý tưởng đến delivery có evidence. Không nhảy bước: mỗi pha chỉ mở route tiếp theo sau khi gate ngay trước đó đã được ghi bền vững.

## Bản đồ một dòng

```text
bootstrap → CONTEXT → Human review → SPEC → lint/review/lock
→ Architecture Profile → PLAN → Human review → TASKS → Human review
→ /add-execute → validation/review → /git-validate → Human delivery
```

- Repository mới: `/sdd-init`.
- Repository đã có code: chạy `scripts/adopt.sh` hoặc `scripts/adopt.ps1`, sau đó `/sdd-adopt`.
- Starter persist `Project Ownership: team` và `Agent Execution: direct` trong `.sdd/shared_context.md`, nên không phụ thuộc worker runtime. Route đã persist không bị đổi ngầm: chỉ đổi khi Human sửa shared context và review. `orchestrated` chỉ dùng khi đã được persist explicit và runtime capability đã được observed; unavailable là `BLOCKED`, không fallback.
- `/add-execute` là public execution entry point duy nhất. Governance editor, audit và recovery route không cấp execution grant.

## Bước 0 — Chọn bootstrap route

### Repository mới hoặc chưa có governance

```text
/sdd-init --project-name="<name>"
```

**Input:** tên dự án và, nếu đã biết, stack explicit có evidence.
**Output:** `AGENTS.md`, `CLAUDE.md`, `.sdd/architecture-profile.md`, `.sdd/shared_context.md`, `.sdd/reviews/init.md` và cấu trúc template.
**Gate:** Human review `APPROVED` cho `.sdd/reviews/init.md`.
**Dừng khi:** stack hoặc verification command mâu thuẫn/thiếu evidence. Không đoán framework, database hay test command.
**Tiếp theo:** `/sdd-context --feature=<slug>` sau persisted `APPROVED`.
**Không được:** chạy `/sdd-plan`, `/sdd-tasks` hoặc `/add-execute` ngay sau bootstrap.

### Repository đã có source

```bash
scripts/adopt.sh <target-repository>
```

Windows PowerShell:

```powershell
.\scripts\adopt.ps1 -TargetPath <target-repository>
```

Sau đó, trong repository đích:

```text
/sdd-adopt
```

**Input:** manifest, lockfile, runtime, CI, test/build config và source layout thật.
**Output:** `.sdd/reviews/adopt-<slug>.md` và Architecture Profile có evidence/conflict.
**Gate:** Human review adoption và Profile trước feature work.
**Dừng khi:** evidence conflict hoặc binding chưa rõ.
**Tiếp theo:** `/sdd-context --feature=<slug>` chỉ khi Follow-up đã persist.
**Không được:** dùng reverse-spec như business approval hoặc overwrite source ngoài adoption scope.

## Bước 1 — Chốt ngữ cảnh (`CONTEXT`)

```text
/sdd-context --feature=<slug>
```

**Mục tiêu:** chốt WHAT, WHY, Definition of Done, boundary, exclusions, glossary và decision owner; chưa chọn HOW.
**Output:** `.sdd/features/<slug>/CONTEXT.md`.
**Gate:** `Human Final Review.Status: APPROVED` với decision, reviewer và timestamp.
**Dừng khi:** Describe-back mâu thuẫn, material question chưa disposition, hoặc Agent tự thêm technology.
**Tiếp theo:** `/sdd-spec --feature=<slug>`.
**Không được:** tự approve hoặc viết Spec khi Context còn `PENDING`.

Human ghi review bằng lệnh có giá trị thật:

```text
/sdd-review --feature=<slug> --artifact=context --status=APPROVED --decision="<decision>" --reviewer="<authorized human>" --follow-up="/sdd-spec --feature=<slug>"
```

## Bước 2 — Viết behavior (`SPEC`)

```text
/sdd-spec --feature=<slug>
/sdd-lint --feature=<slug>
```

**Input:** Context đã `APPROVED`.
**Output:** `.sdd/features/<slug>/SPEC.md` với EARS, acceptance, error contract, Out of Scope, Feature Lock và recommendation.
**Gate:** Clarification-First hoàn tất, lint không còn blocker, Human `APPROVED`; Spec chuyển `APPROVED & LOCKED`.
**Dừng khi:** business rule, NFR hoặc edge case cần Human quyết định; không dùng assumption chưa ghi.
**Tiếp theo:** `/sdd-plan --feature=<slug>` sau review/lock.
**Không được:** thêm framework/ORM/command vào Spec, sửa code để né Spec gap, hoặc gọi Plan trước khi lock.

```text
/sdd-review --feature=<slug> --artifact=spec --status=APPROVED --decision="<decision>" --reviewer="<authorized human>" --follow-up="/sdd-plan --feature=<slug>"
```

## Bước 3 — Xác nhận Architecture Profile

Đọc `.sdd/architecture-profile.md` trước khi lập Plan.

```text
/sdd-review --target=.sdd/architecture-profile.md --status=APPROVED --decision="<approved bindings and exact commands>" --reviewer="<authorized human>" --follow-up="/sdd-plan --feature=<slug>"
```

**Gate:** mọi binding cần cho feature và exact verification command phải có `APPROVED` evidence. Starter core-only profile có thể giữ HTTP/DB/test/build ở `BLOCKED` nếu feature không cần chúng.
**Dừng khi:** feature cần binding hoặc command chưa chọn. Cập nhật Profile và review lại; không đoán `npm test`, framework, DB hoặc ORM.
**Tiếp theo:** `/sdd-plan --feature=<slug>`.
**Không được:** dùng `N/A` để che một command cần thiết cho source behavior.

## Bước 4 — Lập thiết kế (`PLAN`)

```text
/sdd-plan --feature=<slug>
```

**Input:** Spec `APPROVED & LOCKED`, Profile evidence và constraints.
**Output:** `.sdd/features/<slug>/PLAN.md` với mapping `REQ-XXX`, component/path, data flow, state-change, contract, risk và exact command.
**Gate:** Human `APPROVED`.
**Dừng khi:** unresolved technical question, missing binding/command hoặc Plan đưa deferred scope vào implementation.
**Tiếp theo:** `/sdd-tasks --feature=<slug>`.
**Không được:** tự chọn adapter, đổi depth, hoặc lập task từ Plan chưa review.

```text
/sdd-review --feature=<slug> --artifact=plan --status=APPROVED --decision="<decision>" --reviewer="<authorized human>" --follow-up="/sdd-tasks --feature=<slug>"
```

## Bước 5 — Chia task (`TASKS`)

```text
/sdd-tasks --feature=<slug>
```

**Input:** Plan đã `APPROVED`.
**Output:** `.sdd/features/<slug>/TASKS.md`, mỗi task có `REQ-XXX`, boundary, owner, dependency, checkpoint, exact command, sizing và post-code route.
**Gate:** Human `APPROVED` cho Tasks.
**Dừng khi:** task thiếu boundary/command/owner, vượt Feature Lock, hoặc cần exception chưa được Human approve.
**Tiếp theo:** `/add-execute --feature=<slug> --task=<T001>` hoặc `--all`.
**Không được:** sửa code trực tiếp từ TASKS chưa approved hoặc tự cấp execution grant.

```text
/sdd-review --feature=<slug> --artifact=tasks --status=APPROVED --decision="<decision>" --reviewer="<authorized human>" --follow-up="/add-execute --feature=<slug> --all"
```

## Bước 6 — Thực thi qua một entry point

Chạy một task:

```text
/add-execute --feature=<slug> --task=<T001>
```

Chạy snapshot eligible:

```text
/add-execute --feature=<slug> --all
```

`/add-execute` tự resolve `direct|orchestrated` từ `.sdd/shared_context.md`, preflight toàn bộ selection, tạo Execution Record/grant, consume grant trước action, yêu cầu Shadow Plan/checkpoint, sửa đúng boundary và ghi Action Record. Route `orchestrated` mà runtime worker không available là `BLOCKED`; không fallback sang `direct`.

**Dừng khi:** review, dependency, contract, Profile, command, checkpoint, grant, runtime hoặc scope evidence không hợp lệ.
**Tiếp theo:** exact approved command trong Task, rồi validation route được trigger.
**Không được:** truyền `--agent-execution`, `--project-ownership`, `--dispatch-*`, reuse grant consumed, dùng command đoán hoặc gọi skill editor để né `/add-execute`.

## Bước 7 — Validation và delivery

Sau mỗi execution, theo trigger của Task:

```text
<exact approved command>
/sdd-lint --feature=<slug>                 # khi Spec thay đổi
/sdd-audit --feature=<slug>                # khi source/governance/contract thay đổi
/sdd-trace --feature=<slug> --diff         # khi requirement/code/test liên quan
/sdd-sync --feature=<slug> --reason="<reason>"  # khi registry/shared contract đổi
/git-validate --scope=commit --feature=<slug>
```

**Gate:** Action Record đủ, post-code review `APPROVED` khi trigger áp dụng, và `GIT VALIDATION: READY`.
**Dừng khi:** command fail, report thiếu, residual blocker hoặc review pending. Phân loại implementation defect, Spec gap hay Profile gap trước khi sửa.
**Tiếp theo:** Human yêu cầu `/git-commit`; sau commit Human tự delivery remote.
**Không được:** đổi exact command để tạo PASS, commit trước `READY`, hoặc Agent `git push`.

## Route phụ có điều kiện

### Requirement/Plan/Task đã approved nhưng phải đổi

```text
/sdd-update --feature=<slug> --artifact=<context|spec|plan|tasks> --bump=<patch|minor|major> --reason="<reason>"
```

`--bump` bắt buộc khi `--artifact=spec`; với `context`, `plan` và `tasks` thì không cần. Chọn bump theo mức tương thích ngược trong [contract của skill](../.claude/skills/sdd-update/SKILL.md).

Update phải tạo Change Impact Record, invalidate approval bị ảnh hưởng và dừng downstream cho tới review mới. Không chạy lại `/sdd-context` hoặc sửa code để né update.

### Session bị ngắt

```text
/sdd-handoff --feature=<slug>
# phiên sau
/sdd-resume --feature=<slug>
```

Handoff/resume chỉ lưu và khôi phục context. Chúng không cấp grant, không approve và không reuse grant cũ. Chỉ gọi `/add-execute ... --resume` sau revalidation.

### Thay đổi Constitution hoặc hard architecture rule

```text
/sdd-rfc --title=<short-title>
```

Chỉ Tech Lead/Human Director có thẩm quyền approve RFC. Không sửa `CONSTITUTION.md` trực tiếp.

### Cập nhật governance/project memory

Dùng `/sdd-agents-edit` hoặc `/sdd-claude-edit` theo review contract riêng. Các route này không thay thế feature pipeline và không cấp execution authority.

## Khi bị block

| Blocker | Hành động đúng | Shortcut bị cấm |
| :--- | :--- | :--- |
| Thiếu review | Dùng `/sdd-review` với decision thật | Duyệt bằng chat hoặc tự đổi status |
| Thiếu Profile/command | Bổ sung evidence, review Profile | Đoán package/command |
| Spec gap | `/sdd-update` rồi review/lock | Patch code trước |
| Contract/boundary drift | Dừng, để owner/Lead resolve, trace/sync | Tiếp tục absorb scope |
| Thiếu checkpoint | Persist Human checkpoint `APPROVED` | Làm material change trước |
| Grant consumed/mismatch | Revalidate qua `/add-execute` | Reset/reuse token |
| Orchestrated runtime unavailable | Resolve runtime hoặc đổi persisted route explicit | Fallback direct ngầm |
| Validation fail | Giữ exact result, phân loại nguyên nhân | Đổi command để tạo PASS |

## Khi không dùng full SDD

R&D/throwaway/prototype có thể ghi hypothesis và điều kiện dừng. Khi code được giữ lại hoặc có behavior/contract material, phải quay lại `CONTEXT → SPEC → PLAN → TASKS` trước khi mở rộng hoặc delivery.
