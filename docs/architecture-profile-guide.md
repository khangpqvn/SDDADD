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

## Chọn công cụ AI cho dự án

Quyết định này nằm trước Profile: Profile ghi *binding đã chọn*, phần này giúp *chọn*. Tiêu chí ở mức nguyên tắc, không gắn với sản phẩm hay giá cụ thể vì cả hai đổi nhanh.

### Theo mô hình tích hợp

| Mô hình | Phù hợp khi | Đánh đổi |
| :--- | :--- | :--- |
| IDE-native | Phần lớn công việc là viết và sửa code trong editor | Gắn với một IDE; khó tự động hóa ngoài editor |
| Plugin/extension | Muốn giữ IDE hiện tại và thêm năng lực dần | Năng lực phụ thuộc giới hạn của host |
| Terminal-native | Cần script hóa, chạy trong CI, hoặc điều phối nhiều Agent | Ít hỗ trợ trực quan; phụ thuộc kỷ luật command |

Template này vận hành theo mô hình terminal-native: governance và slash command nằm trong Git, nên tái tạo được trên máy khác và trong CI.

### Hai trục kỹ thuật cần cân

| Trục | Lựa chọn | Hệ quả |
| :--- | :--- | :--- |
| Ràng buộc model | Model-locked: tối ưu cho một model, hành vi ổn định hơn | Đổi model là đổi công cụ |
| | Model-agnostic: đổi model không đổi workflow | Phải tự kiểm chứng chất lượng trên từng model |
| Cách nạp ngữ cảnh | RAG: lấy phần liên quan từ kho lớn | Phụ thuộc chất lượng truy hồi; có thể bỏ sót |
| | Long context: đưa trực tiếp lượng lớn ngữ cảnh | Tốn token; chất lượng giảm khi context quá đầy |

Trong template này, `.agentignore` và task boundary là cách giảm cả hai rủi ro: nạp ít hơn nhưng đúng hơn.

### Ba mức riêng tư

| Mức | Nghĩa là | Chọn khi |
| :--- | :--- | :--- |
| Cục bộ | Code không rời máy hoặc mạng nội bộ | Dữ liệu bị ràng buộc pháp lý hoặc hợp đồng |
| Có kiểm soát | Gửi ra dịch vụ nhưng có cam kết không huấn luyện và có nhật ký truy cập | Đa số dự án thương mại |
| Mặc định | Không có cam kết riêng ngoài điều khoản chung | Mã nguồn mở hoặc không có dữ liệu nhạy cảm |

Nguyên tắc vận hành: dữ liệu nào không được phép ra khỏi phạm vi thì không đưa vào context. `.agentignore` là lớp đầu tiên, không phải lớp duy nhất.

### Tổng chi phí sở hữu

Chi phí giấy phép thường không phải phần lớn nhất. Cân đủ bốn khoản:

- **Subscription:** phí cố định theo người dùng hoặc theo chỗ.
- **API/usage:** phí theo token, tăng nhanh khi Agent lục lọi cả repo. Task boundary hẹp là biện pháp giảm chi phí, không chỉ là biện pháp kỹ thuật.
- **Học và vận hành:** thời gian đội hình thành thói quen, viết governance, sửa quy trình.
- **Rủi ro:** chi phí khi Agent làm sai mà không bị phát hiện. Đây là khoản mà gate và evidence trong template này dùng để giảm.

Không ghi bảng giá hay tên phiên bản vào Profile. Ghi binding và exact command, kèm evidence trỏ tới manifest hoặc config thật.

## MCP và giao tiếp giữa Agent

`.sdd/mcp-config.yaml` khai báo policy truy cập tool/resource. Nguyên tắc:

- **Least privilege:** mỗi Agent chỉ nhận quyền cần cho task của nó, không nhận quyền của cả dự án.
- **Có thời hạn và ngân sách:** quyền truy cập nên hết hạn và có giới hạn sử dụng, thay vì mở vô thời hạn.
- **Ghi lại để kiểm chứng:** mỗi lần dùng tool có rủi ro cần để lại evidence trong Action Record.
- **Policy không phải enforcement.** `.sdd/mcp-config.yaml` là khai báo Markdown/YAML; nó **không chứng minh** host đang áp đặt giới hạn đó. Khi chưa có runtime evidence, giữ trạng thái `UNVERIFIED` thay vì khẳng định đã được bảo vệ.

Cùng nguyên tắc áp cho giao tiếp giữa nhiều Agent: mỗi Agent có phạm vi ghi riêng, xung đột được resolve bởi Human hoặc owner đã được chỉ định. Chi tiết nằm trong [Hướng dẫn execution](./multi-agent-orchestration-guide.md).

## Đọc tiếp

- [Bắt đầu nhanh](./sdd-add-quickstart.md)
- [Hướng dẫn vận hành](./sdd-add-guide.md)
- [Tra cứu nhanh](./sdd-add-field-guide.md)
- [Hướng dẫn execution](./multi-agent-orchestration-guide.md)
