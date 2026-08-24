---
name: api-security-auditor
description: Audit API endpoints theo OWASP Top 10 — auth bypass, injection, rate limit, input validation, sensitive data exposure
user-invocable: true
---

# Skill: API Security Auditor (`/api-security-auditor`)

Sử dụng skill này để audit bảo mật toàn bộ API layer theo OWASP Top 10. Đóng gói tri thức Senior Security Engineer.

## Tham số
- `--file=<path>`: Controller/route file cần audit.
- `--feature=<slug>`: Audit toàn bộ feature (đọc từ `.sdd/features/{slug}/`).
- `--owasp=<A01..A10>`: Chỉ kiểm tra một OWASP category cụ thể.

---

## OWASP Top 10 Checklist (API Edition)

### A01 — Broken Access Control
```typescript
// ❌ Missing ownership check
router.get('/orders/:id', authenticate, async (req, res) => {
  const order = await orderRepo.findById(req.params.id); // Bất kỳ user nào cũng lấy được
});

// ✅ Ownership validation
router.get('/orders/:id', authenticate, async (req, res) => {
  const order = await orderRepo.findByIdAndUser(req.params.id, req.user.id);
  if (!order) throw new ForbiddenError('Access denied');
});
```
Kiểm tra: Mọi query lấy resource phải filter theo `userId`/`tenantId`.

### A02 — Cryptographic Failures
- Passwords: PHẢI dùng `bcrypt`/`argon2` (cost factor ≥ 12) — KHÔNG `md5`, `sha1`, `sha256` raw
- JWT: Dùng `RS256` hoặc `ES256` cho production — KHÔNG `HS256` với weak secret
- TLS: Enforce HTTPS, HSTS header, no TLS 1.0/1.1
- Sensitive data: KHÔNG log passwords, tokens, credit cards

### A03 — Injection
```typescript
// ❌ SQL Injection
const user = await db.query(`SELECT * FROM users WHERE email = '${email}'`);

// ✅ Parameterized query
const user = await db.query('SELECT * FROM users WHERE email = $1', [email]);
```
Grep pattern: Tìm template literals trong SQL queries — `\`SELECT.*\${`

### A04 — Insecure Design
- Rate limiting: Có trên auth endpoints? (xem `.sdd/constraints/business.md`)
- Idempotency: POST endpoints có `Idempotency-Key` support?
- Business logic: Không thể mua hàng với số lượng âm? Không thể transfer tiền vượt balance?

### A05 — Security Misconfiguration
```typescript
// Kiểm tra các headers bắt buộc
app.use(helmet()); // X-Frame-Options, X-XSS-Protection, CSP, HSTS
app.use(cors({ origin: process.env.ALLOWED_ORIGINS })); // Không dùng '*' cho production

// KHÔNG expose stack trace trong production
app.use((err, req, res, next) => {
  const safeError = { error_code: err.code, message: err.message, request_id: req.id };
  res.status(err.status || 500).json(safeError); // Không include err.stack
});
```

### A06 — Vulnerable & Outdated Components
- Chạy `npm audit --audit-level=high` — fix HIGH/CRITICAL vulnerabilities
- Grep `package.json` tìm banned packages (theo `.sdd/constraints/global.md`)

### A07 — Identification & Authentication Failures
- Session: Invalidate token sau logout (Redis blacklist)
- Brute force: Rate limit + lockout sau N failures
- Password reset: Token one-time-use, expiry ≤ 15 phút
- 2FA bypass: Verify 2FA code server-side, không trust client claim

### A08 — Software & Data Integrity Failures
- Subresource integrity cho CDN assets
- Verify webhook signatures (`X-Signature-256` header)
- KHÔNG deserialize untrusted data với `eval()` hoặc `Function()`

### A09 — Security Logging & Monitoring Failures
```typescript
// Phải log các events sau (với PII masked — xem business.md):
logger.info('AUTH_SUCCESS', { userId, ip, userAgent });
logger.warn('AUTH_FAILURE', { email: maskEmail(email), ip, attempt });
logger.error('PRIVILEGE_ESCALATION_ATTEMPT', { userId, requestedRole, ip });
```

### A10 — Server-Side Request Forgery (SSRF)
```typescript
// ❌ SSRF risk — user controls URL
const response = await fetch(req.body.webhookUrl);

// ✅ Allowlist validation
const ALLOWED_HOSTS = new Set(['hooks.example.com', 'api.partner.com']);
const url = new URL(req.body.webhookUrl);
if (!ALLOWED_HOSTS.has(url.hostname)) throw new ValidationError('URL not allowed');
```

---

## Output Format

```
🔒 API SECURITY AUDIT REPORT
══════════════════════════════
Feature: {slug} | Scope: {files audited}

🔴 CRITICAL:
  [A01] orders.controller.ts:34 — Missing ownership check on GET /orders/:id
  [A03] user.repository.ts:89 — Potential SQL injection via template literal

🟡 HIGH:
  [A07] auth.controller.ts:120 — No brute-force protection on /auth/login
  [A02] user.service.ts:45 — Password hashed with SHA256 (should use bcrypt)

🟢 PASSED:
  ✓ A05: helmet() và CORS configured correctly
  ✓ A09: Auth events đều có structured logging

📋 REMEDIATION PLAN:
  Priority 1: Fix A01 ownership check (30 min)
  Priority 2: Replace SHA256 with bcrypt (1h + migration)
  Priority 3: Add rate limiting middleware (2h)
```

---

## Integration với SDD

Nếu audit phát hiện design-level security gap:
1. Tạo RFC trong `.sdd/rfcs/` đề xuất thay đổi `CONSTITUTION.md`
2. Cập nhật `.sdd/constraints/business.md` hoặc `safety.md` với rule mới
3. Fix the Spec trước, sau đó re-generate code
