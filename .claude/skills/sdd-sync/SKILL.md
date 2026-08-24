---
name: sdd-sync
description: Đồng bộ Master Feature Registry và shared contract trong .sdd
user-invocable: true
---

# SDD Registry Sync (`/sdd-sync`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `APPROVED`, `CONFIGURATION GAP`), file paths, and CLI commands are language-invariant.

Dùng để quét và cập nhật Master Feature Registry (`.sdd/README.md`) cùng shared API/state contract (`.sdd/shared_context.md`) sau khi feature thay đổi.

## Architecture Profile reference

Tuân thủ [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md).

- Đọc `.sdd/architecture-profile.md` trước khi trích xuất/cập nhật shared contract.
- Chỉ ghi HTTP route, event schema, DTO validator, persistence identifier và command khi profile binding/evidence tương ứng đã `APPROVED`.
- Binding chưa chọn: ghi behavior và data shape technology-neutral; không thêm framework route syntax, decorator, ORM schema hoặc command suy đoán.
- Artifact feature mâu thuẫn profile `APPROVED`: giữ evidence, báo `CONFIGURATION GAP` và yêu cầu Human Director disposition; không tự rewrite contract.

## Tham số

Không có tham số bắt buộc.

## Quy trình

1. Quét thư mục `.sdd/features/`; đọc header từng `SPEC.md` để lấy status, SemVer và số `REQ-XXX`.
2. Cập nhật `.sdd/README.md` với feature path, version và status hiện tại.
3. Tổng hợp data contract, transport/event contract và state definition được evidence xác nhận; chỉ dùng adapter syntax đã approved.
4. Cập nhật `.sdd/shared_context.md` mà không làm đứt shared contract; ghi profile reference khi binding unresolved.

## AI Recommendation và Human Final Review

Sau synchronization, tạo canonical recommendation từ `.claude/skills/_shared/ai-review-protocol.md`, gồm changed feature, contract impact, drift evidence và residual integration risk. Lưu tại `.sdd/reviews/sync.md` với `PENDING HUMAN REVIEW`. Human Director review synchronization trước delivery downstream; Agent không tự kết luận registry hoặc contract đã `APPROVED`.
