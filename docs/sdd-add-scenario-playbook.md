# Sổ tay tình huống SDD + ADD

Dùng khi đã biết tình huống và cần các bước thao tác. Với flow đầy đủ, đọc [Bắt đầu nhanh](./sdd-add-quickstart.md).

## Dự án mới chưa chọn stack

1. `/sdd-init --project-name="<name>"`.
2. Tạo Context; kiểm tra Intent Packet, Describe-back và question disposition.
3. Review Context, tạo/review/lock Spec business-neutral.
4. Khi feature cần kỹ thuật, ghi binding + evidence + exact command vào Architecture Profile và review.
5. Chỉ sau đó tạo Plan, Tasks và chạy `/add-execute` cho task hoặc feature snapshot eligible.

**Dừng khi:** binding/command thiếu hoặc evidence mâu thuẫn. Không sinh adapter-specific plan trong core-only baseline.

## Đưa template vào dự án sẵn có

1. Chạy `scripts/adopt.sh <target>` hoặc `scripts/adopt.ps1 -TargetPath <target>`.
2. Trong repository đích, chạy `/sdd-adopt`.
3. Đối chiếu manifest, CI, source và configuration với Architecture Profile.
4. Mâu thuẫn giữ `PENDING HUMAN REVIEW`; Human review adoption scope trước feature work.

`adopt` không overwrite file hiện hữu nếu không explicit force.

## Requirement hoặc contract thay đổi

```text
/sdd-update --feature=<slug> --artifact=<context|spec|plan|tasks> --reason="..."
```

1. Ghi Change Impact: scope/assumption/lock impact, downstream artifact invalid, trace/test/sync và review follow-up.
2. Refresh recommendation; approval cũ không còn hiệu lực khi field scope material đổi.
3. Với Spec đổi, review/lock lại rồi mới resume code.

## Test hoặc validation fail

1. Lưu exact command/result, không lọc test/skip/mock để ép success.
2. Phân loại: implementation defect, Spec gap, profile/configuration gap, hoặc prohibited/high-risk mutation.
3. Defect chỉ sửa trong approved task/file boundary; sau đó chạy lại exact command.
4. Spec/Profile gap: dừng, update/review đúng artifact.
5. Cập nhật Action Record, trace/sync decision và post-code review nếu trigger áp dụng.

## Material state change

Trước shared/public contract, schema/business-data, permission/security/dependency/runtime config hoặc external/irreversible action:

1. Xác nhận scope category trong Task/Shadow Plan.
2. Lưu persisted Human checkpoint.
3. Thực thi đúng file boundary đã approved.
4. Ghi evidence, compatibility/recovery information khi applicable, rồi trace/sync.

## Handoff, retry và resume

- `/sdd-handoff --feature=<slug>` ghi Intent/DoD, active contract version, scope, profile/exact command/result, checkpoint, blocker và next command.
- `/sdd-resume --feature=<slug>` chỉ revalidate context và gợi ý command public khi gate còn hiệu lực. Context pressure, stuck loop hoặc environment mismatch phải được ghi như blocker/evidence, không reset ngầm scope.
- Chỉ dùng `/add-execute --feature=<slug> --task=<T00X> --retry` cho implementation defect ở task `RETRY_PENDING` khi boundary, frozen contract, profile, exact command và checkpoint không đổi. Grant đã consumed bị retire; không reuse/reset.
- Chỉ dùng `/add-execute --feature=<slug> --task=<T00X> --resume` sau interruption, resolved `BLOCKED`, hoặc Human-dispositioned `ESCALATED`, rồi revalidate record/grant/runtime evidence. Spec/profile/command/checkpoint/contract/ownership/runtime gap là `BLOCKED`, không phải retry.

## Delivery

`Project Ownership: solo` dùng Human-owned direct delivery sau validation/review; `team` dùng PR/review flow. `Agent Execution: direct|orchestrated` không thay đổi delivery policy.

1. Chạy exact approved command và validation route applicable.
2. Tạo/approve post-code report khi source/test/contract/config/schema/state đổi.
3. `/git-validate --scope=commit` phải `READY`.
4. Agent chỉ commit khi Human yêu cầu; Human tự `git push`.
5. Team chạy `/git-validate --scope=pr --strict` trước `/git-pr`; solo bỏ PR overhead.

## Self-heal evidence-only

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

Script chỉ thu thập evidence một lần. Nó không repair/retry, edit, approve, commit, push, deploy hoặc thực hiện external action.
