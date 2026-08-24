---
name: sdd-context
description: Pha 0 SDD — khám phá ngữ cảnh và tạo .sdd/features/{feature-slug}/CONTEXT.md
user-invocable: true
---

# SDD Phase 0 — Context Discovery (`/sdd-context`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `PENDING`, `APPROVED`), file paths, and CLI commands are language-invariant.

Dùng khi bắt đầu feature để làm rõ bài toán nghiệp vụ và tạo `CONTEXT.md`.

## Tham số

- `--feature=<feature-slug>`: Feature identifier kebab-case, ví dụ `feat-001-order-checkout`.

> **Cập nhật CONTEXT.md đã approved?** Dùng `/sdd-update --artifact=context --reason="..."` thay vì chạy lại skill này. `/sdd-context` dùng để tạo Context lần đầu hoặc làm lại khi yêu cầu thay đổi hoàn toàn.

## Architecture Profile preflight

Tuân thủ [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md).

- Đọc profile và governance bắt buộc.
- `CONTEXT.md` được tạo với core-only baseline; không chọn HTTP framework, DB, ORM, validation library hoặc test command.
- Ghi profile version, baseline, evidence và chỉ unknown liên quan feature.
- Evidence mâu thuẫn profile thì dừng và tạo `PENDING HUMAN REVIEW` recommendation.

## Các bước

1. Tạo `.sdd/features/{feature-slug}/CONTEXT.md`.
2. Thu thập problem, user pain và desired behavior; chưa thiết kế giải pháp kỹ thuật.
3. Lập domain glossary, entity/state và business rule.
4. Xác định stakeholder, decision maker, business constraint và open question.
5. Kiểm tra DoD, ghi artifact và cập nhật `.sdd/README.md`.

## DoD

- [ ] Team hiểu problem, không nhầm với solution.
- [ ] Domain glossary rõ nghĩa.
- [ ] Tech, business và time constraint đã ghi.
- [ ] Có decision maker rõ ràng.
- [ ] Open question quan trọng đã trả lời hoặc có assumption minh bạch.

## AI Recommendation và Human Final Review

Sau khi tạo/sửa `CONTEXT.md`, lưu canonical recommendation trong artifact, gồm business question, assumption, stakeholder, constraint và alternative. Giữ `Human Final Review.Status: PENDING`. Chỉ chuyển sang `/sdd-spec` sau `APPROVED` có decision, reviewer và timestamp. Agent phải dừng, không self-approve.
