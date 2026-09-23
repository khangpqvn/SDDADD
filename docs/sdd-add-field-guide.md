# Tra cứu nhanh SDD + ADD

Dùng bảng này khi bạn biết tình huống nhưng chưa biết bước tiếp theo. Nếu chưa từng làm feature, bắt đầu bằng [Bắt đầu nhanh](./sdd-add-quickstart.md). Command contract chính thức nằm trong `.claude/skills/`.

## Quy tắc nhớ nhanh

1. Human duyệt; Agent đề xuất, thực thi và ghi evidence.
2. Context/Spec có thể technology-neutral; Plan/Tasks/execution không được đoán binding hoặc command.
3. Requirement thiếu hoặc sai: update Spec trước, không vá code.
4. Mỗi task có Shadow Plan và Action Record.
5. Agent không self-approve, không `git push`, không deploy.

## Chọn độ sâu Spec

| Rủi ro nếu sai | Độ phức tạp | Độ sâu | Nghĩa là |
| :--- | :--- | :--- | :--- |
| Thấp | Thấp | `SKETCH` | Mục tiêu, vài requirement chính, acceptance criteria. |
| Thấp | Cao | `DETAILED` | Đủ 8 thành phần Spec, EARS cho nhánh chính và nhánh lỗi. |
| Cao | Thấp | `DETAILED` | Nhấn NFR, error handling và data constraint. |
| Cao | Cao | `FORMAL` | Đủ 8 thành phần, traceability đầy đủ, pre-mortem, checkpoint dày. |

Rủi ro cao = sai thì mất dữ liệu, mất tiền, rò rỉ thông tin, hoặc phá public contract.

## Tra cứu EARS

| Cần diễn tả | Mẫu |
| :--- | :--- |
| Luôn đúng, không điều kiện | `THE <system> SHALL <action>` |
| Phản ứng với một sự kiện | `WHEN <event>, THE <system> SHALL <action>` |
| Hành vi liên tục trong một trạng thái | `WHILE <state>, THE <system> SHALL <action>` |
| Tính năng bật/tắt theo cấu hình | `WHERE <feature> IS ENABLED, THE <system> SHALL <action>` |
| Lỗi và edge case | `WHERE <condition>, THE <system> SHALL <response>` |

`SHALL` bắt buộc và phải kiểm chứng được; `SHOULD` khuyến nghị, lệch phải ghi lý do; `MAY` tùy chọn. Ví dụ và anti-pattern nằm trong [Hướng dẫn vận hành](./sdd-add-guide.md).

## Khi nào cần hỏi trước, khi nào làm luôn

| Dấu hiệu | Hành động |
| :--- | :--- |
| Requirement có nhiều cách hiểu hợp lý | Hỏi trước (Clarification-First), ghi câu trả lời vào artifact. |
| Thiếu business rule cho edge case | Hỏi trước; không tự đặt rule. |
| Ngưỡng NFR chưa có số | Hỏi trước; không viết "nhanh" hoặc "an toàn". |
| Có nhiều giải pháp kỹ thuật khả thi, chưa rõ trade-off | So sánh phương án trong `PLAN.md` rồi để Human chọn. |
| Bug chưa rõ nguyên nhân | Chứng minh nguyên nhân trước, không sửa theo phỏng đoán. |
| Requirement rõ, binding đã `APPROVED`, boundary hẹp | Làm luôn trong scope đã duyệt. |

## Tình huống → việc cần làm

| Tình huống | Làm ngay | Chỉ đi tiếp khi |
| :--- | :--- | :--- |
| Repository chưa có governance | `/sdd-init --project-name="<name>"` | Bootstrap review đã `APPROVED`. |
| Repository có code nhưng chưa adopt | `scripts/adopt.*` rồi `/sdd-adopt` | Profile có evidence rõ, mâu thuẫn đã được Human xử lý. |
| Feature mới | `/sdd-context` → review → `/sdd-spec` → review/lock → `/sdd-plan` → `/sdd-tasks` | Artifact gate đúng thứ tự đã đạt. |
| Describe-back mâu thuẫn | Sửa Context, disposition question, review lại | Context `APPROVED`. |
| Requirement/contract đổi | `/sdd-update --feature=<slug> --artifact=<context|spec|plan|tasks> --reason="..."` | Downstream artifact được refresh/review. |
| Task lớn hơn khoảng bốn giờ | Tách task hoặc ghi `approved-exception` | Exception có lý do, risk và Human evidence. |
| Chạy một task | `/add-execute --feature=<slug> --task=<T001>` | Task eligible, dependency, boundary, profile, command, checkpoint và contract đều hợp lệ. |
| Chạy snapshot feature | `/add-execute --feature=<slug> --all` | Toàn snapshot được preflight; dừng tại blocker/failure/drift. |
| Retry implementation defect | `/add-execute --feature=<slug> --task=<T001> --retry` | Task là `RETRY_PENDING`, immutable inputs không đổi. |
| Resume sau gián đoạn | `/sdd-handoff` → `/sdd-resume` → `/add-execute ... --resume` | Execution Record, review, profile, command, contract, checkpoint và runtime được revalidate. |
| Session kết thúc giữa chừng | `/sdd-handoff --feature=<slug>` | Next decision và command đã được ghi. |
| Shared contract thay đổi | Owner/Lead cập nhật shared context → `/sdd-trace` → `/sdd-sync` | Owner/version và evidence khớp. |
| Validation hoặc test fail | Giữ exact command/result và phân loại nguyên nhân | Đã sửa đúng boundary hoặc đã update/review artifact cần thiết. |
| Chuẩn bị Git delivery | `/git-validate --scope=commit --feature=<slug>` | Kết quả là `GIT VALIDATION: READY`. |

## Chuỗi command tối thiểu

```text
/sdd-context --feature=<slug>
/sdd-review ... --artifact=context --status=APPROVED
/sdd-spec --feature=<slug>
/sdd-lint --feature=<slug>
/sdd-review ... --artifact=spec --status=APPROVED
/sdd-plan --feature=<slug>
/sdd-review ... --artifact=plan --status=APPROVED
/sdd-tasks --feature=<slug>
/sdd-review ... --artifact=tasks --status=APPROVED
/add-execute --feature=<slug> --task=<T001>
<exact approved command>
/sdd-audit --feature=<slug>
/sdd-trace --feature=<slug> --diff
/sdd-sync --feature=<slug> --reason="..."
/git-validate --scope=commit --feature=<slug>
```

Chỉ chạy route khi trigger áp dụng. Route không áp dụng phải ghi `N/A` trong Action Record, không ghi giả `PASS`.

## Blocker → không làm / làm đúng

| Blocker | Không làm | Làm đúng |
| :--- | :--- | :--- |
| Thiếu binding/command | Đoán package hoặc command | Bổ sung evidence, review Profile, refresh downstream artifact. |
| Spec gap | Patch code để né gap | Update/review/lock Spec rồi resume. |
| Contract drift | Tiếp tục execution | Dừng; owner/Lead resolve, trace/sync, revalidate. |
| Thiếu checkpoint | Thực hiện material state change | Persist Human checkpoint `APPROVED`. |
| Thiếu Action Record | Đánh dấu task complete | Ghi changed path, command/result, validation và sync-back. |
| Thiếu post-code review | Commit/PR | Tạo report và chờ Human review khi trigger áp dụng. |
| Grant consumed/mismatch | Reuse grant hoặc tự cấp token | Giữ evidence, resolve blocker, gọi lại public route sau revalidation. |
| Orchestrated runtime unavailable | Fallback direct | Giữ `BLOCKED`, resolve runtime evidence. |

## Dấu hiệu Agent đang đi sai

| Dấu hiệu | Nguyên nhân thường gặp | Làm ngay |
| :--- | :--- | :--- |
| Hỏi lại điều đã có trong Spec | Context quá tải | Mở session mới, trỏ lại artifact cụ thể. |
| Sửa đi sửa lại cùng một lỗi | Loop trapping | Dừng attempt, thu evidence, phân loại nguyên nhân. |
| Dùng hàm/tham số không tồn tại | API hallucination | Verify bằng exact approved command; không tin code chỉ vì đọc thấy hợp lý. |
| Bỏ qua chỉ dẫn đã nêu | Context cliff | Session mới; chia task nhỏ hơn. |
| Sửa file ngoài task boundary | Boundary không rõ trong `TASKS.md` | Dừng, revert phần ngoài scope, làm rõ boundary. |
| Báo `PASS` mà không có output command | Thiếu environmental feedback | Yêu cầu exact command và kết quả thật trong Action Record. |

## Tự chủ và checkpoint

Mức tự chủ càng cao thì checkpoint càng phải dày, không phải thưa hơn.

| Loại hành động | Gate cần có |
| :--- | :--- |
| Đọc, phân tích, đề xuất | Không cần gate. |
| Sửa code trong một boundary đã duyệt | Shadow Plan và Action Record. |
| Sửa nhiều file hoặc nhiều layer | Shadow Plan, review trước khi tiếp tục. |
| Đổi schema, permission, security config | Human checkpoint bền vững trước khi thực hiện. |
| Gọi ra ngoài, commit, push, deploy | Human thực hiện; Agent không `git push`, không deploy. |

## Chọn công cụ và bảo mật

Ở mức nguyên tắc, không phụ thuộc sản phẩm hay giá cụ thể:

- Chọn tool theo mô hình tích hợp phù hợp workflow thật, không theo tính năng nghe hay.
- Ưu tiên least privilege: Agent chỉ nhận quyền cần cho task, có thời hạn và có ngân sách.
- Chỉ khẳng định một biện pháp bảo vệ đang hoạt động khi có runtime evidence. File policy tự nó không chứng minh host enforcement.
- Dữ liệu nào không được ra khỏi máy thì không đưa vào context. `.agentignore` là lớp đầu tiên, không phải lớp duy nhất.

Chi tiết tiêu chí chọn tool, privacy và chi phí nằm trong [Hồ sơ kiến trúc](./architecture-profile-guide.md).

## Self-heal

`scripts/self-heal.sh` chỉ chạy một exact approved command với `--max-attempts=1` để thu thập evidence cho `implementation-defect`. Script không edit, repair, retry, self-approve, commit, push hoặc deploy.
