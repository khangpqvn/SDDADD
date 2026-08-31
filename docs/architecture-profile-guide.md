# Hướng dẫn Hồ sơ kiến trúc
# Version: 1.1.0

`.sdd/architecture-profile.md` là nguồn máy đọc được dùng làm chuẩn cho tech binding và exact verification command. `CLAUDE.md` chỉ phản ánh kiến trúc đã được duyệt để con người đọc; file này không tự chọn stack.

## Dùng hướng dẫn này khi nào?

Đọc tài liệu này trước khi tạo `PLAN.md`, `TASKS.md` hoặc chạy technical execution nếu feature cần HTTP, database, ORM/query layer, validation, cache, broker, test, build hoặc lint command.

**Kết quả cần có:** Hồ sơ kiến trúc chỉ ra binding liên quan, evidence nguồn và command có thể chạy. Nếu thiếu một trong các mục này, dừng technical planning và ghi `PENDING HUMAN REVIEW`.

## Thứ tự chọn binding

Luôn kiểm tra theo đúng thứ tự sau:

```text
approved Architecture Profile
→ clear repository evidence
→ explicit command input
→ core-only baseline
```

Nếu hai nguồn mâu thuẫn, đây là configuration blocker. Không tự chọn bên nào. Hãy ghi recommendation `PENDING HUMAN REVIEW`, nêu file đã kiểm tra, rủi ro và quyết định Human cần đưa ra.

## Core-only baseline có nghĩa gì?

Starter chỉ xác nhận:

```text
TypeScript + Node.js + Clean Architecture / Hexagonal Architecture
```

Baseline này **không** chọn HTTP transport, database, ORM/query layer, validation library, cache/broker, test/build/lint command hoặc deployment tooling. Vì vậy, không thay lệnh thiếu bằng `npm`, `pnpm`, `yarn`, placeholder hay framework command suy đoán.

## Artifact nào được phép tiếp tục?

| Artifact/action | Điều kiện để tiếp tục | Nếu chưa đủ |
| :--- | :--- | :--- |
| Context và Spec | Có thể technology-neutral. Ghi unknown và blocker. | Tiếp tục mô tả business behavior, không sinh chi tiết adapter. |
| Plan và Tasks | Cần mọi binding liên quan feature và exact runnable verification command. | Dừng và yêu cầu Human chọn binding/command. |
| Execute và layer edit | Cần artifact prerequisite được duyệt, profile evidence liên quan và exact command. | Không tạo file framework-specific hoặc chạy command. |
| Technical audit | Có thể audit quy tắc framework-neutral. | Trả `CONFIGURATION GAP` cho phần adapter-specific. |

Methodology Profile chỉ điều chỉnh độ sâu, mức rủi ro và route review. Nó không thay evidence, không chọn công nghệ, không tạo command và không vượt gate.

## Dự án mới (greenfield): làm từng bước

1. Khởi tạo template và tạo Context.

   ```text
   /sdd-init --project-name="<name>"
   /sdd-context --feature=<slug>
   ```

2. Lưu Human Final Review `APPROVED` cho Context, rồi mới tạo Spec:

   ```text
   /sdd-spec --feature=<slug>
   ```

3. Chạy `/sdd-lint --feature=<slug>`, sau đó lưu Human Final Review `APPROVED` để lock Spec.
4. Mở `.sdd/architecture-profile.md`. Với mỗi hành vi kỹ thuật của feature, ghi binding cần thiết, evidence và exact command.
5. Đừng tạo Plan/Tasks kỹ thuật khi vẫn còn `BLOCKED`, command rỗng hoặc evidence mâu thuẫn.
6. Gửi profile để Human review bằng command hỗ trợ:

   ```text
   /sdd-review --target=.sdd/architecture-profile.md --status=APPROVED \
     --decision="Approved bindings and exact verification commands for <scope>." \
     --reviewer="<human reviewer>" --follow-up="/sdd-plan --feature=<slug>"
   ```

5. Chỉ khi review hợp lệ, chạy `/sdd-plan --feature=<slug>` rồi `/sdd-tasks --feature=<slug>`.

**Lưu ý:** Review chỉ xác nhận evidence đã trình bày; review không biến binding hoặc command còn thiếu thành hợp lệ.

## Dự án sẵn có (brownfield): làm từng bước

`/sdd-adopt` thu thập evidence từ manifest, lockfile, runtime bootstrap, DB/migration configuration, CI, test configuration và source layout.

Trước khi Human duyệt, kiểm tra từng câu sau:

- Mỗi dependency/binding được chọn có source path chứng minh.
- Layer mapping phản ánh repository thực tế, không phải cấu trúc template mong muốn.
- Input mâu thuẫn đã có quyết định explicit.
- Test/build/lint command chính xác và chạy được trong repository.
- Giá trị discovery chỉ là draft cho đến khi có durable review.

Nếu một câu chưa đúng, để profile ở trạng thái blocker thay vì phỏng đoán để tiếp tục.

## Chọn thông tin theo behavior của feature

| Feature behavior | Profile information cần có trước Plan/Tasks |
| :--- | :--- |
| Route/controller/middleware | transport framework và validation approach |
| Persist/query/migrate | database và query/ORM layer |
| External service/cache/queue | implementation binding của adapter được dùng |
| Test task | exact test command và evidence của nó |
| Build/lint/CI task | exact command và evidence của nó |

Khi thiếu, ghi quyết định cần hỏi, evidence đã xem, rủi ro và review command kế tiếp. Không viết technical plan chưa có nền tảng này.

## Khi cần đổi stack hoặc binding

1. Đề xuất binding, lý do, evidence, migration risk và `PENDING HUMAN REVIEW` trong profile.
2. Human review profile. Nếu kiến trúc dễ đọc cho con người thay đổi, đồng bộ `CLAUDE.md` bằng `/sdd-claude-edit`.
3. Liệt kê Context/Spec/Plan/Tasks/code/tests/contracts mất hiệu lực.
4. Dùng `/sdd-update` khi behavior hoặc artifact thay đổi, rồi review lại phần downstream bị ảnh hưởng.
5. Chỉ chạy command đã được profile mới duyệt.

## Khi điều phối Agent

Lead phải cung cấp cho mỗi sub-agent profile version/status, selected binding/evidence và exact approved command. Sub-agent gặp mismatch hoặc thiếu binding phải dừng; không được mượn tool, tự thêm package hoặc suy ra command để vượt profile gate.

## Checklist trước technical execution

- [ ] Profile có binding `APPROVED` cho mọi behavior kỹ thuật trong scope.
- [ ] Evidence trỏ đến manifest, config, source hoặc durable Human decision.
- [ ] Plan/Tasks chỉ dùng adapter và command đã approved.
- [ ] Shadow Plan nêu profile version, evidence và exact command.
- [ ] Methodology Profile không được dùng để vượt technical gate.
- [ ] Stack change đã làm mất hiệu lực và review lại artifact downstream phù hợp.

## Đọc tiếp

- [Bắt đầu nhanh SDD + ADD](./sdd-add-quickstart.md)
- [Hướng dẫn vận hành SDD + ADD](./sdd-add-guide.md)
- [Sổ tay tình huống](./sdd-add-scenario-playbook.md)
