# Tra cứu nhanh SDD + ADD

Dùng bảng này khi bạn biết tình huống nhưng chưa biết bước tiếp theo. Nếu chưa từng làm feature, bắt đầu bằng [Bắt đầu nhanh](./sdd-add-quickstart.md). Command contract chính thức nằm trong `.claude/skills/`.

## Quy tắc nhớ nhanh

1. Human duyệt; Agent đề xuất, thực thi và ghi evidence.
2. Context/Spec có thể technology-neutral; Plan/Tasks/execution không được đoán binding hoặc command.
3. Requirement thiếu hoặc sai: update Spec trước, không vá code.
4. Mỗi task có Shadow Plan và Action Record.
5. Agent không self-approve, không `git push`, không deploy.

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

## Self-heal

`scripts/self-heal.sh` chỉ chạy một exact approved command với `--max-attempts=1` để thu thập evidence cho `implementation-defect`. Script không edit, repair, retry, self-approve, commit, push hoặc deploy.
