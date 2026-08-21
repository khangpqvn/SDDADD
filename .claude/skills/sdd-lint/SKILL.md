---
name: sdd-lint
description: Linting và kiểm định cú pháp đặc tả EARS Notation, cấu trúc SemVer và mở rộng điều kiện biên cho SPEC.md
user-invocable: true
---

# Skill: SDD Spec Linter (`/sdd-lint`)

Sử dụng skill này để linter và thẩm định file `.sdd/features/{feature-slug}/SPEC.md` nhằm phát hiện các câu từ mập mờ, vi phạm định dạng EARS hoặc thiếu trường hợp biên trước khi khóa Spec (LOCKED).

## Tham số
- `--feature=<feature-slug>`: Tên feature slug cần lint.

## Quy trình Kiểm tra (4 Bước)

1. **Phân tích Cú pháp EARS Notation**:
   - Kiểm tra xem 100% Functional Requirements có viết theo đúng 5 mẫu EARS không:
     - **Ubiquitous**: `The <system> SHALL <action>`
     - **Event-driven**: `WHEN <trigger>, the <system> SHALL <action>`
     - **State-driven**: `WHILE <in state>, the <system> SHALL <action>`
     - **Optional**: `WHERE <feature is included>, the <system> SHALL <action>`
     - **Unwanted**: `IF <error/invalid condition>, THEN the <system> SHALL <action>`
   - Cảnh báo các câu từ mập mờ (vague terms): *"nhanh chóng"*, *"giao diện đẹp"*, *"xử lý linh hoạt"*, *"nếu cần thiết"*.

2. **Kiểm tra Ma trận Xử lý Lỗi (Unwanted Behavior Coverage)**:
   - Đảm bảo mỗi happy path (`WHEN`) đều có ít nhất 1 kịch bản `IF ... THEN ...` tương ứng xử lý lỗi (Timeout, Duplicate, Invalid Input, Unauthorized).

3. **Kiểm tra Đánh số REQ & Metadata Header**:
   - Kiểm tra mã `REQ-XXX` có duy nhất và liên tục không.
   - Kiểm tra header chứa trạng thái (`DRAFT` / `APPROVED & LOCKED`) và phiên bản SemVer (`vX.Y.Z`).

4. **Báo cáo Lỗi & Đề xuất Sửa đổi**:
   - In ra danh sách warning/error chi tiết kèm dòng bị lỗi.
   - Đề xuất câu EARS sửa đổi chuẩn hóa.
