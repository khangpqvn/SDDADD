---
name: sdd-update
description: Cập nhật SPEC.md, bump SemVer, ghi changelog và đồng bộ downstream artifact theo profile
user-invocable: true
---

# SDD Feature Update và SemVer Bump (`/sdd-update`)

Dùng khi cập nhật business requirement, xử lý Spec gap hoặc đổi behavior trong `.sdd/features/{feature-slug}/SPEC.md`.

## Tham số

- `--feature=<feature-slug>`: Bắt buộc; feature cần cập nhật.
- `--bump=<major|minor|patch>`: Bắt buộc; mức SemVer.
- `--reason="<lý-do>"`: Bắt buộc; tóm tắt lý do trong changelog.
- `--req="<EARS requirement>"`: Tùy chọn; requirement mới/điều chỉnh.

## Các bước

1. Đọc Spec, version, status và `REQ-XXX` hiện có.
2. Tính version mới: `patch` cho làm rõ/sửa tương thích, `minor` cho behavior tương thích mới, `major` cho breaking contract.
3. Đặt `SPEC.md` thành `DRAFT`, `Human Final Review: PENDING`; không giữ lock cũ.
4. Cập nhật EARS requirement, BDD, error, acceptance, Out of Scope và changelog.
5. Đọc Architecture Profile. Nếu thay đổi cần transport, persistence, validation, cache, messaging hay tooling mới, tạo profile recommendation và invalidate Plan/Tasks cũ.
6. Chỉ đề xuất execution khi binding/command cần thiết đã `APPROVED` và có evidence; binding unresolved thì dừng ở `PENDING HUMAN REVIEW`.

## AI Recommendation và Human Final Review

Sau khi đề xuất hoặc áp dụng Spec update, lưu canonical recommendation trong `SPEC.md`, gồm thay đổi, SemVer impact, requirement bị ảnh hưởng, migration risk và downstream file. `/add-execute` hoặc task breakdown mới bị block đến khi Human Director approve. Mọi sửa tiếp theo làm review cũ mất hiệu lực; Agent không self-approve changed contract.
