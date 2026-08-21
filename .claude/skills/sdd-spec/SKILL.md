---
name: sdd-spec
description: Pha 1 SDD - Viết Executable Specification (.sdd/features/{feature-slug}/SPEC.md) dùng EARS Notation, SemVer và DoD Checklist
user-invocable: true
---

# Skill: SDD Phase 1 — Specification (`/sdd-spec`)

Sử dụng skill này dựa trên `.sdd/features/{feature-slug}/CONTEXT.md` và `CONSTITUTION.md` để khởi tạo file đặc tả kỹ thuật `.sdd/features/{feature-slug}/SPEC.md`.

## Tham số
- `--feature=<feature-slug>`: Tên định danh feature. Nếu không truyền, skill sẽ hỏi user tên feature slug.
- `--bump=<major|minor|patch>`: (Dùng khi cập nhật spec) Bump phiên bản Semantic Versioning cho Spec.

## Quy trình thực hiện (6 Bước)

1. **Đọc Context & Constitution**:
   - Đọc `.sdd/features/{feature-slug}/CONTEXT.md` và `CONSTITUTION.md` ở root.

2. **Gắn Header Semantic Versioning & State**:
   - Khai báo phiên bản `Version: x.y.z (SemVer)` và trạng thái `DRAFT`.
   - Chỉ Human Director/Tech Lead được chuyển trạng thái sang `APPROVED & LOCKED` sau khi duyệt recommendation trong artifact.

3. **Áp dụng EARS Notation cho Requirements**:
   - *Ubiquitous*: `THE system SHALL [action]`
   - *Event-Driven*: `WHEN [event], THE system SHALL [action]`
   - *State-Driven*: `WHILE [state], THE system SHALL [action]`
   - *Optional*: `WHERE [feature], THE system SHALL [action]`
   - *Unwanted*: `IF [error condition], THEN THE system SHALL [action]`

4. **Định nghĩa Data Model Contract & BDD Scenarios**:
   - Viết TypeScript Interface (bao gồm soft-delete `deleted_at`).
   - Viết các kịch bản nghiệm thu `GIVEN-WHEN-THEN`.

5. **Xác định Phạm vi Cấm (Out of Scope)**:
   - Liệt kê các tính năng KHÔNG làm để tránh AI hallucinate/thêm thừa tính năng.

6. **Đối chiếu Checklist Definition of Done (DoD) & Lock Spec**:
   - Chạy DoD Checklist bên dưới trước khi commit & tag spec.
   - Ghi vết Changelog vào cuối file `SPEC.md`.

---

## 📋 CHECKPOINT CHECKLIST (Definition of Done — Pha 1)
- [ ] SPEC.md có đủ 8 thành phần cốt lõi (Context, Actors, Functional, NFR, Data, Error, Acceptance, Out of Scope).
- [ ] 100% Functional Requirements dùng EARS Notation (`WHEN/WHILE/WHERE/IF... SHALL...`).
- [ ] Đã qua bước AI Clarification/Review để phát hiện và resolve logic gaps.
- [ ] Không còn Open Questions tồn đọng từ Pha 0.
- [ ] Mục `Out of Scope` được liệt kê rõ ràng, không mập mờ.
- [ ] Spec có Semantic Versioning (SemVer) và trạng thái `APPROVED & LOCKED` (đã qua Human Director review).

---

## Template `.sdd/features/{feature-slug}/SPEC.md`

```markdown
# PHASE 1: EXECUTABLE SPECIFICATION (SPEC.md)

# Feature: [Tên Feature]
# Feature Slug: [feature-slug]
# Version: 1.0.0 (SemVer)
# Status: DRAFT
# Owner: [Human Director / Lead]
# Human Final Review: PENDING

> Human Director/Tech Lead restores `APPROVED & LOCKED` only after reviewing the persisted recommendation.


---

## 1. Context & Goal
- **Business Goal**: ...
- **Success Metric**: ...

## 2. Actors & Roles
| Actor | Description | Permissions |
| :--- | :--- | :--- |

## 3. Functional Requirements (EARS Notation)
- `[REQ-001]` WHEN ... THE system SHALL ...
- `[REQ-002]` IF ... THEN THE system SHALL ...

## 4. Non-Functional Requirements (NFR)
- **NFR-PERF-01**: ...

## 5. Data Model Schema Contract
```typescript
interface SampleEntity {
  id: string;
  created_at: Date;
  deleted_at: Date | null;
}
```

## 6. Error Handling
| Scenario | Trigger | Error Code | HTTP Status | Mitigation |
| :--- | :--- | :--- | :--- | :--- |

## 7. Acceptance Criteria (BDD Format)
- **GIVEN** ...
- **WHEN** ...
- **THEN** ...

## 8. Out of Scope
- ❌ KHÔNG làm ...

---

## 9. Revision & Changelog
### v1.0.0 (2026-08-21)
- Initial draft Spec Version pending Human Final Review.
```

---

## AI Recommendation & Human Final Review

After drafting or changing `SPEC.md`, generate the canonical recommendation from `.claude/skills/_shared/ai-review-protocol.md` and persist it in the artifact. Include requirement gaps, EARS risks, edge cases, out-of-scope boundaries, and SemVer impact. Keep `Human Final Review.Status: PENDING`; `/sdd-plan` is blocked until the Human Director records `APPROVED`. Any later Spec change invalidates the prior review. The Agent must not set `APPROVED & LOCKED` on behalf of a human.
