---
name: error-handler-pattern
description: Chuẩn hóa error handling — typed errors, unified HTTP response schema, logging strategy, retry logic
user-invocable: true
---

# Skill: Error Handler Pattern (`/error-handler-pattern`)

Sử dụng skill này để chuẩn hóa error handling toàn codebase theo `ENG-02` trong `CONSTITUTION.md`. Đóng gói tri thức Senior Engineer về error design.

## Tham số
- `--file=<path>`: File cần audit/fix error handling.
- `--feature=<slug>`: Audit toàn bộ feature.
- `--mode=audit|scaffold`: `audit` (phân tích gaps), `scaffold` (tạo error class template).

---

## 1. Error Taxonomy (Phân loại lỗi)

| Error Type           | HTTP Code | Retry?  | Log Level | Example                          |
| :------------------- | :-------- | :------ | :-------- | :------------------------------- |
| `ValidationError`    | 400       | No      | `warn`    | Invalid email format             |
| `AuthenticationError`| 401       | No      | `warn`    | JWT expired / missing            |
| `ForbiddenError`     | 403       | No      | `warn`    | Insufficient permissions         |
| `NotFoundError`      | 404       | No      | `info`    | Resource not found               |
| `ConflictError`      | 409       | No      | `warn`    | Duplicate email / idempotency    |
| `RateLimitError`     | 429       | Yes     | `warn`    | Too many requests                |
| `ExternalServiceError`| 502/503  | Yes     | `error`   | Payment gateway timeout          |
| `InternalError`      | 500       | No      | `error`   | Unhandled exception              |

---

## 2. Unified Error Response Schema (ENG-02)

Mọi error response PHẢI tuân thủ schema sau (không expose stack trace cho client):

```typescript
// ✅ Standard error response
{
  "error_code": "VALIDATION_FAILED",   // Machine-readable code
  "message": "Email is invalid",        // Human-readable, safe to show
  "request_id": "req_abc123",          // Tracing ID
  "timestamp": "2026-08-24T08:00:00Z", // ISO 8601 UTC
  "details": [                          // Optional: field-level errors
    { "field": "email", "issue": "Invalid format" }
  ]
}
```

---

## 3. Typed Error Base Classes (Template)

```typescript
// src/shared/errors/base-error.ts

export abstract class AppError extends Error {
  abstract readonly statusCode: number;
  abstract readonly errorCode: string;
  readonly isOperational: boolean = true; // vs programmer errors

  constructor(
    message: string,
    readonly details?: Record<string, unknown>
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  readonly statusCode = 400;
  readonly errorCode = 'VALIDATION_FAILED';
}

export class AuthenticationError extends AppError {
  readonly statusCode = 401;
  readonly errorCode = 'AUTHENTICATION_REQUIRED';
}

export class ForbiddenError extends AppError {
  readonly statusCode = 403;
  readonly errorCode = 'FORBIDDEN';
}

export class NotFoundError extends AppError {
  readonly statusCode = 404;
  readonly errorCode = 'NOT_FOUND';
}

export class ConflictError extends AppError {
  readonly statusCode = 409;
  readonly errorCode = 'CONFLICT';
}

export class ExternalServiceError extends AppError {
  readonly statusCode = 502;
  readonly errorCode = 'EXTERNAL_SERVICE_FAILED';
  readonly isOperational = false; // Trigger alert
}
```

---

## 4. Global Error Handler Middleware

```typescript
// src/interface/middleware/global-error-handler.ts

import { Request, Response, NextFunction } from 'express';
import { AppError } from '@/shared/errors/base-error';
import { logger } from '@/shared/logger';

export function globalErrorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  const requestId = req.id as string;

  if (err instanceof AppError) {
    // Operational error — expected, safe to send details
    logger[err.statusCode >= 500 ? 'error' : 'warn']({
      event: 'OPERATIONAL_ERROR',
      errorCode: err.errorCode,
      message: err.message,
      requestId,
      path: req.path,
    });

    res.status(err.statusCode).json({
      error_code: err.errorCode,
      message: err.message,
      request_id: requestId,
      timestamp: new Date().toISOString(),
      ...(err.details && { details: err.details }),
    });
    return;
  }

  // Programmer error — never expose internals
  logger.error({
    event: 'UNHANDLED_ERROR',
    error: err.message,
    stack: err.stack, // Log stack server-side only
    requestId,
    path: req.path,
  });

  res.status(500).json({
    error_code: 'INTERNAL_SERVER_ERROR',
    message: 'An unexpected error occurred. Please try again later.',
    request_id: requestId,
    timestamp: new Date().toISOString(),
  });
}
```

---

## 5. Retry Logic Pattern (cho External Services)

```typescript
// src/shared/utils/retry-with-backoff.ts

interface RetryOptions {
  maxAttempts?: number;   // Default: 3
  baseDelayMs?: number;   // Default: 500ms
  maxDelayMs?: number;    // Default: 5000ms
  shouldRetry?: (err: Error) => boolean;
}

export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  opts: RetryOptions = {}
): Promise<T> {
  const { maxAttempts = 3, baseDelayMs = 500, maxDelayMs = 5000 } = opts;
  const shouldRetry = opts.shouldRetry ?? ((err) => err instanceof ExternalServiceError);

  let lastError: Error;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (err) {
      lastError = err as Error;
      if (attempt === maxAttempts || !shouldRetry(lastError)) throw lastError;
      const delay = Math.min(baseDelayMs * 2 ** (attempt - 1), maxDelayMs);
      await new Promise((r) => setTimeout(r, delay)); // Exponential backoff
    }
  }
  throw lastError!;
}
```

---

## 6. Audit Checklist

- [ ] Tất cả `throw new Error()` đã được thay bằng typed `AppError` subclass
- [ ] Global error handler đăng ký là middleware cuối cùng
- [ ] KHÔNG có `try/catch` nuốt lỗi mà không log hoặc re-throw
- [ ] KHÔNG expose `err.stack` trong HTTP response
- [ ] External service calls đều có retry + timeout
- [ ] Error codes nhất quán, dùng được cho i18n translation

---

## Output Format

```
⚠️  ERROR HANDLING AUDIT REPORT
═══════════════════════════════
🔴 MISSING:
  - orders.service.ts:67 — throw new Error('not found') → dùng NotFoundError
  - payment.service.ts:134 — Swallowed catch: catch(e) {} — mất error info

🟡 INCONSISTENT:
  - 3 files dùng { error: message } thay vì { error_code, message, request_id }

🟢 OK:
  ✓ Global error handler đã có
  ✓ Retry logic cho payment gateway

📋 ACTION PLAN:
  1. Tạo src/shared/errors/ với base-error.ts (scaffold mode: /error-handler-pattern --mode=scaffold)
  2. Replace 12 throw new Error() instances
  3. Standardize response schema ở global handler
```
