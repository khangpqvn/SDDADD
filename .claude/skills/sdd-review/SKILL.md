---
name: sdd-review
description: Ghi nhận Human Final Review bền vững cho SDD/ADD artifact và chuyển trạng thái sau khi review
user-invocable: true
---

# Human Review State Manager (`/sdd-review`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`HUMAN REVIEW: RECORDED`, `HUMAN REVIEW: BLOCKED`, `PENDING`, `APPROVED`, `REVISE`, `REJECTED`, `PENDING HUMAN REVIEW`, `APPLIED`, `NOT APPLICABLE`), file paths, and CLI commands are language-invariant.

Dùng skill này sau khi Human Director, Tech Lead hoặc reviewer được ủy quyền đã đọc recommendation và bằng chứng. Skill cập nhật đúng `Human Final Review` block trong artifact; Agent không được tự chọn quyết định thay cho Human.

## Tham số

### Chọn target — dùng đúng một cách

- `--target=<repo-relative-path>`: Đường dẫn tương đối tới một artifact có review block, ví dụ:
  - `.sdd/features/feat-user-register/CONTEXT.md`
  - `.sdd/features/feat-user-register/SPEC.md`
  - `.sdd/features/feat-user-register/PLAN.md`
  - `.sdd/features/feat-user-register/TASKS.md`
  - `.sdd/reviews/audit-feat-user-register.md`
  - `.sdd/rfcs/RFC-001-soft-delete-policy.md`
- Hoặc dùng cặp `--feature=<feature-slug> --artifact=<context|spec|plan|tasks>`.

Không dùng đồng thời `--target` với `--feature`/`--artifact`. Không nhận absolute path, path ngoài repository, `.env`, secret, private key, `node_modules/`, `dist/`, `.git/` hoặc `CONSTITUTION.md`; Constitution chỉ được thay đổi bằng RFC đã `APPROVED` theo `/sdd-rfc`.

### Ghi quyết định của Human — bắt buộc

- `--status=<APPROVED|REVISE|REJECTED>`
- `--decision="<quyết định cụ thể và phạm vi đã review>"`
- `--reviewer="<tên hoặc identity của người review>"`
- `--reviewed-at="<ISO-8601 timestamp có timezone>"`
- `--follow-up="<bước tiếp theo, command hoặc điều kiện đóng>"`

Không được bỏ trống bất kỳ trường nào. Dùng `--status=REVISE` khi artifact phải sửa rồi review lại; dùng `--status=REJECTED` khi hướng đề xuất không được chọn. `APPROVED`, `REVISE` và `REJECTED` đều phải có decision, reviewer, timestamp và follow-up.

## Quy trình thực hiện

1. **Xác định và kiểm tra target**:
   - Resolve target từ `--target` hoặc `--feature` + `--artifact`.
   - Chỉ cho phép feature artifact, `.sdd/reviews/` report hoặc `.sdd/rfcs/` RFC.
   - Đọc file trước khi sửa; dừng nếu file không tồn tại, có nhiều review block hoặc không có `## Human Final Review`.

2. **Đọc protocol và recommendation**:
   - Đọc `.claude/skills/_shared/ai-review-protocol.md`.
   - Bắt buộc có `## AI Agent Recommendation` với `Status: PENDING HUMAN REVIEW`.
   - Kiểm tra recommendation có `Scope`, `Recommendation`, `Evidence`, `Risks and assumptions`, `Alternatives considered` và `Required human decision` có nội dung.
   - Không dùng skill này để biến recommendation thiếu bằng chứng thành approval.

3. **Kiểm tra dữ liệu Human**:
   - `status` phải đúng một trong ba giá trị canonical.
   - `decision`, `reviewer`, `reviewed-at` và `follow-up` không được là placeholder như `<...>`, `TBD`, `TODO`, `PENDING` hoặc chuỗi rỗng.
   - `reviewed-at` phải là timestamp ISO-8601 có timezone, ví dụ `2026-08-22T00:45:00+07:00`.
   - `decision` phải nói rõ artifact/phạm vi đã duyệt và kết luận; `follow-up` phải nói bước tiếp theo hoặc lý do không có bước tiếp theo.

4. **Kiểm tra trạng thái cũ**:
   - Nếu review hiện tại đã là `APPROVED`, không ghi đè decision hợp lệ bằng lệnh mới.
   - Nếu artifact đã thay đổi sau approval, phải coi review cũ là không còn hợp lệ, đưa status về `PENDING`, tạo recommendation mới hoặc ghi nhận thay đổi scope trước khi Human review lại.
   - Nếu status cũ là `REVISE` hoặc `REJECTED`, chỉ cập nhật khi recommendation mới đã được Agent tạo và vẫn đang `PENDING HUMAN REVIEW`.

5. **Cập nhật đúng phạm vi**:
   - Chỉ thay đổi các dòng trong `## Human Final Review`: `Status`, `Decision`, `Reviewer`, `Reviewed at`, `Follow-up`.
   - Không sửa `AI Agent Recommendation`, requirement, architecture, tasks, evidence, changelog hoặc nội dung RFC.
   - Giữ nguyên thứ tự và tên field canonical.

6. **Xử lý Spec lock**:
   - Nếu target là `SPEC.md` và status là `APPROVED`, kiểm tra DoD tối thiểu: SemVer hợp lệ, requirement `REQ-XXX` không trùng, EARS/acceptance/out-of-scope hiện diện, recommendation hợp lệ và review đủ trường.
   - Chỉ sau khi các kiểm tra đạt mới đổi header `Status: DRAFT` thành `Status: APPROVED & LOCKED`.
   - Nếu status là `REVISE` hoặc `REJECTED`, giữ Spec ở trạng thái chưa lock và in bước xử lý tiếp theo.
   - Skill không sửa `CONSTITUTION.md`; RFC vẫn phải được phê duyệt bằng `/sdd-rfc --approve=<rfc-number>` theo contract riêng.

7. **Báo cáo kết quả**:

```text
HUMAN REVIEW: RECORDED
Target: <path>
Previous status: <old status>
New status: <APPROVED|REVISE|REJECTED>
Reviewer: <identity>
Reviewed at: <timestamp>
Spec lock: APPLIED | NOT APPLICABLE | BLOCKED
Next step: <follow-up>
```

Nếu validation fail, không sửa file và báo `HUMAN REVIEW: BLOCKED` kèm field/path/điều kiện cần khắc phục.

## Ví dụ

### Approve Context

```text
/sdd-review --feature=feat-user-register --artifact=context --status=APPROVED --decision="Đã duyệt problem, stakeholders, glossary và constraints; đủ cơ sở lập SPEC, chưa duyệt giải pháp kỹ thuật." --reviewer="Nguyen Van A, Product Owner" --reviewed-at="2026-08-22T00:45:00+07:00" --follow-up="/sdd-spec --feature=feat-user-register"
```

### Approve Spec và lock

```text
/sdd-review --target=.sdd/features/feat-user-register/SPEC.md --status=APPROVED --decision="Đã duyệt REQ-001 đến REQ-012, BDD, error cases, NFR và out-of-scope; cho phép lập Plan theo Spec v1.0.0." --reviewer="Nguyen Van B, Tech Lead" --reviewed-at="2026-08-22T01:00:00+07:00" --follow-up="/sdd-plan --feature=feat-user-register"
```

### Yêu cầu sửa

```text
/sdd-review --target=.sdd/features/feat-user-register/PLAN.md --status=REVISE --decision="Bổ sung phương án rollback migration và làm rõ dependency giữa repository với usecase." --reviewer="Nguyen Van B, Tech Lead" --reviewed-at="2026-08-22T01:10:00+07:00" --follow-up="Cập nhật PLAN.md, tạo recommendation mới rồi gọi lại /sdd-review sau khi review."
```

### Từ chối report

```text
/sdd-review --target=.sdd/reviews/audit-feat-user-register.md --status=REJECTED --decision="Không chấp thuận disposition vì Layer 1 failure còn mở; phải remediation trước delivery." --reviewer="Nguyen Van C, Human Director" --reviewed-at="2026-08-22T01:20:00+07:00" --follow-up="Sửa blocker, chạy lại /sdd-audit và tạo report review mới."
```

## Điều kiện không được tự động vượt qua

- Không có recommendation hoặc recommendation không ở `PENDING HUMAN REVIEW`.
- Thiếu một trong bốn trường Human bắt buộc.
- Target không nằm trong phạm vi cho phép.
- Review cũ đã `APPROVED` nhưng chưa có evidence artifact thay đổi và recommendation mới.
- Spec không đạt DoD tối thiểu khi cần lock.
- RFC chưa qua quy trình `/sdd-rfc --approve`.

`/sdd-review` chỉ ghi nhận quyết định do người gọi cung cấp. Nó không xác minh người gọi có đúng quyền trong tổ chức; quyền reviewer phải được kiểm soát bởi quy trình repository và Git/PR.
