# PROJECT CONSTITUTION — Starter Template

# Version: 1.0.0 (LOCKED)
# Status: APPROVED — Requires RFC Process to Modify
# Owner: Tech Lead & Architecture Board (@arch-board)

---

## 🏛️ LAYER 1: HARD RULES (Bất Biến — Automated Blocking Gates)
*Các quy tắc bảo mật và toàn vẹn dữ liệu tối cao. Vi phạm layer này sẽ làm CI/CD Build FAIL ngay lập tức và Agent bị từ chối submit code.*

### SEC-01: Zero Hardcoded Secrets & PII Exposure
- **Rule**: System SHALL NOT lưu trữ bất kỳ credentials, API Key (`sk-ant-*`, `sk-proj-*`), Private Key, Connection String hoặc Password nào dưới dạng plaintext trong source code, config files hay logs.
- **Enforcement**: Run `git-secrets` / `trufflehog` pre-commit & CI checks.
- **Sanitization**: Tất cả dữ liệu PII (Email, Phone, Credit Card) phải được mask trong application log (`usr_***@domain.com`).

### SEC-02: Mandatory Authentication & Authorization
- **Rule**: System SHALL yêu cầu xác thực JWT / OAuth2 và phân quyền RBAC cho 100% endpoints thay đổi trạng thái (POST, PUT, PATCH, DELETE).

### DATA-01: Soft-Delete for Core Business Entities
- **Rule**: System SHALL áp dụng Soft-Delete (`deleted_at TIMESTAMP`) cho tất cả các bảng dữ liệu cốt lõi. KHÔNG sử dụng `DELETE FROM` SQL statement cho production data.

---

## 🏗️ LAYER 2: ARCHITECTURAL CONSTRAINTS (Ràng Buộc Kiến Trúc)
*Cấu trúc hệ thống và ranh giới module. Cần có RFC approved bởi Tech Lead nếu muốn tạo ngoại lệ.*

### ARCH-01: Clean Architecture Boundaries
- **Rule**: Ranh giới phụ thuộc chỉ được phép đi TỪ NGOÀI VÀO TRONG: `infra` -> `interface` -> `usecase` -> `domain`. `domain` layer không được import bất kỳ 3rd-party library nào ngoại trừ standard utils.
- **Forbidden**: Direct DB Access từ `interface` layer (Controllers).

### ARCH-02: Asynchronous Event-Driven Operations
- **Rule**: Các tác vụ có thời gian phản hồi dự kiến > 1.5 giây SHALL được đẩy vào Message Queue để xử lý bất đồng bộ.

---

## 🛠️ LAYER 3: ENGINEERING STANDARDS (Tiêu Chuẩn Kỹ Thuật)
*Tiêu chuẩn code quality và quy trình bảo trì. Agent được phép tự điều chỉnh nếu có lý do giải thích rõ ràng.*

### ENG-01: Spec-to-Code Traceability (EARS Tagging)
- **Rule**: Mọi function/method thực thi business rule trong `usecase/` bắt buộc phải chứa JSDoc tag trích dẫn requirement từ SPEC:
  ```typescript
  /**
   * @ears .sdd/features/{slug}/SPEC.md#REQ-XXX
   */
  ```

### ENG-02: Unified Error Response Standard
- **Rule**: System SHALL không bao giờ trả về HTTP 500 Unhandled Exception kèm stack trace cho client. Mọi response lỗi phải tuân thủ schema chuẩn: `{ error_code, message, request_id, timestamp }`.

---

## 📜 RFC PROCESS (REQUEST FOR COMMENTS)
Muốn sửa đổi bất kỳ quy tắc nào trong `CONSTITUTION.md` (Layer 1 hoặc Layer 2):
1. Tạo file đề xuất tại `.sdd/rfcs/RFC-XXX-<title>.md`.
2. Mô tả Lý do (Motivation), Đề xuất thay đổi (Proposed Change), và Đánh giá rủi ro (Risk Assessment).
3. Cần sự phê duyệt (Approve) của Tech Lead / Human Director trước khi bump version `CONSTITUTION.md`.

---

## 🤖 AI AGENT SELF-CHECK PROTOCOL
Trước khi báo cáo hoàn thành bất kỳ Task nào, Agent **BẮT BUỘC** tự chạy kiểm tra theo checklist sau:

1. [ ] Code có chứa plaintext secret/key nào không? (`SEC-01`)
2. [ ] Các endpoint mới có middleware authenticate chưa? (`SEC-02`)
3. [ ] Class/Module có tuân thủ ranh giới Clean Architecture không? (`ARCH-01`)
4. [ ] Mọi business function đều đã gắn tag `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX` chưa? (`ENG-01`)
5. [ ] Đã chạy `npm test` và đạt coverage target chưa? (`ENG-02`)
