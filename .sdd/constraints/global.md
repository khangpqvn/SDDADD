# Constraint Layer 1: Global kỹ thuật
# Version: 1.0.0
# Phạm vi: Mọi Agent, mọi feature — baseline không thể tự suy đoán
# Tham chiếu: Slide 10.4 — 3-Layer Constraint Hierarchy

---

## 1. Tech stack và package

`.sdd/architecture-profile.md` là nguồn sự thật duy nhất cho runtime, HTTP framework, database, ORM/query layer, cache, message broker, validation, test framework và runnable command.

- Agent chỉ dùng binding có `APPROVED` và evidence trong Architecture Profile.
- Không suy đoán stack từ tên thư mục, convention hay package quen thuộc.
- Package mới cần phù hợp binding đã approved và Human approval trước khi thêm dependency.
- `eval` và `Function()` constructor bị cấm vì rủi ro bảo mật.
- Không dùng package deprecated khi có native platform API phù hợp, trừ khi Architecture Profile hoặc RFC đã approved nêu rõ lý do.

---

## 2. Quy ước tên

| Loại | Quy ước | Ví dụ |
| :--- | :--- | :--- |
| Source file | kebab-case | `order-repository.ts` |
| Class / type | PascalCase | `OrderRepository` |
| Constant | SCREAMING_SNAKE_CASE | `MAX_RETRY_COUNT` |
| Environment variable | SCREAMING_SNAKE_CASE | `DATABASE_URL` |
| Test file | Theo test framework đã approved | `order-service.spec.ts` |
| SDD artifact | UPPERCASE.md | `SPEC.md`, `PLAN.md` |
| Script | kebab-case | `self-heal.sh` |

---

## 3. Giới hạn kích thước code

- Source file tối đa **200 dòng**; tách module khi vượt ngưỡng.
- SDD artifact `SPEC.md` và `PLAN.md` tối đa **300 dòng**.
- Function/method body tối đa **50 dòng**; tách helper nếu cần.

---

## 4. Secret và runtime configuration

- Secret chỉ dùng qua secret/configuration mechanism đã được Architecture Profile hoặc operations policy chấp thuận; không ghi inline.
- Khi project chọn environment variable, mô tả biến bắt buộc trong `.env.example`; không commit `.env`.
- Khi runtime bootstrap implementation đã được chọn, validate configuration bắt buộc và trả về application error phù hợp; không tự áp class hoặc API chưa có trong binding.
