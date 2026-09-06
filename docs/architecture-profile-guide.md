# Hướng dẫn Hồ sơ kiến trúc

`.sdd/architecture-profile.md` là nguồn chuẩn cho tech binding và exact verification command. Dùng tài liệu này trước Plan, Tasks hoặc technical execution.

## Khi phải dừng

Feature cần HTTP, database, ORM/query layer, validation, cache, broker, test/build/lint command mà Profile chưa có binding/evidence/command `APPROVED` thì dừng. Context và Spec vẫn có thể business-neutral.

## Thứ tự chọn binding

```text
approved Architecture Profile
→ clear repository evidence
→ explicit command input
→ core-only baseline
```

Evidence mâu thuẫn là configuration blocker. Ghi `PENDING HUMAN REVIEW` với file đã kiểm tra, risk và Human decision cần có; không tự chọn một bên.

## Core-only baseline

Starter chỉ xác nhận TypeScript + Node.js + Clean Architecture / Hexagonal Architecture. Baseline không chọn transport, database, query layer, validation, cache/broker, test/build/lint command hay deployment tooling. Không thay bằng command suy đoán.

## Checklist trước Plan/Tasks/execute

- [ ] Binding liên quan feature là `APPROVED`.
- [ ] Evidence trỏ manifest, config, source hoặc durable Human decision.
- [ ] Exact verification command tồn tại và khớp evidence.
- [ ] Plan/Tasks/Shadow Plan chỉ dùng binding/command đã approved.
- [ ] Stack change đã invalidate/review artifact downstream phù hợp.

## Greenfield

1. Tạo/review Context và Spec.
2. Xác định behavior kỹ thuật của feature.
3. Ghi binding, evidence, exact command và configuration gaps trong Profile.
4. Human review Profile; review không hợp thức hóa field còn thiếu.
5. Chỉ sau đó chạy `/sdd-plan` và `/sdd-tasks`.

## Brownfield

`/sdd-adopt` lấy evidence từ manifest, lockfile, runtime bootstrap, DB/migration config, CI, test config và source layout. Chỉ chọn binding có evidence rõ; mâu thuẫn cần Human decision.

## Khi Profile thay đổi

Review Profile, đánh giá Context/Spec/Plan/Tasks/code/tests/contracts bị ảnh hưởng, dùng `/sdd-update` khi behavior/artifact đổi, rồi chỉ chạy command từ Profile mới được duyệt.

## Xem thêm

- [Bắt đầu nhanh](./sdd-add-quickstart.md)
- [Hướng dẫn vận hành](./sdd-add-guide.md)
- [Tra cứu nhanh](./sdd-add-field-guide.md)
- [Agent execution và orchestration](./multi-agent-orchestration-guide.md): chọn direct hoặc orchestrated độc lập với Human project ownership.
