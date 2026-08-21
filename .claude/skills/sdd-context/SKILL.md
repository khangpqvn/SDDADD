---
name: sdd-context
description: Pha 0 SDD - Khai phá Ngữ cảnh (Context Discovery) và tạo file .sdd/features/{feature-slug}/CONTEXT.md kèm DoD Checklist
user-invocable: true
---

# Skill: SDD Phase 0 — Context Discovery (`/sdd-context`)

Sử dụng skill này khi bắt đầu một feature mới để khai phá bài toán nghiệp vụ, thu thập thông tin và tạo file `.sdd/features/{feature-slug}/CONTEXT.md`.

## Tham số
- `--feature=<feature-slug>`: Tên định danh feature (dạng kebab-case, e.g., `feat-001-order-checkout`). Nếu không truyền, skill sẽ hỏi user tên feature slug.

## Quy trình thực hiện (5 Bước)

1. **Xác định Feature Slug & Thư mục**:
   - Đường dẫn mục tiêu: `.sdd/features/{feature-slug}/CONTEXT.md`.

2. **Thu thập thông tin bài toán (Problem Statement)**:
   - Thu thập thông tin về lý do làm feature, nỗi đau của user/khách hàng (Pain Points).
   - Tránh suy nghĩ về giải pháp kỹ thuật (Solution thinking) ở bước này; chỉ tập trung vào vấn đề nghiệp vụ.

3. **Xác định Từ điển Domain (Domain Knowledge & Glossary)**:
   - Liệt kê các thuật ngữ chuyên ngành, trạng thái thực thể (Entities/States), và quy tắc nghiệp vụ.

4. **Xác định Stakeholders & Constraint**:
   - Xác định người sở hữu quyết định nghiệp vụ (Product Owner/PM).
   - Ràng buộc cứng không thể thay đổi (Tech Stack, SLA performance, Security/Compliance từ `CONSTITUTION.md`).

5. **Đối chiếu Checklist Definition of Done (DoD) & Xuất File**:
   - Kiểm tra DoD Checklist bên dưới trước khi hoàn thành.
   - Ghi nội dung vào `.sdd/features/{feature-slug}/CONTEXT.md` và cập nhật `.sdd/README.md`.

---

## 📋 CHECKPOINT CHECKLIST (Definition of Done — Pha 0)
- [ ] Team/Agent hiểu rõ domain & bài toán thực sự (Problem Statement, không giải pháp vội).
- [ ] Đã đồng thuận về định nghĩa các thuật ngữ trong Domain Glossary.
- [ ] Ràng buộc cứng (Tech, Business, Time) đã liệt kê đầy đủ.
- [ ] Đã xác định rõ người quyết định cuối cùng (Decision Maker/Stakeholder).
- [ ] Không còn Open Questions quan trọng chưa được trả lời (hoặc đã nêu rõ giả định minh bạch).

---

## Template `.sdd/features/{feature-slug}/CONTEXT.md`

```markdown
# PHASE 0: CONTEXT DISCOVERY DOCUMENT

# Feature: [Tên Feature]
# Feature Slug: [feature-slug]
# Version: 1.0.0
# Author: [Human Director / Agent]

---

## 1. Problem Statement & Pain Points
- **Current Situation**: ...
- **User Pain Point**: ...
- **Desired Behavior**: ...

## 2. Domain Knowledge & Glossary
- **Term 1**: Description...
- **State 1**: Description...

## 3. Stakeholders & Decision Makers
- **Business Owner**: ...
- **Tech Lead**: ...

## 4. Hard Constraints
- **Tech Stack**: ...
- **SLA Performance**: ...

## 5. Assumptions & Open Questions
- **Assumption 1**: ...
- **Open Question 1**: ...
```
