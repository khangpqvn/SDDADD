# PROJECT CONSTITUTION — Starter Template

# Version: 1.1.0 (LOCKED)
# Status: APPROVED — Requires RFC Process to Modify
# Owner: Tech Lead & Architecture Board (@arch-board)

---

## LAYER 1: HARD RULES

Các quy tắc bảo mật, toàn vẹn dữ liệu và quyền quyết định tối thiểu. Vi phạm phải block delivery hoặc execution liên quan.

### SEC-01: Zero Hardcoded Secrets & PII Exposure

- **Rule**: System SHALL NOT lưu credentials, API key, private key, connection string chứa password hoặc PII dưới dạng plaintext trong source code, configuration, artifact hay log.
- **Rule**: PII trong log/error response phải được mask; không trả stack trace, provider detail hoặc secret cho client/caller không được phép.
- **Enforcement**: Chạy security scan, secret scan hoặc review command đã được Architecture Profile/CI chọn; không tự suy đoán tool hoặc command.

### SEC-02: Access Control by Feature Policy

- **Rule**: Feature có action thay đổi state hoặc truy cập dữ liệu nhạy cảm SHALL xác định identity, authorization ownership và behavior unauthorized trong `SPEC.md`.
- **Rule**: Mechanism xác thực, token/session, role/scope policy, middleware và HTTP/event mapping chỉ dùng khi binding tương ứng trong Architecture Profile đã `APPROVED`.
- **Rule**: Interface adapter chỉ chuyển identity/context đã xác thực vào usecase; business authorization nằm trong usecase hoặc policy boundary đã được Spec xác định.

### DATA-01: Core Business Data Protection

- **Rule**: Feature thay đổi hoặc xóa core business data SHALL xác định retention, recovery, authorization và audit behavior trong `SPEC.md`.
- **Rule**: Soft-delete policy, field representation, query default, hard-delete exception, migration và cascade behavior chỉ dùng khi persistence binding đã `APPROVED` và safety review cho phép.
- **Rule**: Không dùng destructive DB operation trái `.sdd/constraints/safety.md`.

---

## LAYER 2: ARCHITECTURAL CONSTRAINTS

Cấu trúc hệ thống và ranh giới module. Mọi ngoại lệ cần RFC `APPROVED` bởi Tech Lead hoặc Architecture Board.

### ARCH-01: Clean Architecture Boundaries

- **Rule**: Interface gọi usecase; usecase phụ thuộc domain và port; infra triển khai port; domain không phụ thuộc adapter hoặc third-party package.
- **Forbidden**: `src/interface/` truy cập DB/repository/ORM trực tiếp.
- **Rule**: HTTP/event adapter, persistence, cache, external client và validation implementation chỉ nằm ở layer được Architecture Profile + Plan đã `APPROVED` chỉ định.

### ARCH-02: Async and Reliability by Specification

- **Rule**: Feature có latency, reliability, retry, ordering, idempotency hoặc delivery requirement SHALL mô tả behavior và acceptance criteria trong `SPEC.md`.
- **Rule**: Message broker, queue, scheduler, timeout, retry/backoff và persistence mechanism chỉ dùng khi Architecture Profile đã `APPROVED` binding/evidence tương ứng.
- **Rule**: Không tự áp threshold thời gian, broker hoặc implementation mechanism từ template.

---

## LAYER 3: ENGINEERING STANDARDS

Tiêu chuẩn code quality và bảo trì. Exception cần được nêu trong recommendation, có evidence và được reviewer có thẩm quyền chấp thuận.

### ENG-01: Spec-to-Code Traceability

- **Rule**: Function/method thực thi business rule trong `src/usecase/` phải có JSDoc trích requirement từ Spec:

  ```typescript
  /**
   * @ears .sdd/features/{slug}/SPEC.md#REQ-XXX
   */
  ```

### ENG-02: Safe Error Contract

- **Rule**: Typed error không được leak stack trace, secret, PII hoặc provider/driver detail qua application boundary.
- **Rule**: Khi feature dùng HTTP binding đã `APPROVED`, interface adapter map lỗi theo schema `{ error_code, message, request_id, timestamp }`; `details` phải được sanitize.
- **Rule**: Với event/CLI/khác HTTP, error contract và mapping phải do `SPEC.md` cùng approved transport binding xác định.

### ENG-03: Evidence-Based Verification

- **Rule**: Chỉ chạy test, lint, typecheck, build, security scan hoặc migration command vừa có `APPROVED` binding vừa có repository/CI evidence trong Architecture Profile.
- **Rule**: Không thay bằng `npm`, `pnpm`, `yarn`, framework command hoặc test filter suy đoán.
- **Rule**: `N/A` chỉ hợp lệ khi check không áp dụng, ví dụ core-only template chưa có executable behavior/command; phải ghi lý do.

---

## RFC PROCESS

Sau khi template được phát hành, muốn sửa Layer 1 hoặc Layer 2 trong `CONSTITUTION.md`:

1. Tạo `.sdd/rfcs/RFC-XXX-<title>.md` bằng `/sdd-rfc`.
2. Ghi `Motivation`, `Proposed Change`, `Risk Assessment`, `Migration Plan`, AI recommendation và Human Final Review.
3. Tech Lead/Human Director ghi `APPROVED` qua quy trình RFC, rồi dùng `/sdd-rfc --approve=<rfc-number>` để đồng bộ Constitution và bump version.

Agent không tự sửa Constitution, suy approval từ hội thoại hoặc bypass RFC. Ngoại lệ cho lần phát hành template này đã được Human Director cho phép explicit; ngoại lệ đó không tạo quyền mặc định cho thay đổi sau này.

---

## AI AGENT SELF-CHECK PROTOCOL

Trước khi báo hoàn thành task, Agent phải kiểm tra:

1. [ ] Không có plaintext secret/key hoặc PII leak (`SEC-01`).
2. [ ] Feature cần access control đã có identity, authorization ownership và unauthorized behavior trong Spec (`SEC-02`).
3. [ ] Persistence/data change có retention, recovery, deletion policy và safety review phù hợp (`DATA-01`).
4. [ ] Dependency direction khớp `ARCH-01`; interface không truy cập DB trực tiếp.
5. [ ] Async/reliability behavior khớp Spec và chỉ dùng broker/queue đã approved (`ARCH-02`).
6. [ ] Business method có `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX` (`ENG-01`).
7. [ ] Error boundary không leak sensitive detail; HTTP mapping, nếu có, khớp `ENG-02`.
8. [ ] Architecture Profile, Shadow Plan và Human Final Review đã `APPROVED` trước technical execution.
9. [ ] Đã chạy exact approved verification command hoặc ghi `N/A` với lý do hợp lệ (`ENG-03`).

---

## Changelog

### v1.1.0 (2026-08-24)

- Chuyển Constitution của starter template sang profile-aware governance.
- Loại bỏ hardcode JWT/OAuth2/RBAC, `deleted_at`, Message Queue 1.5 giây, HTTP-only error mapping và `npm test`.
- Sửa dependency direction theo Clean Architecture/Hexagonal Architecture canonical.
- Giữ RFC gate cho mọi thay đổi Constitution sau khi phát hành template.

### v1.0.0

- Phát hành Constitution ban đầu cho SDD + ADD Starter Template.
