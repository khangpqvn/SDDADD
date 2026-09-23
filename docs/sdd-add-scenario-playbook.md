# Sổ tay tình huống SDD + ADD

Dùng tài liệu này khi feature bị block, repository là brownfield, session bị ngắt hoặc cần delivery. Flow chuẩn nằm trong [Bắt đầu nhanh](./sdd-add-quickstart.md).

## 1. Repository mới chưa chọn stack

1. Chạy `/sdd-init --project-name="<name>"`.
2. Kiểm tra bootstrap scope và review `.sdd/reviews/init.md`.
3. Tạo Context, review; tạo Spec technology-neutral, review và lock.
4. Xác định behavior kỹ thuật cần thiết.
5. Ghi binding, evidence và exact verification command vào `.sdd/architecture-profile.md`.
6. Human review Profile.
7. Chỉ sau đó chạy `/sdd-plan`, `/sdd-tasks` và `/add-execute`.

**Dừng khi:** binding/command thiếu hoặc evidence mâu thuẫn. Không tạo adapter-specific Plan dựa trên suy đoán.

## 2. Đưa template vào repository có sẵn

1. Chạy `scripts/adopt.sh <target>` hoặc `scripts/adopt.ps1 -TargetPath <target>`.
2. Trong repository đích, chạy `/sdd-adopt`.
3. Đối chiếu manifest, lockfile, CI, runtime bootstrap, test config và source layout với Profile.
4. Giữ `PENDING HUMAN REVIEW` nếu evidence mâu thuẫn.
5. Chỉ làm feature sau khi adoption scope và Profile được review.

Script adopt không được overwrite file hiện hữu nếu chưa có explicit force. Xem contract của `sdd-adopt` trước khi chạy.

## 3. Requirement hoặc contract thay đổi

Dùng:

```text
/sdd-update --feature=<slug> --artifact=<context|spec|plan|tasks> --reason="<lý do>"
```

Sau đó:

1. Kiểm tra Change Impact: scope, assumption, lock, downstream artifact, trace/test/sync.
2. Review lại recommendation và artifact bị ảnh hưởng.
3. Nếu Spec đổi, review và lock lại trước khi resume code.
4. Không giữ approval cũ khi material field đã đổi.

## 4. Test hoặc validation fail

1. Lưu exact command và kết quả đầy đủ cần thiết; không skip test hoặc đổi command để tạo `PASS`.
2. Phân loại failure: implementation defect, Spec gap, Profile/configuration gap hoặc prohibited/high-risk mutation.
3. Implementation defect chỉ sửa trong approved task/file boundary.
4. Spec/Profile gap thì dừng và update/review đúng artifact.
5. Chạy lại exact approved command sau khi nguyên nhân đã được xử lý.
6. Cập nhật Action Record, trace/sync và post-code review nếu trigger áp dụng.

## 5. Material state change

Trước khi đổi public/shared contract, schema/business data, permission/security, dependency/runtime config hoặc tạo external/irreversible action:

1. Xác nhận scope category trong Task/Shadow Plan.
2. Persist Human checkpoint `APPROVED`.
3. Kiểm tra immutable file boundary và exact command.
4. Thực thi đúng scope.
5. Ghi evidence, compatibility/recovery information nếu cần, rồi trace/sync.

Nếu checkpoint thiếu, execution bị `BLOCKED`.

## 6. Handoff và resume

Khi session sắp dừng:

```text
/sdd-handoff --feature=<slug>
```

Handoff phải nêu Intent/DoD, contract version, scope, Profile/exact command/result, checkpoint, blocker và next command.

Khi tiếp tục:

```text
/sdd-resume --feature=<slug>
```

Sau resume, chỉ gọi public `/add-execute` khi record, review, Profile, command, contract, checkpoint, ownership và runtime evidence còn hợp lệ.

Không giả định worker identity, permission hoặc grant của session cũ vẫn hợp lệ.

## 7. Retry và resume task

- `--retry`: chỉ cho implementation defect khi task là `RETRY_PENDING` và immutable inputs không đổi.
- `--resume`: cho task bị interruption, `BLOCKED` đã resolve hoặc `ESCALATED` đã có Human disposition.
- Spec/Profile/command/checkpoint/contract/ownership/security/dependency/runtime gap là `BLOCKED`, không phải retry.
- Grant đã consumed phải retire; không reset hoặc reuse.
- Sau nhiều failure liên tiếp theo threshold của skill, task phải `ESCALATED` và chờ Human disposition.

Ví dụ:

```text
/add-execute --feature=<slug> --task=<T001> --retry
/add-execute --feature=<slug> --task=<T001> --resume
```

## 8. Delivery

1. Chạy exact approved command và các route validation áp dụng.
2. Tạo và xin duyệt post-code report nếu thay đổi source, test, contract, config, schema hoặc state.
3. Chạy `/git-validate --scope=commit --feature=<slug>`.
4. Chỉ khi có `GIT VALIDATION: READY` và Human yêu cầu mới commit.
5. Human tự `git push`; Agent không push.
6. `team` dùng PR flow; `solo` có thể delivery trực tiếp theo policy repository.

`Agent Execution: direct|orchestrated` không thay đổi delivery policy.

## 9. Khi không nên dùng full SDD

SDD trả giá trước để giảm rủi ro sau. Khi chưa biết mình muốn gì, cái giá đó không mua được gì.

| Tình huống | Vì sao full SDD không phù hợp | Làm gì thay thế |
| :--- | :--- | :--- |
| R&D, thăm dò kỹ thuật | Requirement chưa tồn tại; Spec sẽ bị viết lại nhiều lần | Ghi hypothesis và cách đo, chạy thử, rồi mới viết Spec |
| Prototype, hackathon | Mục tiêu là học nhanh, không phải bảo trì lâu dài | Giữ ghi chú ngắn; nêu rõ đây là throwaway |
| Landing page, nội dung tĩnh | Rủi ro thấp, hành vi ít | `SKETCH`: mục tiêu và acceptance criteria |
| Script dùng một lần | Không có downstream consumer | Ghi mục đích và exact command; không tạo feature artifact |

Ranh giới: khi hypothesis được xác nhận và code sẽ được giữ lại, phải chuyển sang Spec đầy đủ trước khi mở rộng. Prototype đi vào production mà không qua Spec là nợ kỹ thuật ngay từ ngày đầu.

Khi cần ghi lại một thăm dò, một file `EXPERIMENT.md` ngắn là đủ: hypothesis cần kiểm chứng, cách đo kết quả, phạm vi code bị ảnh hưởng, và điều kiện dừng. **`EXPERIMENT.md` không phải Spec, không được review như Spec, và không đủ để delivery.** Nếu kết quả được giữ lại, viết `CONTEXT.md` và `SPEC.md` thật rồi đi qua gate bình thường.

## 10. Khi Spec có vấn đề

Spec sai thì Agent thực thi sai một cách rất thuyết phục. Rác vào, rác ra — và rác đi ra nhanh hơn.

Dấu hiệu Spec chưa dùng được:

- Requirement không nêu cách kiểm tra, nên không ai biết khi nào đạt.
- Mô tả HOW thay vì WHAT: đã chọn sẵn class, file, thư viện trước khi hiểu vấn đề.
- Không có Out of Scope, nên scope phình trong lúc thực thi.
- Nhánh lỗi trống, nên hành vi lỗi do Agent tự quyết.
- Requirement mâu thuẫn với `CONSTITUTION.md` hoặc `.sdd/constraints/`.

Bốn cách review Spec trước khi lock:

| Cách | Câu hỏi đặt ra |
| :--- | :--- |
| Domain walkthrough | Kể lại luồng bằng ngôn ngữ nghiệp vụ; người hiểu nghiệp vụ có thấy đúng không? |
| Defensive review | Với mỗi requirement, sai ở đâu thì không ai phát hiện? |
| Pre-mortem | Giả sử feature này đã thất bại; nguyên nhân khả dĩ nhất là gì? |
| Adversarial review | Requirement này có thể hiểu theo nghĩa khác mà vẫn "đúng" không? |

Kết quả review đi vào Spec như requirement hoặc approved assumption, không để trong chat.

## 11. Spec-code drift

Drift là khi code và Spec nói hai điều khác nhau. Phát hiện bằng `/sdd-trace --feature=<slug> --diff`.

| Trường hợp | Xử lý |
| :--- | :--- |
| Code sai so với Spec đã duyệt | Sửa code trong task boundary; chạy lại exact approved command. |
| Spec sai so với thực tế Human đã chấp nhận | `/sdd-update` để sync-back, review lại, lock lại, rồi mới tiếp tục. |
| Lệch có chủ ý nhưng chưa được ghi | Dừng; ghi lý do và trade-off vào artifact, xin Human review; không để lệch ngầm. |
| `@ears` annotation trỏ tới requirement đã đổi nghĩa | Cập nhật annotation cùng lúc với Spec; annotation lệch nặng hơn thiếu annotation. |

Drift không được ghi lại sẽ tích thành spec debt: test xanh nhưng không chứng minh điều gì, và không ai còn tin `SPEC.md`.

## 12. Sửa hay viết lại

Khi một phần code đã lệch xa Spec, chọn giữa sửa và viết lại bằng tiêu chí, không bằng cảm giác:

| Chọn sửa khi | Chọn viết lại khi |
| :--- | :--- |
| Nguyên nhân đã được chứng minh và khu trú | Nguyên nhân rải khắp nhiều layer |
| Boundary hiện tại vẫn khớp Spec | Boundary hiện tại sai so với Plan đã duyệt |
| Có test chứng minh không hồi quy | Không có test đáng tin để bảo vệ hành vi |
| Sửa nằm trong approved task boundary | Viết lại cần Plan mới và Human review mới |

Viết lại là thay đổi scope: cần `/sdd-update` cho `PLAN.md`, review lại, rồi mới thực thi. Không viết lại âm thầm trong một task được duyệt để sửa.

## 13. Self-heal chỉ để thu thập evidence

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

Script không repair, retry, edit, approve, commit, push, deploy hoặc thực hiện external action.
