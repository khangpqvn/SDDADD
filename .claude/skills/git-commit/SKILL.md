---
name: git-commit
description: Stage và commit thay đổi; solo mode auto-push, team mode chỉ commit
user-invocable: true
---

# Git Commit Operator (`/git-commit`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Status tokens (`READY`, `BLOCKED`, `NO-OP`), Git output, and code identifiers are language-invariant.

Dùng để tạo commit an toàn. Không chạy `git commit` trước khi `/git-validate --scope=commit` trả `READY`. **Solo mode**: tự động push sau commit (dùng `/git-pr` hoặc push trực tiếp). **Team mode**: chỉ commit, push cần `--push` flag hoặc `/git-pr`.

## Solo mode detection

Đọc `.sdd/shared_context.md`. Nếu file chứa `## 1A. Solo Developer Context` và section 1B không active (hoặc `--team-size=solo` được truyền), dùng **solo mode**.

Solo mode tự động push sau commit; không cần `--push` flag.

## Tham số

- `--message=<message>`: Commit message; thiếu thì đề xuất từ diff và yêu cầu user xác nhận.
- `--type=<feat|fix|perf|docs|test|refactor|chore|build|ci>`: Tùy chọn.
- `--scope=<scope>`: Tùy chọn.
- `--feature=<feature-slug>`: Tùy chọn, truyền tiếp cho validator.
- `--files=<path,...>`: Tùy chọn; chỉ stage path này. Không có thì hiển thị danh sách và yêu cầu xác nhận trước khi stage intended changes.
- `--push`: Solo mode: luôn push, flag bị bỏ qua. Team mode: chỉ push sau commit khi user yêu cầu rõ trong cùng request.
- `--team-size=solo|team`: Tùy chọn; override solo detection từ shared_context.

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

9. **Solo mode**: sau commit, tự động push lên branch hiện tại:

   ```bash
   git push -u origin <head>
   ```

   Xác minh push thành công bằng `git rev-parse --verify origin/<head>`. Không force-push.

   **Team mode**: `--push` chỉ thực hiện khi user yêu cầu; dùng `/git-pr` hoặc quy trình push của `ak-git`. Không force-push.

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
✓ pushed: yes (solo) | no (team, not requested)
```
