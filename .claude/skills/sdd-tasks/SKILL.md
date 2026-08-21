---
name: sdd-tasks
description: Pha 3 SDD - Phân rã Kế hoạch (.sdd/features/{feature-slug}/PLAN.md) thành Atomic Tasks (.sdd/features/{feature-slug}/TASKS.md) kèm DoD Checklist
user-invocable: true
---

# Skill: SDD Phase 3 — Task Decomposition (`/sdd-tasks`)

Sử dụng skill này dựa trên `.sdd/features/{feature-slug}/PLAN.md` để phân rã dự án thành các atomic tasks tại `.sdd/features/{feature-slug}/TASKS.md`.

## Tham số
- `--feature=<feature-slug>`: Tên định danh feature.

## Quy trình thực hiện (4 Bước)

1. **Phân rã Task theo Nguyên tắc 3 Nguyên tử**:
   - **Atomic**: Không thể chia nhỏ hơn.
   - **Independent**: Thực thi độc lập hoặc có thứ tự dependency rõ ràng.
   - **Verifiable**: Mỗi task có test case cụ thể (Definition of Done).

2. **Gắn EARS Traceability**:
   - Trích dẫn requirement từ SPEC (`@ears SPEC.md#REQ-XXX`) hoặc `CONSTITUTION.md`.

3. **Cập nhật `.sdd/shared_context.md`**:
   - Ghi nhận API Contracts tĩnh dùng chung giữa các feature.

4. **Đối chiếu Checklist Definition of Done (DoD) & Xuất File**:
   - Kiểm tra DoD Checklist bên dưới trước khi xuất file.
   - Ghi file `.sdd/features/{feature-slug}/TASKS.md`.

---

## 📋 CHECKPOINT CHECKLIST (Definition of Done — Pha 3)
- [ ] Mọi task đạt nguyên tắc **Atomic** (không thể chia nhỏ hơn).
- [ ] Mọi task đạt nguyên tắc **Independent** (hoặc khai báo rõ thứ tự phụ thuộc `blockedBy`).
- [ ] Mọi task đạt nguyên tắc **Verifiable** (có lệnh test cụ thể để verify).
- [ ] 100% tasks đều có JSDoc Traceability trích dẫn từ Spec (`@ears SPEC.md#REQ-XXX`).
- [ ] Hợp đồng API dùng chung đã được đồng bộ vào `.sdd/shared_context.md`.

---

## Template `.sdd/features/{feature-slug}/TASKS.md`

```markdown
# PHASE 3: ATOMIC TASK DECOMPOSITION (TASKS.md)

# Feature: [Tên Feature]
# Status: IN_PROGRESS

---

## Task Breakdown

### Phase 3.1: Foundational Setup
- [ ] **`T001`**: Implement Domain Entities
  - **Files**: `src/domain/entities/...`
  - **Verifiable**: `npm test ...` passes
  - **Requirement**: `@ears SPEC.md#REQ-XXX`

### Phase 3.2: Infrastructure Implementation
- [ ] **`T002`**: Implement Repository / Cache
  - **Files**: `src/infra/...`
  - **Verifiable**: Integration tests pass

### Phase 3.3: Usecase Core Logic
- [ ] **`T003`**: Implement Usecase Workflow
  - **Files**: `src/usecase/...`
  - **Verifiable**: Unit tests pass 100%
```

---

## AI Recommendation & Human Final Review

After generating or changing `TASKS.md`, persist the canonical recommendation from `.claude/skills/_shared/ai-review-protocol.md`. Include task ordering, dependencies, affected files, verification commands, and delivery risks. Keep `Human Final Review.Status: PENDING`; `/add-execute` may not start from these tasks until the Human Director records `APPROVED`. The Agent must not mark the task plan approved by itself.
