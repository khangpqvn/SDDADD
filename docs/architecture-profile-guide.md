# Hướng dẫn Hồ sơ kiến trúc

`.sdd/architecture-profile.md` là nguồn chuẩn cho **technology binding** và **exact verification command**. Đọc Profile trước khi lập Plan, chia Tasks hoặc execute.

## Khi nào được tiếp tục?

Feature chỉ được vào technical work khi mọi binding liên quan đã có:

- `APPROVED` status;
- evidence trỏ tới manifest, config, source hoặc Human decision;
- exact verification command khớp với evidence.

Nếu thiếu hoặc mâu thuẫn, status đúng là `PENDING HUMAN REVIEW` hoặc `BLOCKED`. Không tự chọn framework, database, ORM/query layer, validation library, cache/broker, test/build/lint command hay deployment tooling.

## Thứ tự chọn binding

```text
Architecture Profile đã APPROVED
→ repository evidence rõ ràng
→ input kỹ thuật explicit
→ core-only baseline
```

Evidence mâu thuẫn là configuration blocker. Ghi file đã kiểm tra, rủi ro và decision Human cần đưa ra; không chọn một bên theo suy đoán.

## Core-only baseline của starter

Starter chỉ xác nhận TypeScript, Node.js, Clean/Hexagonal Architecture và layout core. Baseline không tự chọn transport, database, query layer, validation, cache/broker hoặc command kiểm thử/build/lint.

## Checklist trước Plan, Tasks hoặc execution

- [ ] Binding liên quan feature là `APPROVED`.
- [ ] Evidence có path cụ thể và còn đúng.
- [ ] Exact verification command tồn tại.
- [ ] Plan/Tasks/Shadow Plan chỉ dùng binding và command đã approved.
- [ ] Stack hoặc command change đã đánh giá impact lên artifact downstream.
- [ ] Human review được persist bằng `/sdd-review` khi cần.

## Greenfield

1. Tạo Context và Spec theo hướng technology-neutral.
2. Xác định behavior kỹ thuật thật sự cần feature.
3. Cập nhật Profile với binding, evidence, command và configuration gap.
4. Human review Profile.
5. Chạy `/sdd-plan` rồi `/sdd-tasks`.

Profile approval chỉ duyệt nội dung đã trình bày; không tự lấp field còn thiếu.

## Brownfield

`/sdd-adopt` thu thập evidence từ manifest, lockfile, runtime bootstrap, DB/migration config, CI, test config và source layout. Chỉ chọn binding có evidence rõ. Mâu thuẫn cần Human decision trước khi lập Plan.

## Khi Profile thay đổi

1. Xác định Context/Spec/Plan/Tasks/code/tests/contracts bị ảnh hưởng.
2. Dùng `/sdd-update` nếu behavior hoặc artifact thay đổi.
3. Review lại artifact downstream bị invalidate.
4. Chỉ chạy command từ Profile mới sau khi được duyệt.

## Ví dụ review Profile

```text
/sdd-review --target=.sdd/architecture-profile.md --status=APPROVED \
  --decision="Đã duyệt binding và command cho scope feature." \
  --reviewer="<human reviewer>" \
  --follow-up="/sdd-plan --feature=<slug>"
```

Các option và review field thực tế phải theo `.claude/skills/sdd-review/SKILL.md`.

## Đọc tiếp

- [Bắt đầu nhanh](./sdd-add-quickstart.md)
- [Hướng dẫn vận hành](./sdd-add-guide.md)
- [Tra cứu nhanh](./sdd-add-field-guide.md)
- [Hướng dẫn execution](./multi-agent-orchestration-guide.md)
