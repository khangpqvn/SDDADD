---
name: sql-performance-tuner
description: Audit hiệu năng persistence adapter theo Architecture Profile, gồm N+1, index/query-plan gap và layer violation
user-invocable: true
---

# SQL Performance Tuner (`/sql-performance-tuner`)

Audit persistence performance cho TypeScript + Node.js + Clean Architecture. Chỉ `src/infra/` được truy cập DB; DB/ORM call trong domain, usecase hoặc interface là `ARCH-01` violation.

## Tham số

- `--file=<path>`: Persistence adapter cần audit, phải thuộc `src/infra/`.
- `--query=<sql>`: Query cần phân tích; chỉ dùng dialect-specific analysis khi DB đã approved.
- `--mode=audit|fix|index`: `audit` phân tích, `fix` tạo recommendation, `index` thiết kế index theo DB approved.

## Architecture Profile gate

1. Đọc Architecture Profile, Constitution, CLAUDE và constraints.
2. Xác minh DB, ORM/query layer, migration mechanism và test command đã `APPROVED` cùng evidence.
3. DB/ORM chưa chọn thì chỉ audit layer boundary và báo `CONFIGURATION GAP`; không sinh SQL dialect, index syntax, migration, ORM method, package name hoặc command suy đoán.
4. Binding đã chọn thì chỉ dùng syntax/API/command của binding đó.

## Checklist

- Không có DB client/query builder/ORM import ngoài `src/infra/`; usecase chỉ phụ thuộc port.
- Không có database call trong loop khi selected adapter có batch loading, join, relation loading hoặc `IN` query phù hợp.
- Chỉ review query plan, index, filter, join, sort, pagination, deletion/soft-delete strategy và migration sau khi DB binding được chọn; soft-delete chỉ áp dụng khi `SPEC.md` và persistence binding đã xác định.
- Không `SELECT *` nếu usecase cần ít field; parameterize input; transaction scope nhỏ; lock order nhất quán.
- Production index/schema change cần safety constraint, rollback plan và Human Final Review.

## Output

```text
PERSISTENCE PERFORMANCE AUDIT REPORT
Feature: {slug} | Profile: v{version} | Binding: {approved database + ORM/query layer}

LAYER VIOLATION:
  [ARCH-01] {path}:{line} — {DB access outside src/infra}
CRITICAL:
  [N+1|INDEX|LOCK] {path}:{line} — {evidence and impact}
WARNING:
  [QUERY|PAGINATION|PROJECTION] {path}:{line} — {finding}
CONFIGURATION GAP:
  {unselected binding; no adapter-specific remediation generated}
REMEDIATION:
  - Binding: {approved binding}
  - Change: {profile-compatible action}
  - Verification: {exact approved command or N/A with reason}
  - Spec/Plan impact: {artifact or N/A with reason}
```

Nếu performance change đổi data contract, consistency, SLA hoặc schema behavior, cập nhật `SPEC.md`/`PLAN.md` trước code. Dùng `/sdd-review` cho profile/schema decision trước execution.
