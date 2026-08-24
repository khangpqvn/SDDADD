# Hướng dẫn Architecture Profile
# Version: 1.1.0
# Mục đích: Bảo đảm mọi artifact SDD/ADD khớp tech stack đã chọn và Clean Architecture.

> **Chưa quen với SDD+ADD?** Đọc [`sdd-add-quickstart.md`](./sdd-add-quickstart.md) trước.

---

## 1. Nguồn sự thật và thứ tự ưu tiên

`.sdd/architecture-profile.md` là nguồn canonical, machine-readable cho mọi skill tạo hoặc thay đổi artifact. `CLAUDE.md` là bộ nhớ kiến trúc dành cho con người và phải phản ánh profile đã approved.

| Ưu tiên | Nguồn | Cách dùng |
| :--- | :--- | :--- |
| 1 | `.sdd/architecture-profile.md` đã approved | Quyết định canonical cho mọi artifact generation. |
| 2 | Manifest, configuration hoặc source evidence rõ ràng | Evidence khi adopt; giá trị vẫn là draft đến khi review. |
| 3 | Input explicit như `--stack` | Chỉ chọn giá trị được nêu trong command. |
| 4 | Starter baseline | Chỉ TypeScript + Node.js + Clean Architecture. |

Mâu thuẫn giữa các nguồn là configuration blocker. Agent tạo recommendation `PENDING HUMAN REVIEW`; không được tự chọn một bên.

---

## 2. Core-only starter baseline

Repository mới chỉ có các fact đã approved sau:

```text
Language/runtime: TypeScript + Node.js
Architecture: Clean Architecture / Hexagonal
src/domain/     Business entity, value object, domain event thuần TypeScript
src/usecase/    Application workflow và port
src/interface/  HTTP/event adapter, DTO và presenter
src/infra/      Repository, cache và external-service adapter
src/shared/     Error, logger, security và common utility
tests/          Vị trí test suite
```

Baseline không chọn HTTP framework/transport, DB engine, ORM/query layer, validation library, cache/message broker, test/build/lint/coverage/deployment command. Agent không được suy đoán các giá trị này từ tên thư mục template.

Dependency contract vẫn cố định: interface gọi usecase; usecase phụ thuộc domain và port; infra triển khai port; domain không phụ thuộc adapter hoặc third-party package.

---

## 3. Kịch bản vận hành

### 3.1 Greenfield chưa chọn stack

```text
/sdd-init --project-name=my-project
/sdd-context --feature=feat-user-register
/sdd-spec --feature=feat-user-register
```

1. `/sdd-init` tạo profile core-only với binding chưa resolve.
2. `/sdd-context` và `/sdd-spec` tạo business artifact, reference profile và giữ technology-neutral.
3. `/sdd-plan`, `/sdd-tasks`, `/add-execute`, `/sdd-layer-edit` dừng nếu feature cần adapter hoặc verification command chưa resolve.
4. Human Director chọn binding trong profile, rồi ghi `APPROVED` qua `/sdd-review`.

Quyết định cần ghi trong profile:

```text
HTTP framework: <selected framework>
Database: <selected database>
ORM/query layer: <selected ORM or driver>
Validation: <selected library or native approach>
Test command: <exact runnable command>
Build/lint command: <exact runnable command>
```

Không đưa controller framework-specific, ORM decorator, migration syntax hoặc `npm` command vào `PLAN.md`/`TASKS.md` trước approval.

### 3.2 Greenfield có `--stack`

```text
/sdd-init --project-name=my-project --stack="Node.js + TypeScript + <database>"
```

`/sdd-init` chỉ ghi runtime, language và database được nêu. Database không tự chọn HTTP framework, ORM, validation tool hay test command. Profile giữ `DRAFT` đến khi Human Final Review ghi durable decision. Sau approval, Plan/Tasks chỉ dùng binding, path và command đã approved.

### 3.3 Brownfield adoption

```text
/sdd-adopt
/sdd-adopt --stack="<known project stack>"
```

`/sdd-adopt` kiểm tra `package.json`, lockfile, runtime bootstrap, DB/migration config, CI, test config và source layout. Mỗi binding phát hiện phải có evidence trong profile.

Checklist Human review:

- [ ] Mỗi framework/dependency đã chọn có manifest hoặc configuration path làm evidence.
- [ ] Layer mapping phản ánh repository thật, không phải starter default.
- [ ] Mâu thuẫn giữa manifest, source và `--stack` được quyết định explicit.
- [ ] Test/build/lint command đã chạy hoặc được xác nhận là command chính xác.
- [ ] Không binding nào tự thành approved chỉ vì Agent phát hiện nó.

### 3.4 Lập Plan đầu tiên

| Yêu cầu feature | Quyết định profile cần có |
| :--- | :--- |
| HTTP endpoint, route, controller, middleware | HTTP framework/transport và validation approach |
| Store, query, soft-delete, migration | Database và ORM/query layer |
| External API, cache, queue | Client/cache/broker implementation khi dùng |
| Unit/integration/E2E task | Exact test command và test framework |
| Build/lint/CI task | Exact build/lint command |

Khi thiếu binding, Agent xuất:

```text
AI RECOMMENDATION: PENDING HUMAN REVIEW
HUMAN DECISION REQUIRED: Select <missing binding> for <feature> in .sdd/architecture-profile.md.
EVIDENCE: <manifest/config/source paths inspected>.
NEXT STEP: Record APPROVED review on the profile, then rerun /sdd-plan.
```

### 3.5 Đổi stack hoặc binding

1. Cập nhật profile với binding đề xuất, rationale, migration risk, evidence và `PENDING HUMAN REVIEW`.
2. Sau approval, đồng bộ `CLAUDE.md` bằng `/sdd-claude-edit`.
3. Xác định `SPEC.md`, `PLAN.md`, `TASKS.md`, test, CI và adapter code bị ảnh hưởng.
4. Invalidate technical recommendation cũ và sinh lại từ profile đã approved.
5. Dùng `/sdd-update --bump=major` khi public API/data behavior bị breaking; nếu không, chọn SemVer theo behavior.
6. Chỉ chạy migration/test command đã approved trong profile mới.

---

## 4. Quy tắc artifact

| Artifact | Quy tắc |
| :--- | :--- |
| `CONTEXT.md` | Ghi profile reference, baseline, evidence và unknown liên quan feature; mô tả business constraint, không đoán implementation. |
| `SPEC.md` | Giữ EARS, BDD, error code, acceptance và technology-neutral data contract; không dùng ORM decorator, SQL dialect hoặc framework DTO schema chưa chọn. |
| `PLAN.md` | Cần mọi binding feature cần dùng; ghi profile version/evidence, Technology Binding, boundary, data flow và verification command đã chọn. |
| `TASKS.md` | Cần Plan approved và runnable test/build/lint command; mỗi task ghi path, layer, binding, `@ears` và exact command. |
| Shadow Plan | `/add-execute` phải ghi profile version, binding, evidence và command; mismatch thì dừng. |

---

## 5. Technical skill

| Skill | Được làm khi chưa chọn binding | Cần binding đã chọn |
| :--- | :--- | :--- |
| `/api-security-auditor` | Layer boundary, authorization ownership, PII masking, error exposure | Middleware, package/config check, ORM-specific fix |
| `/sql-performance-tuner` | Phát hiện DB access ngoài `src/infra/` | SQL dialect, EXPLAIN, index, migration, ORM query review |
| `/error-handler-pattern` | Typed error trong `src/shared/`, error boundary rule | Exception filter/middleware, request-ID integration, test command |

Khi thiếu adapter binding, skill trả `CONFIGURATION GAP`; không sinh import, package name hoặc command của framework suy đoán.

---

## 6. Multi-Agent và checklist

Lead Agent gửi profile version, binding liên quan, evidence và exact command cho từng sub-agent. Sub-agent không được thêm dependency, adapter, path hoặc command ngoài binding được giao. Conflict quay về Lead rồi Human Director.

- [ ] Profile `APPROVED` cho mọi binding feature dùng.
- [ ] Evidence khớp manifest/config/source.
- [ ] `CLAUDE.md` phản ánh profile đã approved.
- [ ] Context/Spec technology-neutral nếu binding chưa resolve.
- [ ] Plan/Tasks chỉ nêu adapter và command đã approved.
- [ ] Shadow Plan có profile version/evidence.
- [ ] Technical skill báo configuration gap thay vì suy đoán tool.
- [ ] Stack change đã invalidate và sinh lại Plan/Tasks bị ảnh hưởng.
