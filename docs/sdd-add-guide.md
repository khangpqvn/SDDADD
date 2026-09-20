# Hướng dẫn vận hành SDD + ADD

Tài liệu này giải thích **ai quyết định**, **mỗi artifact dùng để làm gì**, và **khi nào được đi tiếp**. Nếu cần làm feature theo từng bước, đọc [Bắt đầu nhanh](./sdd-add-quickstart.md).

## 1. Bốn khái niệm cần nhớ

| Khái niệm | Hiểu đơn giản |
| :--- | :--- |
| **Artifact** | File có cấu trúc lưu Context, Spec, Plan, Tasks hoặc evidence. |
| **Gate** | Điều kiện bắt buộc trước khi sang bước tiếp theo. Chưa đạt thì dừng. |
| **Human Final Review** | Quyết định `APPROVED`, `REVISE` hoặc `REJECTED` do Human ghi bền vững bằng `/sdd-review`. Chat không thay thế review này. |
| **Checkpoint** | Approval bền vững trước material state change như đổi public contract, schema, permission, security config hoặc external action. |

Các tên field, status và format chính thức nằm trong `.claude/skills/_shared/ai-review-protocol.md` và từng `SKILL.md`.

## 2. Ai làm gì?

| Vai trò | Trách nhiệm |
| :--- | :--- |
| **Human reviewer** | Quyết định business, risk, scope và ghi approval. Với `solo`, project owner duy nhất review; với `team`, Human collaborator được ủy quyền review. |
| **Agent** | Phân tích, đề xuất, thực thi trong scope đã duyệt và ghi evidence. Agent không self-approve, không `git push`, không deploy. |
| **Tech Lead/contract owner** | Quyết định binding kiến trúc và xử lý shared contract khi repository giao quyền đó. |

`Project Ownership` và `Agent Execution` là hai trục độc lập trong `.sdd/shared_context.md`:

- `Project Ownership: solo|team` quyết định quyền review và policy delivery.
- `Agent Execution: direct|orchestrated` quyết định `/add-execute` chạy trong session hiện tại hay dùng worker.

`orchestrated` chỉ được dùng khi runtime Claude Code `Agent` capability đã được quan sát. Runtime không khả dụng là `BLOCKED`, không tự fallback sang `direct`.

## 3. Artifact và gate

| Artifact | Câu hỏi cần trả lời | Gate tiếp theo |
| :--- | :--- | :--- |
| `CONTEXT.md` | Làm gì, vì sao, cho ai, boundary nào? | Human `APPROVED` |
| `SPEC.md` | Hệ thống phải làm gì, không làm gì, và kiểm tra ra sao? | Human `APPROVED` và Feature Lock |
| `PLAN.md` | Sẽ thay đổi boundary nào, dùng binding/command nào, rủi ro gì? | Human `APPROVED` |
| `TASKS.md` | Ai làm từng phần, file nào được sửa, dependency và command nào? | Human `APPROVED` trước `/add-execute` |
| `Execution Record` | Attempt nào được chạy, route nào, grant/evidence nào? | Revalidate trước retry/resume |
| `Action Record` | Đã đổi gì, chạy command nào, kết quả và blocker còn lại? | Evidence đủ trước completion |
| Post-code review | Thay đổi có an toàn để delivery không? | Human `APPROVED` khi trigger áp dụng |

`REVISE`, `REJECTED`, review cũ, missing exact command, contract drift hoặc missing checkpoint đều chặn phần việc bị ảnh hưởng.

## 4. Cách xử lý requirement

Requirement thiếu hoặc mơ hồ phải đi theo quy tắc **Fix the Spec, not the Code**:

1. Ghi gap hoặc edge case trong Context/Spec.
2. Human xác nhận rule hoặc approved assumption.
3. Dùng `/sdd-update` nếu artifact đã tồn tại hoặc đã lock.
4. Review và lock lại artifact.
5. Chỉ sau đó mới resume execution.

`Methodology Profile` (`SKIP`, `SKETCH`, `DETAILED`, `FORMAL`) chỉ quyết định độ sâu phân tích. Nó không chọn framework, database hoặc verification command thay Architecture Profile.

## 5. Architecture Profile

`.sdd/architecture-profile.md` là nguồn chuẩn cho technology binding và exact verification command. Trước `PLAN`, `TASKS` hoặc execution:

1. Kiểm tra binding liên quan feature có `APPROVED`.
2. Kiểm tra evidence trỏ đến manifest, config, source hoặc decision bền vững.
3. Kiểm tra exact command tồn tại và khớp evidence.
4. Nếu thiếu hoặc mâu thuẫn, dừng và yêu cầu Human review.

Không thay command bị thiếu bằng `npm test`, `npm run build` hoặc lệnh quen thuộc khác. Xem [Hướng dẫn Hồ sơ kiến trúc](./architecture-profile-guide.md).

## 6. Execution và evidence

`/add-execute` là public entry point duy nhất sau khi `TASKS.md` đã `APPROVED`:

```text
/add-execute --feature=<slug> --task=<T001>
/add-execute --feature=<slug> --all
```

Command tự resolve route từ `.sdd/shared_context.md`, preflight, tạo Execution Record/grant nội bộ, consume grant trước action, thực thi và ghi Action Record. Không truyền grant, consumer, ownership, execution route hoặc dispatch flag thủ công.

`--retry` chỉ dành cho named task ở `RETRY_PENDING` do implementation defect, khi immutable inputs không đổi. `--resume` dành cho task bị interruption hoặc blocker đã được resolve, sau revalidation. Không reuse grant đã consumed.

## 7. Review sau code và delivery

Post-code review áp dụng khi thay đổi source behavior, test, API/shared contract, runtime/dependency/security config, schema hoặc business state. Docs-only change không tự động cần post-code review.

Trước commit:

```text
/git-validate --scope=commit --feature=<slug>
```

Chỉ khi có `GIT VALIDATION: READY` và Human yêu cầu mới dùng `/git-commit`. Agent không `git push`. Với `team`, dùng PR flow; với `solo`, Human có thể delivery trực tiếp theo policy repository.

## 8. Khi bị block

| Blocker | Hành động đúng |
| :--- | :--- |
| Context/Describe-back sai | Sửa Context, disposition question, review lại. |
| Spec thiếu rule | `/sdd-update` rồi review/lock lại; không vá code trước. |
| Thiếu binding/command | Bổ sung evidence và review Architecture Profile. |
| Contract hoặc boundary drift | Dừng, để owner/Lead resolve, rồi trace/sync và revalidate. |
| Test/validation fail | Giữ exact command/result, phân loại nguyên nhân, sửa trong scope hoặc quay lại Spec/Profile. |
| Thiếu checkpoint/review | Persist approval trước khi tiếp tục. |
| Runtime orchestrated unavailable | Giữ `BLOCKED`; resolve runtime evidence, không fallback direct. |

## Đọc tiếp

- [Bắt đầu nhanh](./sdd-add-quickstart.md)
- [Tra cứu nhanh](./sdd-add-field-guide.md)
- [Sổ tay tình huống](./sdd-add-scenario-playbook.md)
- [Hướng dẫn điều phối nhiều Agent](./multi-agent-orchestration-guide.md)
