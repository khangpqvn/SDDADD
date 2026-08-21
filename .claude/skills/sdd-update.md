---
name: sdd-update
description: Cập nhật đặc tả Feature (.sdd/features/{slug}/SPEC.md), nâng cấp phiên bản SemVer (Major/Minor/Patch), ghi Changelog và điều hướng đồng bộ Code/Test
---

# Skill: SDD Feature Update & Version Bump (`/sdd-update`)

Sử dụng skill này khi cần **cập nhật yêu cầu nghiệp vụ**, **khắc phục bug logic**, **bổ sung trường hợp biên** hoặc **nâng cấp phiên bản (SemVer Bump)** cho một feature đã tồn tại trong `.sdd/features/{feature-slug}/SPEC.md`.

Skill đảm bảo tuân thủ triệt để triết lý **"Fix the Spec, NOT the Code"**, tự động ghi nhật ký thay đổi (`Changelog`) và kích hoạt quy trình đồng bộ lại Kế hoạch/Code/Test.

## Tham số
- `--feature=<feature-slug>`: (Bắt buộc) Tên định danh feature cần cập nhật (e.g. `feat-001-user-auth`).
- `--bump=<major|minor|patch>`: (Bắt buộc) Mức độ nâng cấp phiên bản Semantic Versioning:
  - `patch`: Sửa lỗi nhỏ, bổ sung điều kiện biên/xử lý lỗi, làm rõ Spec mà không thêm chức năng mới lớn (e.g. `v1.0.0` ➔ `v1.0.1`).
  - `minor`: Bổ sung tính năng/yêu cầu EARS mới tương thích ngược, không phá vỡ hợp đồng API/DB hiện tại (e.g. `v1.0.0` ➔ `v1.1.0`).
  - `major`: Thay đổi lớn phá vỡ hợp đồng API (Breaking Changes), đổi Data Schema cốt lõi (e.g. `v1.0.0` ➔ `v2.0.0`).
- `--reason="<nội dung lý do>"`: (Bắt buộc) Nội dung tóm tắt lý do cập nhật Spec để ghi vào Changelog.
- `--req="<nội dung EARS requirement>"`: (Tùy chọn) Nội dung yêu cầu EARS mới hoặc điều chỉnh.

---

## Các công việc Skill thực hiện tự động (5 Bước)

### 1. Kiểm tra Trạng thái & Đọc Spec Hiện tại
- Đọc file `.sdd/features/{feature-slug}/SPEC.md`.
- Trích xuất phiên bản hiện tại (e.g. `v1.0.0`), trạng thái (`APPROVED & LOCKED`) và danh sách các `REQ-XXX` đang có.

### 2. Tính toán & Nâng cấp Phiên bản Semantic Versioning (SemVer Bump)
Dựa trên tham số `--bump`:
- Calculate Version mới: `v1.0.0` ➔ `v1.0.1` (`patch`) | `v1.1.0` (`minor`) | `v2.0.0` (`major`).
- Cập nhật header file `SPEC.md`:
  ```markdown
  # Version: 1.0.1 (SemVer)
  # Status: APPROVED & LOCKED
  ```

### 3. Cập nhật Yêu cầu Nghiệp vụ (EARS Notation)
- Thêm mới hoặc chỉnh sửa các `[REQ-XXX]` trong mục `## 3. Functional Requirements`:
  - Đảm bảo giữ đúng chuẩn cú pháp EARS (`WHEN / WHILE / WHERE / IF ... SHALL ...`).
  - Nếu thêm `REQ` mới, tự động lấy ID tiếp theo (e.g. `REQ-012`).

### 4. Ghi Nhật ký Thay đổi (Changelog Protocol)
Tự động chèn dòng lịch sử vào mục `## 9. Revision & Changelog` ở cuối file `SPEC.md`:
```markdown
### v1.0.1 (2026-08-21) - [Patch Bump]
- Author: [Human Director / Agent]
- Reason: [Nội dung truyền từ --reason]
- Changes:
  - Updated REQ-003: Reduced OTP expiration time from 5 mins to 2 mins.
  - Added REQ-012: Added Rate Limit 3 attempts per minute for OTP resend.
```

### 5. Cập nhật Registry & Khởi động Đồng bộ Downstream (Re-sync Protocol)
- Cập nhật phiên bản mới của feature vào Master Registry `.sdd/README.md`.
- Xuất hướng dẫn và tự động đề xuất lệnh thực thi tiếp theo:
  - Nếu `patch`: Chạy ngay `/add-execute --feature={<feature-slug>}` để Agent cập nhật Code và Test cases.
  - Nếu `minor` hoặc `major`: Chạy `/sdd-tasks --feature={<feature-slug>}` để phân rã thêm Tasks mới, sau đó chạy `/add-execute --feature={<feature-slug>}`.
