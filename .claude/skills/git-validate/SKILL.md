---
name: git-validate
description: Repository validation gate that MUST pass before commit, push, or Pull Request
user-invocable: true
---

# Git Repository Validation Gate (`/git-validate`)

Dùng skill này trước mọi commit, push hoặc Pull Request. Đây là single source of truth cho validation của Git Operator. Gate **fail closed**: chỉ trả `READY` khi mọi check bắt buộc đạt.

## Tham số

- `--scope=commit|pr`: bắt buộc.
  - `commit`: kiểm tra staged diff (`git diff --cached`).
  - `pr`: kiểm tra diff trên remote (`origin/<base>...origin/<head>`), không dùng local diff làm nguồn kết luận.
- `--feature=<feature-slug>`: tùy chọn; giới hạn SDD checks vào feature.
- `--base=<branch>`: dùng với `pr`; mặc định branch mặc định của remote.
- `--head=<branch>`: dùng với `pr`; mặc định branch hiện tại.
- `--strict`: biến mọi `WARNING` thành `BLOCKED`, bắt buộc cho PR.

## Nguyên tắc bắt buộc

1. Không commit, push, merge, tạo PR hoặc sửa file trong skill này.
2. Không hiển thị secret thật. Chỉ hiển thị path, loại pattern và dòng đã mask.
3. Không gọi `PASS` cho bước chưa chạy. Kết quả hợp lệ chỉ là `PASS`, `FAIL`, hoặc `N/A (reason)`.
4. Nếu command không tồn tại, script test không có, hoặc prerequisite bị thiếu: báo `N/A` với lý do. Với source behavior có thể kiểm thử mà không có test command, báo `FAIL`.
5. Không tự sửa lỗi, reset, checkout, stash, amend hoặc discard changes.
6. Nếu phát hiện lỗi, dừng tại gate liên quan và đưa lệnh khắc phục; không tiếp tục tới commit/PR.

## Quy trình

### 1. Xác định repository và nguồn diff

Đọc `AGENTS.md`, `CLAUDE.md`, `CONSTITUTION.md` trước khi kiểm tra.

#### Commit scope

```bash
git rev-parse --show-toplevel
git symbolic-ref --short -q HEAD
git status --short
git diff --cached --stat
git diff --cached --name-only
```

- Block detached HEAD.
- Block merge/rebase/cherry-pick đang dở (`.git/MERGE_HEAD`, `.git/rebase-merge`, `.git/rebase-apply`, `.git/CHERRY_PICK_HEAD`).
- Block nếu staged diff rỗng.
- Chỉ kiểm tra nội dung được stage; file unstaged không thuộc commit hiện tại nhưng phải được báo để người dùng biết.

#### PR scope

```bash
git fetch --prune origin
git symbolic-ref --short refs/remotes/origin/HEAD
git rev-parse --verify "origin/<base>"
git rev-parse --verify "origin/<head>"
git diff --name-status "origin/<base>...origin/<head>"
git diff --stat "origin/<base>...origin/<head>"
git status --short
```

- Block detached HEAD, missing remote, missing base/head, unresolved Git operation, dirty worktree, base branch as head, and empty remote diff.
- Block khi local `HEAD` khác `origin/<head>`; PR phải phản ánh commit đã push.
- Nếu branch chưa có trên remote, không kết luận PR ready. `/git-pr` phải push khi người dùng yêu cầu, rồi chạy lại gate.
- Dùng `origin/<base>...origin/<head>` cho mọi kết luận về PR. Không dùng `git diff main...HEAD`.

### 2. Security và file policy gate

Quét đúng diff tương ứng với scope. Pattern cần kiểm tra:

```text
AKIA[0-9A-Z]{16}
sk-[A-Za-z0-9_-]+
(api[_-]?key|auth[_-]?token|client[_-]?secret|password|passwd|credential|private[_-]?key|jwt)
(mongodb|postgres|mysql|redis)://
-----BEGIN .*PRIVATE KEY-----
```

Kiểm tra cả file path:

```text
.env, .env.*, *.pem, *.key, *.p12, credentials.json, secrets.json,
config/private.*, node_modules/, dist/
```

- `.env.example` được phép nếu không chứa credential thật.
- Chỉ block khi pattern đi kèm giá trị có khả năng là credential thật hoặc file path bị cấm. Các pattern nằm trong chính tài liệu kiểm định, placeholder (`<value>`, `example`, `REDACTED`) và tên biến không có giá trị không phải secret.
- Scan phần dòng được thêm/sửa, ưu tiên assignment/URL/key format; không block chỉ vì tài liệu nhắc đến từ `password`, `token`, `secret` hoặc regex policy.
- Không dùng `grep` output nguyên văn nếu có khả năng lộ giá trị. Mask values trước khi báo cáo.
- Nếu `CONSTITUTION.md` thay đổi, yêu cầu RFC approved tương ứng trong `.sdd/rfcs/`. Không chấp nhận thay đổi Constitution chỉ vì commit message giải thích lý do.

### 3. SDD governance gate

Xác định các path bị ảnh hưởng từ diff:

- `.sdd/features/*/SPEC.md`: chạy `/sdd-lint --feature=<slug>`.
- `src/`, `tests/`, `.sdd/features/*/PLAN.md`, `.sdd/features/*/TASKS.md`, `CONSTITUTION.md`, `CLAUDE.md`, `AGENTS.md`: chạy `/sdd-audit` với feature scope nếu xác định được, nếu không chạy toàn repo.
- Thay đổi `SPEC.md`, usecase, test hoặc `@ears`: chạy `/sdd-trace --feature=<slug> --diff`.
- Thay đổi `.sdd/features/`, `.sdd/README.md`, hoặc `.sdd/shared_context.md`: yêu cầu người dùng chạy `/sdd-sync` trước, sau đó kiểm tra không còn thay đổi registry/contracts ngoài intended diff. Validator không tự gọi skill có khả năng sửa file.

Quy tắc kết quả:

- `sdd-lint` error: `FAIL`.
- `sdd-audit` vi phạm Layer 1 (`SEC-*`, `DATA-*`) hoặc hard rule: `FAIL`.
- Broken trace, orphan code, missing test trace: `FAIL`.
- Layer 2/3 warning: `WARNING`; với `--strict` hoặc scope PR: `FAIL` nếu chưa có giải trình được chấp thuận.
- Nếu feature có `SPEC.md` nhưng chưa ở trạng thái `APPROVED & LOCKED` và diff chạm source/test feature đó: `FAIL`.
- Nếu thay đổi source behavior nhưng không xác định được requirement/test liên quan: `FAIL`, yêu cầu cập nhật Spec/trace trước.
- Khi diff có SDD artifact, governance file hoặc review report, phải xác nhận recommendation/review block theo `.claude/skills/_shared/ai-review-protocol.md` tồn tại và không ở trạng thái `REVISE`/`REJECTED`.
- `APPROVED` chỉ hợp lệ khi có decision, reviewer identity và timestamp; Agent-generated `APPROVED` không được chấp nhận.
- Diff làm thay đổi artifact đã approved nhưng không tạo recommendation mới hoặc invalidate review: `FAIL`.

### 4. Test và quality gate

Đọc `package.json` nếu tồn tại. Chạy các script có liên quan, theo thứ tự:

```bash
npm test
npm run lint
npm run typecheck
npm run build
```

- Chỉ chạy script thực sự tồn tại; ghi command và exit result.
- Nếu source behavior tồn tại mà không có test script hoặc test files phù hợp: `FAIL`.
- Nếu repository không có source/test/package manifest: `N/A (repository template has no executable project)`.
- Không nuốt output hoặc đổi failure thành warning.
- Test fail, lint fail, typecheck fail hoặc build fail: `FAIL`.

### 5. Báo cáo gate

Báo cáo theo format ổn định:

```text
GIT VALIDATION: READY | BLOCKED
scope: commit | pr
source: <staged diff | origin/base...origin/head>

[PASS] repository integrity — evidence
[PASS] secret and forbidden-file scan — evidence
[PASS] constitution and RFC policy — evidence
[PASS|N/A] SDD lint — evidence/reason
[PASS|N/A] SDD audit — evidence/reason
[PASS|N/A] SDD trace — evidence/reason
[PASS|N/A] SDD sync — evidence/reason
[PASS|N/A] tests — command/result/reason
[PASS|N/A] lint/typecheck/build — command/result/reason

blockers:
- <path:line or command and remediation>
warnings:
- <warning and explicit rationale>
next step:
- <exact remediation command>
```

`READY` chỉ hợp lệ khi:

- Không có `FAIL`.
- Scope `pr` không có `WARNING` unresolved; tương đương `--strict`.
- Mọi `N/A` có lý do hợp lệ.
- Diff không rỗng và nguồn diff đúng scope.
