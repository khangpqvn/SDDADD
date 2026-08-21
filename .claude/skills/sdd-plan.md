---
name: sdd-plan
description: Pha 2 SDD - Lập Kế hoạch Kiến trúc (.sdd/features/{feature-slug}/PLAN.md), Data Flow và Đánh giá Rủi ro kèm DoD Checklist
---

# Skill: SDD Phase 2 — Architecture Planning (`/sdd-plan`)

Sử dụng skill này dựa trên `.sdd/features/{feature-slug}/SPEC.md` và `CONSTITUTION.md` để tạo ra bản thiết kế kỹ thuật `.sdd/features/{feature-slug}/PLAN.md`.

## Tham số
- `--feature=<feature-slug>`: Tên định danh feature.

## Quy trình thực hiện (5 Bước)

1. **Phân tích Kiến trúc (Architectural Layers)**:
   - Tuân thủ Clean Architecture từ `CLAUDE.md`.
   - Liệt kê các Component và File Paths tương ứng sẽ tạo/sửa.

2. **Vẽ Luồng Dữ liệu (Data Flow Diagram)**:
   - Vẽ tương tác: Client ➔ Controller ➔ Usecase ➔ Repository/Cache ➔ DB.

3. **Đánh giá Rủi ro & Giải pháp (Risk Assessment)**:
   - Liệt kê ít nhất 3 rủi ro kỹ thuật (Race condition, Security, Performance) và cách giảm thiểu.

4. **Trích xuất Questions for Human**:
   - Liệt kê tất cả các thắc mắc về technical implementation mà Spec chưa chỉ định.

5. **Đối chiếu Checklist Definition of Done (DoD) & Xuất File**:
   - Chạy DoD Checklist bên dưới trước khi trình Human Lead phê duyệt.
   - Ghi file `.sdd/features/{feature-slug}/PLAN.md`.

---

## 📋 CHECKPOINT CHECKLIST (Definition of Done — Pha 2)
- [ ] Phác thảo rõ ràng cách tiếp cận kiến trúc (Clean Architecture / Pattern).
- [ ] Danh sách các Components có đủ tên, trách nhiệm và file paths tương ứng.
- [ ] Luồng dữ liệu (Data Flow Diagram) thể hiện đầy đủ từ HTTP Request đến DB Storage & Response.
- [ ] Phân tích ít nhất 3 rủi ro kỹ thuật kèm phương án giảm thiểu (Mitigation Strategy).
- [ ] Mục `Questions for Human` đã trích xuất các giả định ẩn hoặc được Human Director phê duyệt.

---

## Template `.sdd/features/{feature-slug}/PLAN.md`

```markdown
# PHASE 2: TECHNICAL ARCHITECTURE PLAN (PLAN.md)

# Feature: [Tên Feature]
# Feature Slug: [feature-slug]
# Target Spec Version: 1.0.0
# Version: 1.0.0
# Status: APPROVED

---

## 1. Architectural Approach & Layers
- Mô tả các tầng Clean Architecture...

## 2. Component Design & Responsibilities
| Component Name | File Path | Responsibility |
| :--- | :--- | :--- |

## 3. Data Flow Diagram
```text
[Client] -> [Controller] -> [Usecase] -> [Infra] -> [DB]
```

## 4. Risk Assessment & Mitigations
| Identified Risk | Impact | Likelihood | Mitigation Strategy |
| :--- | :--- | :--- | :--- |

## 5. Questions for Human Director
1. Question 1...
```
