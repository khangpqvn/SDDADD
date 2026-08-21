---
name: git-pr
description: Validate remote-first changes and create a Pull Request only after all gates pass
user-invocable: true
---

# Git Pull Request Operator (`/git-pr`)

Dùng để tạo Pull Request. PR luôn dùng remote diff và bắt buộc qua `/git-validate --scope=pr --strict` trước `gh pr create`.

## Tham số

- `--base=<branch>`: target branch; mặc định branch mặc định của `origin`.
- `--head=<branch>`: source branch; mặc định branch hiện tại.
- `--feature=<feature-slug>`: tùy chọn, truyền tiếp cho validator.
- `--push`: cho phép push source branch khi user yêu cầu rõ. Không có flag này thì không push.
- `--draft`: tạo draft PR sau khi gate PASS.
- `--issue=<id>`: tùy chọn, liên kết issue trong body.

## Quy trình remote-first

1. Kiểm tra quyền và trạng thái trước thao tác outward-facing:

   ```bash
   git status --short
   git branch --show-current
   git remote -v
   gh auth status
   ```

2. Xác định default branch và fetch remote:

   ```bash
   git fetch --prune origin
   git symbolic-ref --short refs/remotes/origin/HEAD
   git rev-parse --verify origin/<base>
   git rev-parse --verify origin/<head>
   ```

3. Nếu local có commit chưa push:
   - Không tạo PR dựa trên local-only commit.
   - Chỉ chạy `git push -u origin <head>` nếu user đã yêu cầu `--push` hoặc nói rõ push.
   - Sau push, fetch lại và xác nhận local `HEAD == origin/<head>`.
4. Block các trường hợp:
   - head là `main`, `master`, `production`, `prod`, hoặc `release/*`;
   - detached HEAD, dirty worktree, unresolved merge/rebase/cherry-pick;
   - thiếu remote base/head hoặc remote head chưa phản ánh local HEAD;
   - remote diff rỗng hoặc đã có PR mở cho cùng base/head;
   - branch có conflict với base;
   - required checks hiện tại fail hoặc review state là `CHANGES_REQUESTED`.
5. Phân tích đúng remote diff:

   ```bash
   git log --oneline origin/<base>...origin/<head>
   git diff --stat origin/<base>...origin/<head>
   git diff --name-status origin/<base>...origin/<head>
   ```

   Không dùng `git diff main...HEAD` để kết luận PR.
6. Chạy gate bắt buộc:

   ```text
   /git-validate --scope=pr --base=<base> --head=<head> --feature=<feature-slug> --strict
   ```

   Chỉ tiếp tục nếu gate trả `GIT VALIDATION: READY`.
7. Tạo title/body:
   - Title conventional, imperative, dưới 72 ký tự, không version number.
   - Body gồm Summary, Validation evidence, Test plan, Related issue.
   - Không thêm AI attribution.
8. Kiểm tra PR chưa tồn tại, sau đó yêu cầu user xác nhận nội dung outward-facing nếu request chưa bao gồm đồng ý tạo PR.
9. Chỉ sau xác nhận và `READY`, chạy:

   ```bash
   gh pr create --base <base> --head <head> --title "..." --body-file <temporary-body-file>
   ```

   Dùng `--draft` khi user yêu cầu. Không merge, close, force-push hoặc bypass checks trong skill này.

## Post-create verification

```bash
gh pr view <pr-url-or-number> --json number,url,state,baseRefName,headRefName,statusCheckRollup
```

Báo rõ PR URL, validation result, checks pending/failing. Pending checks không được báo là green.

## Failure handling

- Push rejected: dừng, đề xuất `git pull --rebase`, resolve conflicts rồi chạy lại validation.
- Validation blocked: báo blocker + lệnh khắc phục, không tạo PR.
- `gh` auth/API failure: báo lỗi, không retry vô hạn.
- Conflict: dừng; không tự resolve hoặc force-push.

## Output

```text
✓ remote diff: origin/<base>...origin/<head>
✓ validation: READY
✓ checks: passed | pending | failed
✓ pull request: <url>
```
