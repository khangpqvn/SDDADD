---
name: git-pr
description: Kiểm định thay đổi remote-first; tạo Pull Request team hoặc hướng dẫn Human push solo
user-invocable: true
---

# Git Push / Pull Request Operator (`/git-pr`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Status tokens (`READY`, `BLOCKED`), Git/GitHub output, and code identifiers are language-invariant.

Dùng để chuẩn bị delivery remote. **Solo mode** không tạo PR: Agent kiểm định local delivery readiness và hướng dẫn Human tự `git push`. **Team mode** tạo Pull Request sau Human confirmation và remote diff; Agent không push branch thay Human.

## Solo mode detection

Đọc `# Collaboration Mode: team|solo` trong `.sdd/shared_context.md`. `--team-size=solo|team` override explicit cho invocation hiện tại. Không suy mode từ sự tồn tại section mẫu 1A/1.

Solo mode bỏ qua PR creation flow, nhưng giữ validation và Human-owned push.

## Tham số

- `--base=<branch>`: Target branch; mặc định là default branch của `origin`. Solo mode: dùng để báo target/delivery context, không push.
- `--head=<branch>`: Source branch; mặc định branch hiện tại.
- `--feature=<feature-slug>`: Tùy chọn, truyền tiếp cho validator.
- `--draft`: Tạo draft PR (team mode only).
- `--issue=<id>`: Tùy chọn, liên kết issue trong body (team mode only).
- `--team-size=solo|team`: Tùy chọn; override solo detection từ shared_context.

## Quy trình — Solo mode

Developer là Human Director và tự push. Agent không chạy `git push`.

1. Kiểm tra trạng thái:

   ```bash
   git status --short
   git branch --show-current
   git remote -v
   ```

2. Block nếu detached HEAD, dirty worktree (unstaged/uncommitted), merge/rebase/cherry-pick chưa xử lý, hoặc branch là `main`/`master`/`production`/`prod`/`release/*`.
3. Xác minh local commit và remote target; không fetch/push thay Human nếu outbound network action chưa được họ thực hiện.
4. Trước Human push, chạy `/git-validate --scope=pr --team-size=solo` trên local source `origin/<base>...HEAD`. `READY` ở giai đoạn này xác nhận local pre-push readiness; remote verification vẫn pending.
5. Khi local commit và validation evidence sẵn sàng, báo Human command, không thực thi:

   ```bash
   git push -u origin <head>
   ```

6. Sau khi Human push, họ có thể gọi lại `/git-pr --team-size=solo` để kiểm tra `HEAD == origin/<head>` và remote diff.

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

3. Local commit chưa push: dừng và hướng dẫn Human push branch rồi chạy lại validation. Không tạo PR dựa trên local-only commit.
4. Block nếu head là `main`, `master`, `production`, `prod` hoặc `release/*`; detached HEAD, dirty worktree, merge/rebase/cherry-pick chưa xử lý; remote base/head thiếu; remote diff rỗng; PR đã tồn tại; branch conflict với base; required check fail hoặc review state `CHANGES_REQUESTED`.
5. Phân tích remote diff và chạy `/git-validate --scope=pr --base=<base> --head=<head> --feature=<feature-slug> --strict`.
6. Title/body dùng conventional format, imperative, dưới 72 ký tự, không version number hoặc AI attribution. Body gồm Summary, Validation evidence, Test plan, Related issue.
7. Kiểm tra PR chưa tồn tại; nếu request chưa chứa approval tạo PR, yêu cầu user xác nhận nội dung outward-facing.
8. Sau confirmation và `READY`, chạy:

   ```bash
   gh pr create --base <base> --head <head> --title "..." --body-file <temporary-body-file>
   ```

   Dùng `--draft` khi user yêu cầu. Không merge, close, force-push hoặc bypass check.

## Xử lý lỗi

- Push bị từ chối: Human resolve theo repository policy, rồi validation lại.
- Validation blocked: báo blocker và lệnh khắc phục, không push hoặc tạo PR.
- `gh` auth/API failure (team mode): báo lỗi, không retry vô hạn.
- Conflict: dừng; không tự resolve hoặc force-push.

## Output

### Solo mode

```text
✓ validation: READY | BLOCKED
✓ delivery: Human must run git push -u origin <head>
✓ remote verification: pending Human push | HEAD == origin/<head>
```

### Team mode

```text
✓ remote diff: origin/<base>...origin/<head>
✓ validation: READY
✓ checks: passed | pending | failed
✓ pull request: <url>
```
