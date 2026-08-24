---
name: git-commit
description: Stage và commit thay đổi chỉ sau khi repository validation gate đạt
user-invocable: true
---

# Git Commit Operator (`/git-commit`)

Dùng để tạo commit an toàn. Không chạy `git commit` trước khi `/git-validate --scope=commit` trả `READY`.

## Tham số

- `--message=<message>`: Commit message; thiếu thì đề xuất từ diff và yêu cầu user xác nhận.
- `--type=<feat|fix|perf|docs|test|refactor|chore|build|ci>`: Tùy chọn.
- `--scope=<scope>`: Tùy chọn.
- `--feature=<feature-slug>`: Tùy chọn, truyền tiếp cho validator.
- `--files=<path,...>`: Tùy chọn; chỉ stage path này. Không có thì hiển thị danh sách và yêu cầu xác nhận trước khi stage intended changes.
- `--push`: Chỉ push sau commit khi user yêu cầu rõ trong cùng request.

## Quy trình

1. Đọc `AGENTS.md`, `CONSTITUTION.md`, `CLAUDE.md` và skill reference liên quan.
2. Kiểm tra worktree:

   ```bash
   git status --short
   git diff --stat
   git diff --name-only
   ```

3. Không stage forbidden file: `.env`, private key, credential, secret, `node_modules/`, `dist/`; không stage thay đổi ngoài scope user yêu cầu.
4. Stage path đã xác nhận:

   ```bash
   git add -- <path>...
   git diff --cached --stat
   git diff --cached --name-only
   ```

5. Tách thay đổi khác type/scope; tách code, test, docs, dependency/config khi không cùng intent. Hơn mười file không liên quan thì chia nhiều commit. File `.claude/` chỉ dùng prefix `feat`, `fix` hoặc `perf`.
6. Commit message theo `type(scope): description`, dưới 72 ký tự, imperative/present tense, không dấu chấm cuối và không AI attribution. Feature SDD thêm feature/spec version khi `add-execute` yêu cầu.
7. Chạy gate ngay trước commit:

   ```text
   /git-validate --scope=commit --feature=<feature-slug>
   ```

   Gate phải trả `GIT VALIDATION: READY`; `BLOCKED` thì dừng, không tự sửa, reset, amend hoặc bypass check.
8. Sau `READY` và user xác nhận commit message, chạy:

   ```bash
   git commit -m "type(scope): description"
   git rev-parse --short HEAD
   git log -1 --format=%s
   ```

9. `--push` chỉ thực hiện khi user yêu cầu; dùng `/git-pr` hoặc quy trình push của `ak-git`. Không force-push.

## Safety gates

- Không có thay đổi: báo `NO-OP`, không commit.
- Có secret/forbidden file: block, chỉ hiện path/pattern đã mask.
- Validation/commit hook fail: block, báo lỗi nguyên văn và giữ nguyên worktree; không retry vô hạn.
- `main`, `master`, `production`, `prod`, `release/*`: không force-push hoặc bypass protection.
- Destructive operation như `reset`, `checkout`, `clean`, `amend` cần explicit confirmation.

## Output

```text
✓ staged: N files (+X/-Y lines)
✓ validation: READY
✓ commit: HASH type(scope): description
✓ pushed: yes | no | not requested
```
