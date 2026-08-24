---
name: api-security-auditor
description: Audit API theo OWASP, Clean Architecture và Architecture Profile
user-invocable: true
---

# API Security Auditor (`/api-security-auditor`)

Audit API theo OWASP, `CONSTITUTION.md` và Clean Architecture.

## Tham số

- `--file=<path>`: HTTP boundary/controller/adapter cần audit.
- `--feature=<slug>`: Audit toàn feature.
- `--owasp=<A01..A10>`: Chỉ audit một OWASP category.

## Architecture Profile gate

1. Đọc Architecture Profile, governance và evidence liên quan.
2. Core-only check được phép: authorization ownership trong `usecase/`, domain invariant, PII masking, typed error và cấm `interface/` truy cập DB trực tiếp.
3. HTTP middleware, route/config, validation schema, authentication package, DB/ORM remediation, dependency scan command và framework-specific test chỉ dùng khi profile có binding `APPROVED` và evidence.
4. Binding thiếu thì báo `CONFIGURATION GAP`; không sinh import, package name, SQL dialect, ORM API, config file hoặc command suy đoán.

## OWASP checklist theo Clean Architecture

- **A01 Broken Access Control:** Ownership/tenant/role check nằm trong usecase theo `SPEC.md`; interface chỉ chuyển identity đã xác thực.
- **A02 Cryptographic Failures:** Không hardcode/log secret; crypto, token, TLS, key rotation chỉ dùng mechanism approved; mask PII.
- **A03 Injection:** Validate input tại interface boundary; parameterize persistence call trong `src/infra/`; không dùng untrusted interpolation.
- **A04 Insecure Design:** Domain invariant, state transition, idempotency và rate limit khớp EARS/Spec.
- **A05 Security Misconfiguration:** Chỉ audit header, CORS, body limit, debug bypass, TLS/trust proxy sau HTTP binding.
- **A06 Vulnerable Components:** Chỉ chạy exact dependency/security scan command đã approved/evidenced.
- **A07 Authentication Failures:** Signature, expiry, claim, revocation, reset/MFA và brute-force behavior theo Spec/profile.
- **A08 Integrity Failures:** Verify webhook/external payload integrity; validate external data tại boundary; cấm dynamic code execution.
- **A09 Logging Failures:** Security event có correlation, PII masking và logger adapter approved.
- **A10 SSRF:** Validate external URL/protocol/destination theo policy; timeout/redirect/DNS policy dùng client adapter selected.

## Output

```text
API SECURITY AUDIT REPORT
Feature: {slug} | Profile: v{version}

CRITICAL:
  [A01|A03|SEC-01|SEC-02] {path}:{line} — {verified finding and evidence}
HIGH:
  [A02|A04-A10] {path}:{line} — {finding}
CONFIGURATION GAP:
  {missing binding; adapter-specific remediation omitted}
PASSED:
  {verified profile-compatible control}
REMEDIATION:
  - Binding: {approved binding or human decision required}
  - Change: {profile-compatible action}
  - Verification: {exact approved command or N/A with reason}
  - Spec/Plan impact: {artifact or N/A}
```

Nếu finding đổi business behavior, cập nhật `SPEC.md` trước code. Governance change cần RFC. Binding gap phải lưu `PENDING HUMAN REVIEW`; không remediation framework-specific.
