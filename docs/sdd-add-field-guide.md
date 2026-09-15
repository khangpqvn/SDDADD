# Tra cứu nhanh SDD + ADD

Dùng khi đang làm việc và cần chọn bước tiếp theo. Nếu mới bắt đầu, đọc [Bắt đầu nhanh](./sdd-add-quickstart.md). `.claude/skills/` là command contract.

## Quy tắc nhớ nhanh

`Project Ownership` và `Agent Execution` là hai trục độc lập: solo là một Human owner, team là nhiều Human collaborator; `/add-execute` chạy direct trong Agent hiện tại hoặc điều phối orchestrated worker theo persisted route. Solo vẫn có thể dùng worker; team vẫn có thể direct execution.

1. Agent đề xuất; Human ghi decision persisted bằng `/sdd-review`.
2. Context/Spec có thể business-neutral; Plan/Tasks/execute không đoán binding hay command.
3. Spec thiếu rule: `/sdd-update`, không vá behavior.
4. Mỗi task cần Shadow Plan và Action Record.
5. Agent không `git push`.

## Tình huống → hành động

| Tình huống | Action ngay | Chỉ tiếp tục khi |
| :--- | :--- | :--- |
| Greenfield chưa chọn stack | `/sdd-init` → Context/Spec business-neutral | Profile có binding/command trước Plan |
| Brownfield | `scripts/adopt.*` → `/sdd-adopt` | Evidence profile không mâu thuẫn |
| Feature mới | `/sdd-context` → review → `/sdd-spec` → lock → Plan → Tasks | Gate artifact hợp lệ |
| Describe-back mâu thuẫn | Sửa Context/glossary/constraint, disposition lại question | Human review Context `APPROVED` |
| Requirement/contract đổi | `/sdd-update --artifact=<...> --reason="..."` | Downstream review đã refresh |
| Task > khoảng bốn giờ | Tách task; hoặc ghi `approved-exception` | Exception có evidence/risk/command/checkpoint |
| Test fail | Phân loại defect, Spec gap, profile gap, prohibited mutation | Exact command và approved scope còn hợp lệ |
| Validation fail | Giữ evidence; sửa trong scope hoặc quay lại Spec/Profile | Tất cả route applicable pass |
| Post-code review pending | Tạo post-code report rồi `/sdd-review` | Report `APPROVED` nếu trigger áp dụng |
| Shared contract đổi | Owner/Lead cập nhật shared context → trace → sync | Contract owner/version khớp |
| Chạy một task eligible | `/add-execute --feature=<slug> --task=<T001>` | `TASKS.md` approved; task/dependency/boundary/profile/command/checkpoint/contract evidence hợp lệ |
| Chạy snapshot feature eligible | `/add-execute --feature=<slug> --all` | Preflight toàn snapshot; chạy theo declaration order và dừng ở blocker/Human gate/drift/failure/cancellation |
| Orchestrated execution | Gọi cùng `/add-execute` command; không thêm route flag | Persisted route là `orchestrated`, runtime Claude Code `Agent` observed, boundary/packet/evidence đủ; runtime unavailable là `BLOCKED`, không fallback direct |
| Retry implementation defect | `/add-execute --feature=<slug> --task=<T001> --retry` | Named task là `RETRY_PENDING`; immutable inputs không đổi |
| Resume task bị gián đoạn/đã resolve | `/sdd-resume --feature=<slug>` rồi `/add-execute --feature=<slug> --task=<T001> --resume` | Record, review/profile/command/contract/checkpoint và runtime evidence revalidated |
| Session dừng | `/sdd-handoff --feature=<slug>` | Next decision/command được ghi |
| Session tiếp tục | `/sdd-resume --feature=<slug>` | Review/profile/command/contract/checkpoint đủ |
| Git delivery | `/git-validate --scope=commit` | `GIT VALIDATION: READY` |

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
# Or run the current eligible feature snapshot:
/add-execute --feature=<slug> --all
<exact approved command>
/sdd-audit --feature=<slug>
/sdd-trace --feature=<slug> --diff
/sdd-sync --feature=<slug> --reason="..."
/git-validate --scope=commit --feature=<slug>
```

## Blocker → không làm / làm đúng

| Blocker | Không làm | Làm đúng |
| :--- | :--- | :--- |
| Missing binding/command | Guess package/command | Add evidence, review profile, refresh downstream work |
| Spec gap | Patch code | Update/review/lock Spec rồi resume |
| Contract drift | Continue execution | Stop; owner/Lead resolve, trace/sync |
| Material mutation thiếu checkpoint | Execute | Persist Human checkpoint trước |
| Thiếu Action Record | Mark `[x]` | Record command/result/validation/sync |
| Thiếu post-code review | Commit/PR | Tạo report, Human review |
| Grant consumed/mismatch hoặc runtime unavailable | Reuse grant, supply token hoặc fallback direct | Giữ Execution Record evidence; resolve đúng blocker rồi revalidate public route |
| Loop/context/environment issue | Lặp command hoặc mở rộng scope | Handoff evidence, classify blocker, Human decision |

## Self-heal

`self-heal.sh` chỉ chạy một exact approved command với `--max-attempts=1` và ghi evidence. Không edit, repair, retry, self-approve, commit, push hoặc deploy.
