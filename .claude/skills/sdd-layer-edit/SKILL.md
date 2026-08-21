---
name: sdd-layer-edit
description: Chỉnh sửa đồng bộ mã nguồn qua 4 tầng kiến trúc (Domain, Usecase, Interface, Infra) đảm bảo đúng ranh giới ARCH-01 và EARS Tagging
user-invocable: true
---

# Skill: SDD Cross-Layer Editor (`/sdd-layer-edit`)

Sử dụng skill này khi cần thêm mới hoặc thay đổi một luồng nghiệp vụ đi xuyên qua 4 tầng Clean Architecture (`domain` ➔ `usecase` ➔ `interface` ➔ `infra`) mà không vi phạm quy tắc ranh giới kiến trúc.

## Tham số
- `--feature=<feature-slug>`: Feature slug chứa Spec tương ứng.
- `--action=<add|modify|refactor>`: Hành động thay đổi (Thêm mới, sửa đổi hoặc refactor).
- `--target=<name>`: Tên UseCase hoặc Entity mục tiêu (e.g., `CreateOrder`).

## Quy trình Thực hiện (4 Tầng)

### 1. Tầng Domain (`src/domain/`):
- Thêm/Sửa Entity, Value Object hoặc Domain Event.
- **Ràng buộc cứng**: Pure TypeScript, tuyệt đối KHÔNG import thư viện 3rd party hay bất kỳ layer nào khác.

### 2. Tầng Usecase (`src/usecase/`):
- Thêm/Sửa Interactor / Application Service.
- Định nghĩa Port Interface cho Repository và External Services.
- **Bắt buộc**: Gắn JSDoc tag `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX` cho mọi method nghiệp vụ.

### 3. Tầng Interface (`src/interface/`):
- Thêm/Sửa HTTP Controller, Event Consumer, Presenter & DTO Schema validation.
- **Bắt buộc**: Bọc Authentication Middleware cho các route thay đổi trạng thái (`SEC-02`).
- **Cấm**: KHÔNG được import hoặc gọi trực tiếp DB Repository. Chỉ gọi Usecase Interactor.

### 4. Tầng Infra (`src/infra/`):
- Thêm/Sửa DB Repository implementation, Redis Cache Adapter, External Client.
- **Bắt buộc**: Sử dụng Soft-Delete (`deleted_at TIMESTAMP`) cho lệnh xóa (`DATA-01`). KHÔNG dùng `DELETE FROM`.
- **Bắt buộc**: Không hardcode API Key hay Password (`SEC-01`).
