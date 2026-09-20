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

## 9. Self-heal chỉ để thu thập evidence

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

Script không repair, retry, edit, approve, commit, push, deploy hoặc thực hiện external action.
