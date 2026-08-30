---
name: git-pr
description: Kiểm định thay đổi remote-first; tạo Pull Request (team) hoặc push trực tiếp (solo) khi mọi gate đạt
user-invocable: true
---

# Git Push / Pull Request Operator (`/git-pr`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Status tokens (`READY`, `BLOCKED`), Git/GitHub output, and code identifiers are language-invariant.

Dùng để push code lên remote hoặc tạo Pull Request. **Solo mode**: push trực tiếp lên branch hiện tại, không tạo PR. **Team mode**: tạo Pull Request, luôn dùng remote diff và bắt buộc qua `/git-validate --scope=pr --strict` trước `gh pr create`.

## Solo mode detection

Đọc `.sdd/shared_context.md`. Nếu file chứa `## 1A. Solo Developer Context` và section 1B không active (hoặc `--team-size=solo` được truyền), dùng **solo mode**.

Solo mode bỏ qua PR creation flow; thay bằng push trực tiếp và xác minh.

## Tham số

- `--base=<branch>`: Target branch; mặc định là default branch của `origin`. Solo mode: bỏ qua (push lên branch hiện tại).
- `--head=<branch>`: Source branch; mặc định branch hiện tại.
- `--feature=<feature-slug>`: Tùy chọn, truyền tiếp cho validator.
- `--push`: Solo mode luôn push. Team mode: chỉ push khi user yêu cầu rõ.
- `--draft`: Tạo draft PR (team mode only). Bỏ qua trong solo mode.
- `--issue=<id>`: Tùy chọn, liên kết issue trong body (team mode only).
- `--team-size=solo|team`: Tùy chọn; override solo detection từ shared_context.

## Quy trình — Solo mode

Solo mode push trực tiếp, không tạo PR. Developer là Human Director, tự approve và tự push.

1. Kiểm tra trạng thái:

   ```bash
   git status --short
   git branch --show-current
   git remote -v
   ```

2. Block nếu detached HEAD, dirty worktree (unstaged/uncommitted), merge/rebase/cherry-pick chưa xử lý, hoặc branch là `main`/`master`/`production`/`prod`/`release/*`.

3. Fetch remote và xác minh state:

   ```bash
   git fetch --prune origin
   ```

4. Local commit chưa push: push lên branch hiện tại. Không cần `--push` flag trong solo mode.

5. Chạy gate bắt buộc:

   ```text
   /git-validate --scope=pr --base=<base> --head=<head> --feature=<feature-slug> --strict
   ```

   Solo mode: `--strict` vẫn áp dụng nhưng WARNING không block (chỉ block khi có FAIL). Chỉ tiếp tục khi trả `GIT VALIDATION: READY`.

6. Push trực tiếp:

   ```bash
   git push -u origin <head>
   ```

   Không force-push. Nếu push bị từ chối: dừng, đề xuất `git pull --rebase`, resolve conflict rồi validation lại.

7. Xác minh sau push:

   ```bash
   git log --oneline origin/<head> -5
   git rev-parse --verify origin/<head>
   ```

   Xác minh `HEAD == origin/<head>`.

## Quy trình — Team mode

Team mode tạo Pull Request. Luôn dùng remote diff và bắt buộc qua `/git-validate --scope=pr --strict` trước `gh pr create`.

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

10. Xác minh sau tạo:

    ```bash
    gh pr view <pr-url-or-number> --json number,url,state,baseRefName,headRefName,statusCheckRollup
    ```

    Báo PR URL, validation result và check pending/failing. Pending check không được báo là green.

## Xử lý lỗi

- Push bị từ chối: dừng, đề xuất `git pull --rebase`, resolve conflict rồi validation lại.
- Validation blocked: báo blocker và lệnh khắc phục, không push (solo) hoặc không tạo PR (team).
- `gh` auth/API failure (team mode): báo lỗi, không retry vô hạn.
- Conflict: dừng; không tự resolve hoặc force-push.

## Output

### Solo mode

```text
✓ validation: READY
✓ checks: passed | pending | failed
✓ pushed: origin/<head> → <commit range>
✓ commits ahead: <count>
```

### Team mode

```text
✓ remote diff: origin/<base>...origin/<head>
✓ validation: READY
✓ checks: passed | pending | failed
✓ pull request: <url>
```
