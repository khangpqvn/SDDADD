# Bắt đầu nhanh SDD + ADD

Tài liệu này hướng dẫn bạn hoàn thành **một feature** từ ý tưởng đến Git delivery. Hãy đi tuần tự từng bước; tuyệt đối không nhảy từ ý tưởng sang viết code.

**Lộ trình:** `CONTEXT` $\rightarrow$ `SPEC` $\rightarrow$ `PLAN` $\rightarrow$ `TASKS` $\rightarrow$ `execute` $\rightarrow$ `validation` $\rightarrow$ `delivery`

---

## Bước 0: Chuẩn bị và Định danh
Trước khi bắt đầu, bạn cần:
1. **Feature Slug**: Một tên viết bằng kebab-case (ví dụ: `feat-user-register`). Dùng slug này xuyên suốt mọi command.
2. **Outcome mong muốn**: Mô tả ngắn gọn kết quả cuối cùng (ví dụ: "Người dùng đăng nhập được bằng email").
3. **Kiểm tra Governance**: Đảm bảo `.sdd/shared_context.md` đã xác định `Project Ownership` (solo/team) và `Agent Execution` (direct/orchestrated).

---

## Bước 1: Thống nhất bài toán (`CONTEXT`)
**Mục tiêu:** Xác định "Chúng ta đang làm gì, cho ai, và ranh giới ở đâu?" để không làm sai hướng.

- **Việc cần làm:**Chạy `/sdd-context --feature=feat-user-register`
- **Kết quả kiểm chứng:** Tệp `.sdd/features/feat-user-register/CONTEXT.md` được tạo.
- **Điểm mấu chốt:**
    - `Intent Packet` phải rõ ràng.
    - Mọi câu hỏi mơ hồ phải được disposition (`resolved`, `approved assumption`, hoặc `blocking decision`).
- **Gate:** Human đọc và ghi `/sdd-review ... --artifact=context --status=APPROVED`.
- **Tiếp theo:** Sang Bước 2.

---

## Bước 2: Định nghĩa behavior (`SPEC`)
**Mục tiêu:** Chuyển ý tưởng thành yêu cầu kỹ thuật có thể kiểm tra (không gắn với framework cụ thể).

- **Việc cần làm:**Chạy `/sdd-spec --feature=feat-user-register`
- **Kết quả kiểm chứng:** Tệp `.sdd/features/feat-user-register/SPEC.md` được tạo.
- **Điểm mấu chốt:**
    - Dùng EARS để viết `REQ-XXX`.
    - Phải có Acceptance Criteria cho mỗi requirement.
    - **Clarification-First**: Agent phải liệt kê gap/edge case $\rightarrow$ Human trả lời $\rightarrow$ mới viết REQ.
- **Gate:** Human ghi `/sdd-review ... --artifact=spec --status=APPROVED`. Spec lúc này được **LOCKED**.
- **Tiếp theo:** Kiểm tra Architecture Profile rồi sang Bước 3.

---

## Bước 3: Thiết kế kỹ thuật (`PLAN`)
**Mục tiêu:** Xác định "Sẽ sửa file nào, dùng lệnh gì để verify, rủi ro ở đâu?".

- **⚠️ Điều kiện tiên quyết:** Mở `.sdd/architecture-profile.md`. Nếu feature cần DB/API/Library mà Profile chưa có binding `APPROVED`, bạn phải cập nhật Profile và xin duyệt trước.
- **Việc cần làm:**Chạy `/sdd-plan --feature=feat-user-register`
- **Kết quả kiểm chứng:** Tệp `.sdd/features/feat-user-register/PLAN.md` được tạo.
- **Điểm mấu chốt:**
    - Map mỗi `REQ-XXX` vào component/file cụ thể.
    - Sử dụng **Exact approved command** từ Profile (không dùng lệnh đoán).
- **Gate:** Human ghi `/sdd-review ... --artifact=plan --status=APPROVED`.
- **Tiếp theo:** Sang Bước 4.

---

## Bước 4: Chia nhỏ công việc (`TASKS`)
**Mục tiêu:** Biến bản thiết kế thành danh sách việc cần làm (Atomic tasks).

- **Việc cần làm:**Chạy `/sdd-tasks --feature=feat-user-register`
- **Kết quả kiểm chứng:** Tệp `.sdd/features/feat-user-register/TASKS.md` được tạo.
- **Điểm mấu chốt:**
    - Mỗi task có: Boundary (file được sửa), Dependency, và Exact command để verify.
    - Task lớn (> 4h) phải được tách nhỏ hoặc có `approved-exception`.
- **Gate:** Human ghi `/sdd-review ... --artifact=tasks --status=APPROVED`.
- **Tiếp theo:** Sang Bước 5 (Thực thi).

---

## Bước 5: Thực thi và Xác minh (`EXECUTE`)
**Mục tiêu:** Viết code và chứng minh code chạy đúng.

- **Việc cần làm:**
    - Chạy một task: `/add-execute --feature=feat-user-register --task=T001`
    - Chạy toàn bộ feature: `/add-execute --feature=feat-user-register --all`
- **Luồng hoạt động:**
    1. Agent tạo **Shadow Plan** $\rightarrow$ Consumer Grant $\rightarrow$ Thực thi $\rightarrow$ Ghi **Action Record**.
    2. Chạy exact approved command để verify.
- **Điểm mấu chốt:**
    - Không tự ý sửa file ngoài boundary.
    - Không tự ý đổi command verify.
    - Mọi material state change (đổi DB schema, v.v.) cần **Human Checkpoint** trước khi làm.
- **Tiếp theo:** Sang Bước 6.

---

## Bước 6: Kiểm tra cuối và Delivery (`GIT`)
**Mục tiêu:** Đảm bảo không có regression và chuyển giao vào Git.

- **Việc cần làm:**
    1. Chạy `/sdd-audit` và `/sdd-trace` để kiểm tra độ phủ requirement.
    2. Tạo **Post-code review report** (nếu có thay đổi source/contract).
    3. Chạy `/git-validate --scope=commit --feature=feat-user-register`.
- **Kết quả cuối cùng:** Khi nhận được `GIT VALIDATION: READY`, Human yêu cầu Agent commit.
- **Delivery:** Human tự thực hiện `git push`.

---

## 🛑 Khi nào phải DỪNG?
- Thiếu review `APPROVED` cho bất kỳ artifact nào.
- Spec bị mâu thuẫn hoặc thiếu rule $\rightarrow$ Quay lại Bước 2.
- Architecture Profile thiếu binding/command $\rightarrow$ Cập nhật Profile.
- Test fail $\rightarrow$ Phân tích defect, không vá code tùy tiện.
