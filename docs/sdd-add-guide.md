# HƯỚNG DẪN CHI TIẾT PHƯƠNG PHÁP LUẬN VÀ VẬN HÀNH SDD + ADD

# Version: 3.0.0 (Comprehensive Handbook & Operational Scenarios)
# Target Audience: Developers, Tech Leads, QA, AI Assistants (Claude Code, Roo Code, Cline, Cursor)

---

## 1. SDD + ADD LÀ GÌ? (Ý NGHĨA & TRIẾT LÝ CỐT LÕI)

### 1.1 Khái niệm
- **SDD (Spec-Driven Development — Phát triển dựa trên Đặc tả Executable)**: Phương pháp lập trình mà trong đó **Đặc tả (Specification)** được xem như **Mã nguồn thực thi (Executable Code)**. Mọi logic nghiệp vụ, điều kiện biên, cách xử lý lỗi phải được định nghĩa chính xác và không mơ hồ trong file `.sdd/features/{slug}/SPEC.md` trước khi viết bất kỳ dòng code nào.
- **ADD (Agent-Driven Development — Phát triển do AI Agent dẫn dắt)**: Phương pháp sử dụng các AI Agent làm lực lượng thực thi chính (Executor) dưới sự chỉ đạo và giám sát của Con người (Human Director). Agent đọc đặc tả, lập kế hoạch kiến trúc, phân rã công việc và sinh code + test tự động.

### 1.2 Triết lý Vàng (Golden Rules)
1. **"Fix the Spec, NOT the Code" (Sai ở đâu, sửa ở Spec đó)**:
   Khi test thất bại, có bug hoặc logic chưa đúng ➔ **Tuyệt đối KHÔNG sửa code trực tiếp**. Phải cập nhật lại file `SPEC.md` để bổ sung trường hợp sót ➔ Sau đó yêu cầu AI Agent re-generate code từ Spec mới. Code chỉ là sản phẩm trung gian (Artifact), Spec mới là Nguồn sự thật lâu dài (Single Source of Truth).
2. **Spec là Compiler Interface**:
   Con người đóng vai trò Kiến trúc sư/Nhạc trưởng (viết What — Hệ thống cần làm gì). AI Agent đóng vai trò Compiler (sinh How — Hệ thống làm như thế nào). Nếu AI đoán mò (Hallucinate), đó là do Spec viết chưa đủ chi tiết hoặc còn mập mờ.
3. **EARS Traceability (Truy vết 100%)**:
   Tất cả hàm/phương thức thực thi logic nghiệp vụ trong code (`src/usecase/`) bắt buộc phải gắn JSDoc tag `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX`.

---

## 2. QUY TRÌNH 5 BƯỚC THỰC THI (5-STEP WORKFLOW)

Mỗi tính năng (Feature) mới đều trải qua 5 pha tuyến tính. Không chuyển pha khi pha hiện tại chưa đạt **Definition of Done (DoD)**.

```text
[Pha 0: CONTEXT] ➔ [Pha 1: SPEC] ➔ [Pha 2: PLAN] ➔ [Pha 3: TASKS] ➔ [Pha 4 & 5: EXECUTE & VERIFY]
```

### Chi tiết các Pha & Lệnh Slash Commands:

| Pha | Lệnh Slash Command | Đầu vào (Input) | Đầu ra (Output) | Ý nghĩa & Cách làm |
| :--- | :--- | :--- | :--- | :--- |
| **Pha 0: Context** | `/sdd-context --feature=<slug>` | Yêu cầu nghiệp vụ sơ khai từ User/PM | `.sdd/features/{slug}/CONTEXT.md` | Khai phá nỗi đau người dùng, từ điển Domain (Glossary), các ràng buộc cứng. Chưa bàn giải pháp kỹ thuật. |
| **Pha 1: Spec** | `/sdd-spec --feature=<slug>` | `CONTEXT.md` | `.sdd/features/{slug}/SPEC.md` | Viết đặc tả chuẩn EARS Notation, đủ 8 thành phần, đánh số `REQ-001`, khai báo Semantic Versioning (`v1.0.0`) & trạng thái LOCKED. |
| **Pha 2: Plan** | `/sdd-plan --feature=<slug>` | `SPEC.md` | `.sdd/features/{slug}/PLAN.md` | Thiết kế kiến trúc Clean Arch (`domain`, `usecase`, `interface`, `infra`), phân tích rủi ro kỹ thuật, vẽ Data Flow. |
| **Pha 3: Tasks** | `/sdd-tasks --feature=<slug>` | `PLAN.md` + `SPEC.md` | `.sdd/features/{slug}/TASKS.md` | Phân rã công việc thành các Atomic Tasks (`T001`, `T002`), mỗi task độc lập, có thể verify và gắn `@ears` tag. |
| **Pha 4 & 5: Execute** | `/add-execute --feature=<slug>` | `TASKS.md` + `SPEC.md` | Source Code + Test Suite | AI Agent thực thi từng task, viết test, tự kiểm tra quy chuẩn `CONSTITUTION.md` và chạy test báo GREEN. |
| **Cập nhật Spec** | `/sdd-update --feature=<slug> --bump=<major\|minor\|patch> --reason="..."` | `SPEC.md` hiện tại | `SPEC.md` (Version mới) + Changelog | Tự động nâng phiên bản SemVer, cập nhật yêu cầu EARS, ghi Changelog và đề xuất lệnh đồng bộ Code/Test. |
| **Truy vết & Diff** | `/sdd-trace --feature=<slug> [--req=REQ-XXX] [--diff]` | Codebase + Spec | Traceability Report | Truy vết 5 tầng (Spec ➔ Plan ➔ Task ➔ Code ➔ Test), phân tích tác động thay đổi và phát hiện đứt gãy vết. |

---

## 3. HƯỚNG DẪN SỬA SPEC THỦ CÔNG (MANUAL SPEC FIX PROTOCOL)

Khi bạn muốn chỉnh sửa thủ công (manual edit) file `SPEC.md` sau khi đã chạy các skill hoặc đã sinh code:

### Quy trình 4 bước sửa Spec thủ công chuẩn SDD:

1. **Bước 1: Mở file Spec cần sửa**
   - Đội ngũ mở file `.sdd/features/{slug}/SPEC.md`.

2. **Bước 2: Cập nhật nội dung & Đánh số REQ mới**
   - Sửa đổi quy tắc EARS cũ hoặc bổ sung Functional Requirement mới (ví dụ: `REQ-008`).
   - Giữ nguyên cấu trúc EARS (`WHEN ... SHALL ...`).

3. **Bước 3: Tăng phiên bản Spec (Semantic Versioning Bump)**
   - Cập nhật header ở đầu file `SPEC.md`:
     - **Thêm/Sửa điều kiện nhỏ / Fix bug**: Bump `PATCH` (e.g. `v1.0.0` ➔ `v1.0.1`).
     - **Thêm tính năng mới không phá vỡ hợp đồng cũ**: Bump `MINOR` (e.g. `v1.0.0` ➔ `v1.1.0`).
     - **Thay đổi lớn phá vỡ hợp đồng API/DB**: Bump `MAJOR` (e.g. `v1.0.0` ➔ `v2.0.0`).
   - Ghi chú lý do vào mục `## Changelog` ở cuối file `SPEC.md`.

4. **Bước 4: Re-synchronize Plan, Tasks & Code**
   - Chạy lại các lệnh tương ứng để đồng bộ hệ thống:
     - Nếu chỉ sửa bug/logic nhỏ trong Spec: Chạy trực tiếp `/add-execute --feature=<slug>` để Agent đọc Spec mới, cập nhật code và bổ sung test cases.
     - Nếu bổ sung nhiều Yêu cầu mới (Minor/Major): Chạy lại `/sdd-tasks --feature=<slug>` để cập nhật danh sách `TASKS.md`, sau đó chạy `/add-execute --feature=<slug>`.

---

## 4. CÁC KỊCH BẢN THỰC TẾ KHI LÀM VIỆC THEO SDD + ADD (REAL-WORLD SCENARIOS)

### Kịch bản 1: Phát triển tính năng mới từ đầu (New Feature)
- **Bối cảnh**: Bạn nhận được yêu cầu "Xây dựng tính năng Đăng ký tài khoản người dùng bằng Email/OTP".
- **Luồng xử lý**:
  1. Chạy `/sdd-context --feature=feat-user-register` ➔ Trả lời các câu hỏi về domain, OTP expiry, rate limit.
  2. Chạy `/sdd-spec --feature=feat-user-register` ➔ Tạo `SPEC.md` chứa `REQ-001` đến `REQ-010` chuẩn EARS.
  3. Review `SPEC.md` với PO/Team ➔ Thấy ổn thì khoá Spec (`APPROVED & LOCKED v1.0.0`).
  4. Chạy `/sdd-plan --feature=feat-user-register` ➔ Thiết kế Clean Architecture cho UseCase `RegisterUser`.
  5. Chạy `/sdd-tasks --feature=feat-user-register` ➔ Sinh danh sách công việc `T001` đến `T006`.
  6. Chạy `/add-execute --feature=feat-user-register` ➔ Agent sinh toàn bộ code và unit test.

---

### Kịch bản 2: Phát hiện Bug trong quá trình chạy Test hoặc Production
- **Bối cảnh**: Khi test phát hiện bug "Người dùng có thể bấm gửi lại OTP liên tục 100 lần/phút gây tràn RAM Redis".
- **Cách làm KHÔNG ĐÚNG ❌**: Nhảy vào `src/usecase/send-otp.ts` sửa trực tiếp `if (rateLimit) return;`.
- **Cách làm ĐÚNG SDD ✅**:
  1. Mở file `.sdd/features/feat-user-register/SPEC.md`.
  2. Bổ sung yêu cầu mới theo chuẩn EARS:
     ```markdown
     ### REQ-011: Rate Limit Gửi OTP (Unwanted Behavior)
     IF người dùng gửi yêu cầu gửi lại OTP quá 3 lần trong vòng 60 giây,
     THEN hệ thống SHALL từ chối xử lý, trả về HTTP status 429 Too Many Requests kèm error_code `ERR_OTP_RATE_LIMIT`.
     ```
  3. Bump version Spec từ `v1.0.0` ➔ `v1.0.1` và thêm changelog "Fix rate limit vulnerability".
  4. Chạy `/add-execute --feature=feat-user-register`. Agent sẽ đọc Spec mới, cập nhật code và thêm test case cho rate limit.

---

### Kịch bản 3: Sửa Spec thủ công do Khách hàng/PO đổi Yêu cầu (Requirement Change)
- **Bối cảnh**: PO yêu cầu đổi thời gian hết hạn OTP từ 5 phút xuống 2 phút.
- **Luồng xử lý**:
  1. Developer mở thủ công `.sdd/features/feat-user-register/SPEC.md`.
  2. Sửa dòng EARS tương ứng từ `5 minutes` thành `2 minutes`.
  3. Bump version `SPEC.md` từ `v1.0.1` ➔ `v1.1.0`.
  4. Chạy `/add-execute --feature=feat-user-register`. Agent kiểm tra sự sai lệch giữa Spec mới và Code cũ, cập nhật lại hằng số/config và tự động điều chỉnh assertion trong Unit Test.

---

### Kịch bản 4: Test Fail hoặc Agent bị lặp lỗi (Spec Mismatch & Self-Correction)
- **Bối cảnh**: Trong pha `/add-execute`, Agent sinh code nhưng test liên tục thất bại quá 3 lần.
- **Luồng xử lý theo `AGENTS.md` Protocol**:
  1. Agent dừng việc sinh code bừa bãi (Không thử vá ngẫu nhiên).
  2. Agent thực hiện Self-Diagnostic: Phân tích lỗi xem do Code bug hay do Spec viết mập mờ/thiếu trường hợp biên.
  3. Nếu Spec mập mờ: Agent báo cáo điểm mập mờ cho Human Director.
  4. Human Director sửa Spec thủ công (hoặc duyệt phương án sửa Spec do Agent đề xuất).
  5. Chạy lại `/add-execute` để hoàn tất task.

---

### Kịch bản 5: Thay đổi Quy chuẩn Kiến trúc hoặc Bảo mật Toàn hệ thống (RFC Process)
- **Bối cảnh**: Team quyết định từ nay tất cả các bảng dữ liệu cốt lõi bắt buộc dùng Soft-Delete (`deleted_at TIMESTAMP`), vi phạm sẽ không cho commit code.
- **Luồng xử lý**:
  1. `CONSTITUTION.md` là file Hiến pháp Layer 1 bị **LOCKED** (Agent không được tự sửa).
  2. Tạo file đề xuất RFC tại `.sdd/rfcs/RFC-001-soft-delete-policy.md`.
  3. Trình bày Lý do (Motivation), Đề xuất quy tắc (`DATA-01`) và Rủi ro.
  4. Sau khi Tech Lead phê duyệt RFC ➔ Cập nhật quy tắc `DATA-01` vào `CONSTITUTION.md`.
  5. Mọi Agent trong các pha `/add-execute` tương lai sẽ tự động tuân thủ và kiểm tra quy định `DATA-01` này.

### Kịch bản 6: Tích hợp SDD+ADD vào Repository CÓ SẴN (Brownfield / Legacy Codebase)
- **Bối cảnh**: Bạn có một dự án Node.js/Python/Go đã chạy 2 năm, chưa từng dùng SDD+ADD, nay muốn đưa quy trình SDD+ADD vào để quản lý các tính năng mới và refactor các module cũ.
- **Luồng xử lý**:
  1. **Khởi tạo bộ khung SDD trên Repo cũ**:
     Chạy lệnh:
     ```bash
     /sdd-adopt
     ```
     Agent sẽ tự động scout codebase hiện tại, phát hiện Tech Stack, Naming Conventions, Build/Test scripts và tự động sinh 3 file Hiến pháp (`CLAUDE.md`, `AGENTS.md`, `CONSTITUTION.md`) phù hợp với codebase cũ mà **không chạm/không sửa bất kỳ dòng code hiện tại nào**.
  2. **Phát triển tính năng MỚI trên Repo cũ**:
     Sử dụng bình thường 5 bước slash commands cho feature mới:
     ```bash
     /sdd-context --feature=feat-new-payment
     /sdd-spec    --feature=feat-new-payment
     /sdd-plan    --feature=feat-new-payment
     /sdd-tasks   --feature=feat-new-payment
     /add-execute --feature=feat-new-payment
     ```
  3. **Đảo ngược Đặc tả (Reverse Spec) cho Module CŨ để Refactor (Tùy chọn)**:
     Khi cần refactor hoặc viết lại một module cũ (ví dụ `src/modules/auth`), chạy lệnh:
     ```bash
     /sdd-adopt --reverse-feature=feat-legacy-auth --path=src/modules/auth
     ```
     Agent sẽ đọc source code và tests cũ, trích xuất lại các quy tắc nghiệp vụ hiện có thành file đặc tả `.sdd/features/feat-legacy-auth/SPEC.md` theo chuẩn EARS (`v1.0.0 LOCKED`). Từ đây, mọi việc sửa đổi/refactor module cũ này sẽ tuân thủ nguyên tắc **"Fix the Spec, NOT the Code"**.

---

## 5. TRUY VẾT & PHÂN TÍCH TÁC ĐỘNG THAY ĐỔI YÊU CẦU (REQUIREMENT TRACEABILITY & IMPACT ANALYSIS)

Khi một hệ thống phát triển lâu dài, việc thay đổi yêu cầu nghiệp vụ (Requirement Change) trong `SPEC.md` có thể dẫn đến rủi ro đứt gãy vết hoặc bỏ sót code/test. Phương pháp luận SDD+ADD cung cấp slash command `/sdd-trace` để quản lý vết 5 tầng:

```text
SPEC.md (REQ-XXX) ➔ PLAN.md ➔ TASKS.md ➔ Source Code (src/ @ears) ➔ Tests (tests/ @ears)
```

### 5.1 Sử dụng Slash Command `/sdd-trace`
- **Truy vết 1 Requirement cụ thể**:
  ```bash
  /sdd-trace --feature=feat-user-register --req=REQ-001
  ```
- **Phân tích tác động khi vừa nâng version Spec (Impact Analysis)**:
  ```bash
  /sdd-trace --feature=feat-user-register --diff
  ```
- **Kiểm tra ma trận phủ (Coverage Matrix) cho toàn feature**:
  ```bash
  /sdd-trace --feature=feat-user-register
  ```

### 5.2 Xử lý các dạng Đứt gãy Vết (Broken Trace Patterns)
1. **Untraced Requirement (Yêu cầu thiếu Code/Test)**:
   - **Hiện tượng**: `REQ-005` được định nghĩa trong `SPEC.md` nhưng không tìm thấy JSDoc tag `@ears ...#REQ-005` nào trong `src/` hoặc `tests/`.
   - **Khắc phục**: Chạy `/add-execute --feature=<slug>` để Agent tự bổ sung UseCase và Test còn thiếu.
2. **Orphan Code (Code mồ côi)**:
   - **Hiện tượng**: Một phương thức trong `src/usecase/` có chứa logic nghiệp vụ nhưng không gắn tag `@ears` trích dẫn về Spec.
   - **Khắc phục**: Bổ sung Tag JSDoc `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX` để đảm bảo 100% code có lý do tồn tại minh bạch.
3. **Outdated Implementation (Code cũ chưa theo Spec mới)**:
   - **Hiện tượng**: `SPEC.md` vừa được sửa từ `v1.0.0` ➔ `v1.1.0` (thay đổi `REQ-003`). `/sdd-trace --diff` phát hiện code trong `src/usecase/` vẫn đang chạy theo logic cũ.
   - **Khắc phục**: Chạy `/add-execute --feature=<slug>` để Agent đồng bộ lại code và test theo `REQ-003` phiên bản mới.

---

## 6. BẢNG TIÊU CHUẨN ĐỊNH DẠNG EARS NOTATION (CHEAT SHEET)

Khi viết hoặc sửa `SPEC.md`, luôn dùng 5 mẫu EARS (Easy Approach to Requirements Syntax) sau:

| Loại EARS Pattern | Cấu trúc cú pháp | Ví dụ thực tế |
| :--- | :--- | :--- |
| **Ubiquitous** (Luôn đúng) | The `<system>` SHALL `<action>` | The system SHALL encrypt all stored user passwords using bcrypt with cost factor 12. |
| **Event-driven** (Khi có sự kiện) | WHEN `<trigger>`, the `<system>` SHALL `<action>` | WHEN the user clicks "Submit Order", the system SHALL create a pending transaction in DB. |
| **State-driven** (Khi ở trạng thái) | WHILE `<in state>`, the `<system>` SHALL `<action>` | WHILE the payment gateway is maintenance mode, the system SHALL display notice banner. |
| **Optional** (Tính năng tùy chọn) | WHERE `<feature is included>`, the `<system>` SHALL `<action>` | WHERE biometric login is enabled, the system SHALL prompt for Fingerprint/FaceID. |
| **Unwanted** (Xử lý lỗi/Ngoại lệ) | IF `<error/invalid condition>`, THEN the `<system>` SHALL `<action>` | IF the password attempt fails >= 5 times, THEN the system SHALL lock account for 30 minutes. |

---

## 7. CHECKLIST TỰ KIỂM TRA CHO DEVELOPER (SELF-AUDIT CHECKLIST)

Trước khi gửi Pull Request hoặc báo cáo hoàn thành công việc, hãy tự kiểm tra:

- [ ] File `SPEC.md` đã có trạng thái `APPROVED & LOCKED` và có phiên bản SemVer (`vX.Y.Z`) chưa?
- [ ] Mọi chức năng nghiệp vụ trong code đã gắn tag `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX` chưa?
- [ ] Có dòng code nào sửa trực tiếp logic mà không qua bước cập nhật `SPEC.md` không? (Nếu có ➔ Quay lại sửa Spec trước).
- [ ] Tất cả các test cases (`npm test`) có báo status **GREEN** 100% không?
- [ ] Code có vi phạm quy định bảo mật `SEC-01` (Zero Hardcoded Secrets) trong `CONSTITUTION.md` không?

---

## 8. QUY TRÌNH HÀN THỦ VÀ LƯU TRẠNG THÁI DỞ DANG (HANDOFF & RESUME PROTOCOL)

Khi đang làm dở công việc và cần kết thúc phiên (hoặc chuyển giao giữa các phiên làm việc), tuân thủ quy trình 3 bước sau để Claude tự ghi nhớ và tiếp tục chính xác ở phiên sau:

### 8.1 Bước 1: Lưu trạng thái dở dang (End of Session / Handoff)

Trước khi đóng Claude Code, thực hiện cập nhật tiến độ công việc vào file `.sdd/features/{slug}/TASKS.md`:

1. Đánh dấu trạng thái các Task (`[x]` cho hoàn thành, `[/]` cho đang làm dở, `[ ]` cho chưa làm).
2. Chạy lệnh Slash Command để cập nhật/đồng bộ danh sách task:
   ```bash
   /sdd-tasks --feature=<slug>
   ```
3. (Tùy chọn) Yêu cầu Claude lưu tóm tắt điểm dừng:
   > *"Lưu trạng thái công việc dở dang: Đang làm dở Task T003 feature <slug>, đã xong file A, phiên sau cần viết tiếp file B."*

### 8.2 Bước 2: Khởi động phiên mới với quyền & khôi phục ngữ cảnh (Resume Session)

Khi mở lại Claude Code cho phiên mới:

- **PowerShell:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Continue
  ```
- **Bash:**
  ```bash
  ./scripts/start-claude.sh -c
  ```

*(Flag `-c` / `-Continue` tự động tải lại phiên làm việc gần nhất tại thư mục dự án).*

### 8.3 Bước 3: Nạp ngữ cảnh và tiếp tục thực thi (Start of Session)

Ngay khi vào phiên mới, chạy lệnh nạp ngữ cảnh feature:

```bash
/sdd-context --feature=<slug>
```

Claude sẽ tự động đọc `.sdd/features/{slug}/TASKS.md` và `SPEC.md`, phát hiện các task đang đánh dấu `[/]` hoặc `[ ]`, báo cáo điểm dừng và tiếp tục thực thi qua lệnh:

```bash
/add-execute --feature=<slug>
```

