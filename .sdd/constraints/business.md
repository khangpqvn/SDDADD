# CONSTRAINT LAYER 2: BUSINESS RULES
# Version: 1.0.0
# Scope: All agents handling business logic — domain, usecase layers
# Reference: Slide 10.4 — 3-Layer Constraint Hierarchy

---

## 1. Authentication Rules

- **JWT expiry**: Access token 15 phút, Refresh token 7 ngày
- **Token rotation**: Refresh token phải được rotate sau mỗi lần dùng (invalidate old)
- **Failed login throttle**: Khóa tài khoản sau 5 lần thất bại liên tiếp trong 15 phút
- **Scope validation**: Mọi endpoint MUST kiểm tra JWT scope/role trước khi xử lý business logic
- **Session revocation**: Logout phải invalidate token trên Redis blacklist (không chỉ client-side delete)

---

## 2. PII Masking Rules

Các trường dữ liệu sau PHẢI được mask trong application logs và error responses:

| Field Type      | Mask Pattern               | Example                       |
| :-------------- | :------------------------- | :---------------------------- |
| Email           | `usr_***@domain.com`       | `usr_***@gmail.com`           |
| Phone           | `***-***-1234`             | `***-***-5678`                |
| Credit Card     | `****-****-****-1234`      | `****-****-****-5678`         |
| Password        | `[REDACTED]`               | —                             |
| JWT Token       | `[TOKEN]`                  | —                             |
| API Key         | `sk-***...{last4}`         | `sk-***...abcd`               |

**Rule**: Logger middleware MUST sanitize request body/headers trước khi ghi log. Không dùng `JSON.stringify(req.body)` raw.

---

## 3. Rate Limiting

| Endpoint Category    | Limit              | Window   | Action on Exceed     |
| :------------------- | :----------------- | :------- | :------------------- |
| Auth (login/signup)  | 10 req             | 1 phút   | 429 + lockout        |
| Public API           | 100 req            | 1 phút   | 429 + retry-after    |
| Authenticated API    | 500 req            | 1 phút   | 429 + log            |
| Admin API            | 200 req            | 1 phút   | 429 + alert          |
| File Upload          | 10 req             | 1 giờ    | 429                  |

- Implement via Redis sliding window counter (không dùng in-memory — lost on restart)
- Rate limit key: `{ip}:{endpoint}` hoặc `{userId}:{endpoint}` cho authenticated users

---

## 4. Soft Delete Rules

- **Mandatory**: Tất cả core business entities (User, Order, Product, etc.) MUST có `deleted_at TIMESTAMP NULL`
- **Query filter**: Mọi repository query PHẢI tự động filter `WHERE deleted_at IS NULL` (default scope)
- **Hard delete**: Chỉ được phép cho non-business data (logs, temp files, audit trails cũ > 7 năm)
- **Cascade**: Soft delete parent entity KHÔNG tự động soft delete children — xử lý explicit từng entity

---

## 5. Business Logic Constraints

- **Idempotency**: Mọi mutation endpoint (POST, PUT, PATCH) phải hỗ trợ `Idempotency-Key` header
- **Optimistic Locking**: Entities có concurrent update risk PHẢI dùng `version` column (+ retry logic)
- **Currency**: Tất cả giá trị tiền tệ lưu dạng integer cents/đồng — KHÔNG dùng float
- **Timezone**: Tất cả timestamps lưu UTC trong DB — convert sang local chỉ ở presentation layer
