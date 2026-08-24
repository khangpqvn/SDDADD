# Architecture Profile
# Version: 1.0.0
# Status: DRAFT
# Mục đích: Nguồn sự thật tech stack và kiến trúc canonical cho artifact do SDD/ADD sinh ra.

---

## 1. Thứ tự chọn binding

Skill resolve quyết định công nghệ theo thứ tự:

1. Profile này khi `Status: APPROVED`.
2. Repository evidence rõ ràng: manifest, lockfile, runtime config, source layout.
3. Input explicit của command, ví dụ `/sdd-init --stack="..."`.
4. Core-only starter baseline bên dưới.

Mâu thuẫn giữa các nguồn là **blocking configuration gap**. Skill phải lưu AI recommendation và yêu cầu Human Director quyết định; không được chọn một bên hoặc sinh artifact adapter-specific.

---

## 2. Baseline đã approved

| Mối quan tâm | Giá trị đã chọn | Status | Evidence |
| :--- | :--- | :--- | :--- |
| Ngôn ngữ | TypeScript | APPROVED | `CLAUDE.md` §2.1, `src/` layout |
| Runtime | Node.js | APPROVED | Core-only baseline |
| Kiến trúc | Clean Architecture / Hexagonal | APPROVED | `CLAUDE.md` §2.1, `CONSTITUTION.md` ARCH-01 |
| Domain layer | `src/domain/` — TypeScript thuần, không third-party dependency | APPROVED | `CLAUDE.md` §2.1 |
| Use-case layer | `src/usecase/` — application workflow và port | APPROVED | `CLAUDE.md` §2.1 |
| Interface layer | `src/interface/` — HTTP/event adapter, DTO, presenter | APPROVED | `CLAUDE.md` §2.1 |
| Infrastructure layer | `src/infra/` — repository, cache, external adapter | APPROVED | `CLAUDE.md` §2.1 |
| Shared layer | `src/shared/` — logging, security, common utility | APPROVED | `CLAUDE.md` §2.1 |
| Vị trí test | `tests/` | APPROVED | Repository layout |

---

## 3. Technology binding

| Mối quan tâm | Giá trị đã chọn | Status | Evidence / Human Decision |
| :--- | :--- | :--- | :--- |
| HTTP framework / transport | Chưa chọn | BLOCKED | Không có `package.json`, application bootstrap hoặc Human decision |
| Database engine | Chưa chọn | BLOCKED | Không có DB config, migration hoặc Human decision |
| ORM / query layer | Chưa chọn | BLOCKED | Không có dependency manifest hoặc Human decision |
| Cache | Chưa chọn | OPTIONAL | Chỉ chọn khi feature cần caching |
| Message broker | Chưa chọn | OPTIONAL | Chỉ chọn khi `SPEC.md` có async/reliability requirement cần broker và Human decision |
| Validation library | Chưa chọn | BLOCKED khi lập kế hoạch interface validation | Không có dependency manifest hoặc Human decision |
| Test framework / command | Chưa chọn | BLOCKED trước executable task | Không có `package.json`, script hoặc Human decision |
| Build / lint command | Chưa chọn | BLOCKED trước executable task | Không có `package.json`, CI config hoặc Human decision |
| Deployment environment | Chưa chọn | OPTIONAL | Chỉ chọn khi lập kế hoạch deployment architecture |

---

## 4. Artifact generation gate

| Artifact / skill | Có thể dùng core-only baseline? | Điều kiện |
| :--- | :--- | :--- |
| `CONTEXT.md` / `/sdd-context` | Có | Reference profile, chỉ ghi unknown liên quan feature. |
| `SPEC.md` / `/sdd-spec` | Có | Requirement technology-neutral; không dùng ORM decorator hoặc framework schema. |
| `PLAN.md` / `/sdd-plan` | Không, nếu feature cần HTTP, persistence, validation hoặc test command | Binding bắt buộc phải được chọn và có evidence. |
| `TASKS.md` / `/sdd-tasks` | Không | Cần Plan approved và test/build command đã chọn. |
| `/add-execute`, `/sdd-layer-edit` | Không | Cần binding đã chọn và verification command runnable. |
| Technical skill adapter guidance | Không, nếu adapter-specific | Báo `CONFIGURATION GAP`; chỉ đưa ra architecture check framework-neutral. |

---

## 5. Quyết định bắt buộc khi bị block

```markdown
## AI Agent Recommendation
- Status: PENDING HUMAN REVIEW
- Scope: `.sdd/architecture-profile.md` — <feature or requested task>
- Recommendation: Select <HTTP framework / database / ORM / test command> before technical planning or execution.
- Evidence: <files checked and no/conflicting evidence found>
- Risks and assumptions: Generating framework-specific files or commands now would be speculative.
- Alternatives considered: <supported stack options relevant to the project>
- Required human decision: Approve exact technology binding(s) and verification command(s).

## Human Final Review
- Status: PENDING
- Decision:
- Reviewer:
- Reviewed at:
- Follow-up:
```

Dùng `/sdd-review --target=.sdd/architecture-profile.md ...` để ghi approval. Sau approval, cập nhật `PLAN.md` và `TASKS.md` bị ảnh hưởng; technical recommendation cũ mất hiệu lực.

---

## 6. Governance liên quan

- `CONSTITUTION.md` là thẩm quyền cho hard security và architecture constraint.
- `CLAUDE.md` là bộ nhớ kiến trúc dành cho con người; phải phản ánh profile đã approved.
- `.sdd/constraints/` quản lý global, business và safety constraint. Constraint chỉ áp dụng adapter-specific khi Architecture Profile đã chọn binding tương ứng.
- `.sdd/mcp-config.yaml` kiểm soát quyền tool, không chọn công nghệ.

---

## AI Agent Recommendation
- Status: PENDING HUMAN REVIEW
- Scope: `.sdd/architecture-profile.md` — starter-template baseline
- Recommendation: Approve the TypeScript + Node.js + Clean Architecture baseline and select HTTP framework, database, ORM/query layer, validation, test, build, and lint commands before implementation planning.
- Evidence: Repository has only Clean Architecture placeholder directories; no `package.json`, lockfile, runtime bootstrap, database config, or test runner.
- Risks and assumptions: Adapter-specific PLAN, TASKS, source code, and commands would otherwise be unsupported assumptions.
- Alternatives considered: Keep the template core-only; select bindings per project during `/sdd-init` or `/sdd-adopt`.
- Required human decision: Approve this profile and provide the bindings required for the first implementation feature.

## Human Final Review
- Status: PENDING
- Decision:
- Reviewer:
- Reviewed at:
- Follow-up:
