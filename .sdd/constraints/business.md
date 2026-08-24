# Constraint Layer 2: Quy tắc nghiệp vụ
# Version: 1.0.0
# Phạm vi: Agent xử lý business logic — domain và usecase layer
# Tham chiếu: Slide 10.4 — 3-Layer Constraint Hierarchy

---

## 1. Authentication và authorization

Các quy tắc dưới đây chỉ áp dụng khi feature và Architecture Profile đã chọn authentication/authorization adapter:

- Mọi action thay đổi trạng thái phải xác thực identity và kiểm tra authorization trong usecase hoặc policy boundary.
- Token expiry, token rotation, failed-login throttle, session revocation và scope/role policy phải được xác định trong `SPEC.md` hoặc binding đã approved; không tự áp thời lượng, package hoặc storage cụ thể.
- Interface adapter chuyển identity đã xác thực vào usecase; controller không tự thực thi business authorization.

---

## 2. PII masking

PII phải được mask trong application log và error response:

| Loại dữ liệu | Mẫu mask | Ví dụ |
| :--- | :--- | :--- |
| Email | `usr_***@domain.com` | `usr_***@gmail.com` |
| Số điện thoại | `***-***-1234` | `***-***-5678` |
| Thẻ thanh toán | `****-****-****-1234` | `****-****-****-5678` |
| Password | `[REDACTED]` | — |
| JWT token | `[TOKEN]` | — |
| API key | `sk-***...{last4}` | `sk-***...abcd` |

Logger/sanitization adapter phải sanitize request body và header trước khi ghi log. Không dùng `JSON.stringify(req.body)` nguyên trạng.

---

## 3. Rate limiting

Khi feature cần rate limiting, `SPEC.md` phải xác định endpoint/action, limit, time window, key và behavior khi vượt ngưỡng. Chỉ chọn storage/algorithm sau khi cache hoặc persistence binding được approved.

- Không dựa vào in-memory state cho policy cần tồn tại qua restart, trừ khi Spec chấp thuận rõ ràng.
- Key phải giới hạn theo identity hoặc nguồn request phù hợp với abuse model đã mô tả trong Spec.
- Response khi vượt limit phải dùng error contract đã approved.

---

## 4. Bảo vệ vòng đời dữ liệu

Khi feature dùng persistence đã approved:

- Core business data phải có retention, recovery, authorization và deletion policy theo `CONSTITUTION.md` DATA-01.
- Soft-delete policy chỉ dùng khi `SPEC.md`, database/ORM binding và review đã xác định field representation cùng query behavior.
- Hard delete chỉ dùng cho dữ liệu được Spec và safety review cho phép.
- Cascade behavior phải explicit; không tự suy đoán từ ORM hoặc DB default.

---

## 5. Business logic chung

- Mutation phải xét idempotency khi duplicate request có thể gây sai dữ liệu; behavior nằm trong `SPEC.md`.
- Concurrent update phải có concurrency policy được Spec nêu rõ.
- Giá trị tiền tệ không dùng floating-point; chọn unit nguyên trong contract.
- Timestamp lưu theo UTC; chỉ chuyển đổi presentation khi cần.
