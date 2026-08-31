# Sổ tay tình huống SDD + ADD

Dùng tài liệu này khi đã biết tình huống đang gặp và cần quy trình thao tác. `.claude/skills/` vẫn là nguồn chuẩn cho command contract; trang này giải thích thứ tự làm, điểm dừng và kết quả mong đợi.

## 1. Dự án mới, chưa chọn stack (greenfield core-only)

1. Chạy `/sdd-init --project-name="<name>"`.
2. Mở `.sdd/architecture-profile.md`, đọc bootstrap recommendation và xác nhận phần nào chưa được chọn.
3. Tạo `/sdd-context --feature=<slug>`; ghi Intent Packet và Methodology Profile bằng ngôn ngữ business.
4. Human review Context, rồi tạo, review và lock Spec.
5. Khi feature cần kỹ thuật, ghi binding cùng exact command vào profile và review profile.
6. Chỉ sau đó mới tạo Plan, Tasks và thực thi lifecycle.

**Dừng khi:** binding hoặc command còn thiếu. Không tạo adapter hoặc dùng command giả định trong core-only baseline.

## 2. Đưa template vào dự án có sẵn (brownfield adoption)

1. Chạy `scripts/adopt.sh <target>` hoặc `scripts/adopt.ps1 -TargetPath <target>`.
2. Trong repository đích, chạy `/sdd-adopt`.
3. Đối chiếu manifest, CI, source và configuration với Architecture Profile.
4. Khi evidence mâu thuẫn, ghi `PENDING HUMAN REVIEW`, không suy luận.
5. Human review adoption scope trước feature work.

`adopt` không overwrite file hiện hữu nếu không explicit force.

## 3. Một feature thông thường

1. `/sdd-context --feature=<slug>` tạo Intent Packet, unresolved decision disposition và Methodology Profile.
2. Human approves Context.
3. `/sdd-spec --feature=<slug>` tạo EARS, acceptance, error behavior, Feature Lock và out-of-scope.
4. Human approves/locks Spec.
5. `/sdd-plan` maps requirements, profile binding, consistency và state-change impact.
6. Human approves Plan.
7. `/sdd-tasks` creates atomic ownership, checkpoint và sync-back records.
8. Human approves Tasks.
9. `/add-execute` runs từng approved task với Shadow Plan và Action Record.
10. `/sdd-lint`, `/sdd-audit`, `/sdd-trace`, `/sdd-sync` tạo delivery evidence.

**Kết quả mong đợi:** Chỉ task có review, profile binding và exact command hợp lệ mới được complete.

## 4. Requirement, contract hoặc plan thay đổi

```text
/sdd-update --feature=<slug> --artifact=<context|spec|plan|tasks> --reason="..."
```

1. Ghi Change Impact: intent/requirement/assumption đổi, Feature Lock impact, material category, downstream artifact bị invalid, trace/test/sync và review follow-up.
2. Context đổi actor, boundary, constraint hoặc risk phải explicit quyết định có cần sửa Spec không.
3. Spec đổi phải đánh giá Plan và Tasks trước khi resume.
4. Review recommendation mới; review cũ không còn hiệu lực.
5. Chạy `/sdd-trace --feature=<slug> --diff`; sync shared contract khi áp dụng.

## 5. Test hoặc CI thất bại

1. Lưu exact command và output.
2. Phân loại failure.
   - Implementation defect: chỉ sửa trong approved task/file boundary.
   - Spec gap: update/review Spec.
   - Profile/configuration gap: update/review profile.
   - Material/high-risk mutation: cần checkpoint trước action.
3. Chạy lại exact approved command.
4. Cập nhật Action Record, trace và sync decision.

Không thêm test filter, skip hoặc mock chỉ để biến failure thành success.

## 6. Material state change

Trước shared/public contract, schema/business-data, permission/security/dependency/runtime configuration, hoặc external/irreversible action:

1. Phân loại thay đổi trong Plan/Task/Shadow Plan.
2. Xác định contract owner và recovery/rollback information khi áp dụng.
3. Lưu Human checkpoint bằng review evidence.
4. Chỉ thực thi action/file boundary đã approved.
5. Ghi result và trace/sync cần thiết vào Action Record.

## 7. Shared contract và multi-agent dispatch

1. Lead đọc frozen contract trong `.sdd/shared_context.md`.
2. Dispatch phải có task ID, frozen contract version, ownership/file boundary, selected profile bindings, exact commands, allowed action/checkpoint và audit evidence reference.
3. Chỉ chạy parallel khi ownership không overlap.
4. Contract owner hoặc Lead là actor duy nhất được mutate shared contract.
5. Contract drift, overlap, evidence mismatch hoặc material decision mới phải dừng task bị ảnh hưởng.
6. Sau integration, Lead kiểm tra compatibility rồi trace/sync.

`.sdd/mcp-config.yaml` là policy specification. Runtime host enforcement phải được cấu hình riêng; file không tự chứng minh enforcement.

## 8. Tình huống Claude Code dispatcher

### Parallel-owned, low-risk batch

1. `TASKS.md` được approved; T001/T002 đã hoàn tất dependency, có exact commands, disjoint exclusive boundaries và `Dispatch readiness: parallel-owned`.
2. Lead quan sát Claude Code `Agent`, ghi runtime identity/enforcement evidence là `VERIFIED` hoặc `UNVERIFIED`, rồi chạy:

   ```text
   /sdd-dispatch --feature=<slug> --batch=<batch-id> --task=<T001,T002>
   ```

3. Mỗi worker trả changed paths, Action Record, exact command/result, requirement coverage, blocker và sync-back decision.
4. Lead kiểm tra boundaries/integration rồi mới đánh task `[x]`. Thiếu return evidence thì không được complete.

### Blocked cross-contract batch

1. Batch thay frozen shared contract hoặc public behavior.
2. Lead tạo `.sdd/reviews/dispatch-<feature>-<batch>.md` với canonical recommendation; ghi exact contract/version, tasks, boundary và allowed checkpoint.
3. Cho đến khi Human Final Review là `APPROVED`, `/sdd-dispatch` vẫn `AWAITING_APPROVAL`; worker không được mutation.
4. Drift hoặc scope change là `BLOCKED`. Sau năm consecutive eligible retry failure, đặt `ESCALATED`, giữ `[/]`, tạo dispatch review report và yêu cầu Human disposition; không mở rộng permissions.

## 9. Handoff và resume

### Handoff

```text
/sdd-handoff --feature=<slug>
```

Đảm bảo `Current Handoff State` có Intent/DoD, approved scope, active contract version, profile binding, exact command/result, checkpoint, next decision/command, blockers và Action Record.

### Resume

```text
/sdd-resume --feature=<slug>
```

Resume block khi binding, review, checkpoint, contract ownership hoặc exact command bắt buộc bị thiếu. Legacy high-risk work cần Human disposition thay vì automatic invalidation.

## 10. Self-heal evidence collection

```bash
./scripts/self-heal.sh --feature=<slug> --task=<task-id> \
  --test-cmd="<exact approved command>" \
  --approved-evidence=.sdd/architecture-profile.md \
  --max-attempts=1 \
  --scope-category=implementation-defect
```

Script là opt-in và evidence-only. Nó reject non-implementation scope, không repair, commit, push, deploy, approve hoặc thực hiện external action.

## 11. Delivery

1. Verify intended diff và evidence.
2. Chạy `/git-validate --scope=commit`.
3. Khi `READY`, Agent chỉ tạo commit nếu Human yêu cầu.
4. Human chạy `git push -u origin <head>`.
5. Team delivery chạy strict remote validation và chỉ tạo PR sau khi Human xác nhận content. Solo bỏ Pull Request overhead.

## 12. Thay đổi Constitution

Dùng `/sdd-rfc`. Không sửa `CONSTITUTION.md` trực tiếp sau template release. Cần RFC đã approved trước constitutional governance changes.
