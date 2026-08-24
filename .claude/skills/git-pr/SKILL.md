---
name: git-pr
description: Kiểm định thay đổi remote-first và tạo Pull Request chỉ khi mọi gate đạt
user-invocable: true
---

# Git Pull Request Operator (`/git-pr`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Status tokens (`READY`, `BLOCKED`), Git/GitHub output, and code identifiers are language-invariant.

Dùng để tạo Pull Request. PR luôn dùng remote diff và bắt buộc qua `/git-validate --scope=pr --strict` trước `gh pr create`.

## Tham số

- `--base=<branch>`: Target branch; mặc định là default branch của `origin`.
- `--head=<branch>`: Source branch; mặc định branch hiện tại.
- `--feature=<feature-slug>`: Tùy chọn, truyền tiếp cho validator.
- `--push`: Cho phép push source branch khi user yêu cầu rõ. Không có flag thì không push.
- `--draft`: Tạo draft PR sau khi gate `PASS`.
- `--issue=<id>`: Tùy chọn, liên kết issue trong body.

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

3. Local commit chưa push: không tạo PR dựa trên local-only commit. Chỉ `git push -u origin <head>` khi user dùng `--push` hoặc yêu cầu rõ. Sau push, fetch lại và xác minh local `HEAD == origin/<head>`.
4. Block nếu head là `main`, `master`, `production`, `prod` hoặc `release/*`; detached HEAD, dirty worktree, merge/rebase/cherry-pick chưa xử lý; remote base/head thiếu; remote diff rỗng; PR đã tồn tại; branch conflict với base; required check fail hoặc review state `CHANGES_REQUESTED`.
5. Phân tích remote diff:

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

   Chỉ tiếp tục khi trả `GIT VALIDATION: READY`.
7. Title/body dùng conventional format, imperative, dưới 72 ký tự, không version number hoặc AI attribution. Body gồm Summary, Validation evidence, Test plan, Related issue.
8. Kiểm tra PR chưa tồn tại; nếu request chưa chứa approval tạo PR, yêu cầu user xác nhận nội dung outward-facing.
9. Sau confirmation và `READY`, chạy:

   ```bash
   gh pr create --base <base> --head <head> --title "..." --body-file <temporary-body-file>
   ```

   Dùng `--draft` khi user yêu cầu. Không merge, close, force-push hoặc bypass check.

## Xác minh sau tạo

```bash
gh pr view <pr-url-or-number> --json number,url,state,baseRefName,headRefName,statusCheckRollup
```

Báo PR URL, validation result và check pending/failing. Pending check không được báo là green.

## Xử lý lỗi

- Push bị từ chối: dừng, đề xuất `git pull --rebase`, resolve conflict rồi validation lại.
- Validation blocked: báo blocker và lệnh khắc phục, không tạo PR.
- `gh` auth/API failure: báo lỗi, không retry vô hạn.
- Conflict: dừng; không tự resolve hoặc force-push.

## Output

```text
✓ remote diff: origin/<base>...origin/<head>
✓ validation: READY
✓ checks: passed | pending | failed
✓ pull request: <url>
```
