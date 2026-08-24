---
name: error-handler-pattern
description: Chuẩn hóa error handling theo Architecture Profile: typed error, response schema, logging và retry
user-invocable: true
---

# Error Handler Pattern (`/error-handler-pattern`)

Audit hoặc thiết kế error handling theo `CONSTITUTION.md` `ENG-02`.

## Tham số

- `--file=<path>`: File cần audit/fix.
- `--feature=<slug>`: Audit toàn feature.
- `--mode=audit|scaffold`: `audit` phân tích gap; `scaffold` tạo template phù hợp profile.

## Architecture Profile gate

- Core-only được audit error taxonomy và layer boundary.
- HTTP handler, request ID, logger adapter, package import, retry client config và test command chỉ được sinh khi binding `APPROVED` có evidence.
- Binding thiếu thì báo `CONFIGURATION GAP`; không sinh Express, NestJS, Fastify, logger package, test command hoặc retry API suy đoán.

## Quy tắc

- Domain/usecase throw typed error, không import HTTP/transport type.
- Interface map typed error thành response theo approved transport adapter.
- Infra translate provider/DB error tại boundary, không leak driver detail hay stack.
- Khi HTTP binding đã `APPROVED`, response theo `ENG-02` là `{ error_code, message, request_id, timestamp }`; `details` không chứa PII.
- Với event/CLI/transport khác, error contract do `SPEC.md` và binding đã approved xác định; `request_id` chỉ lấy từ request-context mechanism đã approved.
- Retry chỉ ở `src/infra/`, chỉ cho idempotent operation hoặc operation có idempotency guarantee; timeout/backoff phải do Spec/constraint xác định.

## Core template

```typescript
export abstract class AppError extends Error {
  abstract readonly errorCode: string;
  readonly isOperational = true;

  constructor(
    message: string,
    readonly details?: Record<string, unknown>
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}
```

Đặt tại `src/shared/errors/`. Chỉ map `errorCode` sang HTTP/event status ở approved interface adapter.

## Output

```text
ERROR HANDLING AUDIT REPORT
Feature: {slug} | Profile: v{version}
CRITICAL:
  [ENG-02] {path}:{line} — {exposed stack/PII/provider error or missing safe mapping}
WARNING:
  [BOUNDARY|RETRY|LOGGING] {path}:{line} — {finding}
CONFIGURATION GAP:
  {missing binding; framework-specific remediation omitted}
REMEDIATION:
  - Binding: {approved binding or human decision required}
  - Change: {profile-compatible action}
  - Verification: {exact approved command or N/A with reason}
  - Spec/Plan impact: {artifact or N/A}
```

Error code, visible message, retry hoặc idempotency change cần cập nhật `SPEC.md` trước code. Chỉ thay đổi chính `ENG-02` trong `CONSTITUTION.md` mới cần RFC; thay đổi feature dùng `/sdd-review` trước execution.
