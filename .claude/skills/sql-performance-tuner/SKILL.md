---
name: sql-performance-tuner
description: Phân tích và tối ưu SQL queries — EXPLAIN ANALYZE, index strategy, N+1 detection, slow query review
user-invocable: true
---

# Skill: SQL Performance Tuner (`/sql-performance-tuner`)

Sử dụng skill này để phân tích, phát hiện và tối ưu SQL queries trong codebase. Đóng gói tri thức Senior DBA.

## Tham số
- `--file=<path>`: File cần audit (repository, migration, query file).
- `--query=<sql>`: SQL query cụ thể cần phân tích.
- `--mode=audit|fix|index`: `audit` (phân tích), `fix` (đề xuất sửa), `index` (thiết kế indexes).

---

## Checklist Phân Tích (Chạy theo thứ tự)

### 1. N+1 Query Detection
Dấu hiệu N+1 trong code:
```typescript
// ❌ N+1: Loop với query bên trong
for (const order of orders) {
  const items = await itemRepo.findByOrderId(order.id); // N queries
}

// ✅ Fix: JOIN hoặc IN clause
const items = await itemRepo.findByOrderIds(orders.map(o => o.id)); // 1 query
```

Phát hiện pattern: Grep tìm `await` bên trong `for`, `.forEach`, `.map` có async callback.

### 2. Missing Index Analysis
Indexes BẮT BUỘC cho:
- Foreign key columns (`user_id`, `order_id`, `*_id`)
- Columns trong `WHERE` clause thường xuyên
- Columns trong `ORDER BY` + `LIMIT` (pagination)
- Compound index cho queries có multiple WHERE conditions

```sql
-- Kiểm tra query plan
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM orders WHERE user_id = $1 AND status = $2 ORDER BY created_at DESC LIMIT 20;
-- Nếu thấy "Seq Scan" trên bảng lớn → cần index
```

### 3. Slow Query Patterns (Phát hiện và sửa)

| Pattern                        | Vấn đề                         | Fix                                  |
| :----------------------------- | :----------------------------- | :----------------------------------- |
| `SELECT *`                     | Over-fetching columns          | Chọn đúng columns cần dùng           |
| `LIKE '%keyword%'`             | Full table scan                | Dùng Full-Text Search hoặc pg_trgm   |
| `ORDER BY rand()`              | Filesort toàn bảng             | Keyset pagination                    |
| `NOT IN (subquery)`            | Correlated subquery            | `NOT EXISTS` hoặc `LEFT JOIN IS NULL`|
| `COUNT(*)` trên table lớn      | Expensive aggregation          | Materialized view hoặc counter table |
| Implicit type cast trong WHERE | Index skip                     | Cast explicit hoặc đúng type         |

### 4. Pagination Anti-patterns
```sql
-- ❌ Offset pagination chậm ở trang sau
SELECT * FROM orders ORDER BY id LIMIT 20 OFFSET 10000;

-- ✅ Keyset pagination (cursor-based)
SELECT * FROM orders WHERE id > :last_seen_id ORDER BY id LIMIT 20;
```

### 5. Transaction & Lock Analysis
- Detect long transactions: queries nằm trong transaction scope không cần thiết
- Identify lock contention: `SELECT FOR UPDATE` scope quá rộng
- Deadlock patterns: Kiểm tra thứ tự acquire locks nhất quán

---

## Output Format

```
📊 SQL PERFORMANCE AUDIT REPORT
═══════════════════════════════

🔴 CRITICAL (Fix ngay):
  [N+1] order-repository.ts:45 — N+1 query trong loop fetchItems
  [INDEX] Missing index on orders.user_id + status (Seq Scan)

🟡 WARNING (Plan to fix):
  [SLOW] SELECT * dùng ở 3 chỗ — over-fetching columns
  [PAGINATE] Offset pagination ở orders-list — slow at page > 500

🟢 OK:
  ✓ Foreign keys đều có indexes
  ✓ Compound index cho search queries

📋 INDEX RECOMMENDATIONS:
  CREATE INDEX CONCURRENTLY idx_orders_user_status
    ON orders(user_id, status) WHERE deleted_at IS NULL;
```

---

## Integration với SDD

Sau khi audit, nếu phát hiện query pattern phải thay đổi thiết kế schema:
1. **Fix the Spec, NOT the Code** — cập nhật PLAN.md hoặc SPEC.md của feature tương ứng
2. Tạo migration file với index `CONCURRENTLY` (không lock production)
3. Gắn `@ears SPEC.md#PERF-XXX` vào optimized query
