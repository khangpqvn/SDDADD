---
name: git-commit
description: Stage and commit changes only after the repository validation gate passes
user-invocable: true
---

# Git Commit Operator (`/git-commit`)

Dùng để tạo commit an toàn. Không chạy `git commit` cho đến khi `/git-validate --scope=commit` trả `READY`.

## Tham số

- `--message=<message>`: commit message; nếu thiếu, đề xuất từ diff và yêu cầu user xác nhận.
- `--type=<feat|fix|perf|docs|test|refactor|chore|build|ci>`: tùy chọn.
- `--scope=<scope>`: tùy chọn.
- `--feature=<feature-slug>`: tùy chọn, truyền tiếp cho validator.
- `--files=<path,...>`: tùy chọn; chỉ stage các path này. Không có thì hiển thị danh sách và yêu cầu xác nhận trước khi stage toàn bộ intended changes.
- `--push`: chỉ push sau commit khi user yêu cầu rõ trong cùng request.

## Quy trình

1. Đọc `AGENTS.md`, `CONSTITUTION.md`, `CLAUDE.md` và các skill references liên quan.
2. Kiểm tra:

   ```bash
   git status --short
   git diff --stat
   git diff --name-only
   ```

3. Không stage các file forbidden (`.env`, private keys, credentials, secrets, `node_modules/`, `dist/`). Không stage thay đổi ngoài phạm vi user yêu cầu.
4. Stage path đã xác nhận:

   ```bash
   git add -- <path>...
   git diff --cached --stat
   git diff --cached --name-only
   ```

5. Áp dụng split logic của `ak-git`:
   - Tách các thay đổi khác type/scope.
   - Tách code, tests, docs, dependencies/config khi chúng không cùng một intent.
   - Nếu hơn 10 file unrelated, chia thành nhiều commit.
   - Các file `.claude/` chỉ dùng prefix `feat`, `fix`, hoặc `perf`.
6. Kiểm tra commit message:
   - Format `type(scope): description`.
   - Dưới 72 ký tự, imperative/present tense, không dấu chấm cuối.
   - Không chứa AI attribution.
   - Nếu source thuộc feature SDD, thêm feature/spec version theo quy tắc của `add-execute` khi cần.
7. Chạy gate ngay trước commit:

   ```text
   /git-validate --scope=commit --feature=<feature-slug>
   ```

   Gate phải trả `GIT VALIDATION: READY`. Nếu `BLOCKED`, dừng; không tự sửa, reset, amend hoặc bỏ qua check.
8. Chỉ sau `READY`, và sau xác nhận commit message, chạy:

   ```bash
   git commit -m "type(scope): description"
   git rev-parse --short HEAD
   git log -1 --format=%s
   ```

9. Nếu `--push` được user yêu cầu, kiểm tra lại branch/upstream và dùng `/git-pr` hoặc quy trình push của `ak-git`. Không tự force-push.

## Safety gates

- No changes: báo `NO-OP`, không tạo commit.
- Secret hoặc forbidden file: block commit, chỉ hiển thị path/pattern đã mask.
- Validation fail: block commit.
- Commit hook fail: báo nguyên văn lỗi và giữ nguyên worktree; không retry vô hạn.
- `main`, `master`, `production`, `prod`, `release/*`: không force-push và không tự bypass protection.
- Destructive operation (`reset`, `checkout`, `clean`, `amend`): cần explicit confirmation.

## Output

```text
✓ staged: N files (+X/-Y lines)
✓ validation: READY
✓ commit: HASH type(scope): description
✓ pushed: yes | no | not requested
```
