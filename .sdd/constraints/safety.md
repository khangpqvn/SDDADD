# CONSTRAINT LAYER 3: SAFETY RULES
# Version: 1.0.0
# Scope: All agents — absolute safety floor, no exceptions
# Reference: Slide 10.4 — 3-Layer Constraint Hierarchy
# CRITICAL: Vi phạm layer này → CI/CD FAIL ngay lập tức

---

## 1. Database Safety (HARD BLOCK)

| Rule ID  | Rule                                                                         | Enforcement          |
| :------- | :--------------------------------------------------------------------------- | :------------------- |
| DB-S-01  | **BANNED**: `DROP TABLE`, `DROP DATABASE`, `TRUNCATE` trên production        | Pre-commit hook + CI |
| DB-S-02  | **BANNED**: `DELETE FROM <table>` không có `WHERE` clause                   | Static analysis      |
| DB-S-03  | **BANNED**: `UPDATE <table>` không có `WHERE` clause                        | Static analysis      |
| DB-S-04  | **BANNED**: Raw SQL string interpolation (SQL injection vector)              | Code review gate     |
| DB-S-05  | Migration rollback plan PHẢI có trước khi chạy migration lên production      | Human review gate    |
| DB-S-06  | Backup verification bắt buộc trước mọi schema migration có breaking changes  | Human review gate    |

---

## 2. Git Commit Safety

| Rule ID  | Rule                                                                         | Enforcement          |
| :------- | :--------------------------------------------------------------------------- | :------------------- |
| GIT-S-01 | **BANNED**: Commit `.env`, `.env.*` (trừ `.env.example`)                    | .gitignore + hook    |
| GIT-S-02 | **BANNED**: Commit files chứa pattern `sk-ant-`, `sk-proj-`, `-----BEGIN`  | git-secrets hook     |
| GIT-S-03 | **BANNED**: `git push --force` lên `main` / `master` / `production`        | Branch protection    |
| GIT-S-04 | **BANNED**: Commit trực tiếp lên `main` — phải qua PR + review             | Branch protection    |
| GIT-S-05 | Commit message PHẢI theo Conventional Commits: `feat|fix|refactor|test|...` | Commit-msg hook      |

---

## 3. Secret & Credential Safety

- **ZERO tolerance**: Không output, ghi, log, hoặc commit bất kỳ:
  - API keys (`sk-ant-*`, `sk-proj-*`, `AKIA*`, `ghp_*`)
  - JWT secrets, private keys (`-----BEGIN RSA/EC PRIVATE KEY-----`)
  - Database connection strings chứa password
  - Passwords, PINs, OTPs dưới mọi hình thức

- **Detection**: Chạy `gitleaks` / `trufflehog` trong pre-commit hook và CI pipeline

---

## 4. Agent Execution Safety

| Rule ID  | Rule                                                                            |
| :------- | :------------------------------------------------------------------------------ |
| AGT-S-01 | Agent KHÔNG được self-approve recommendation — chỉ Human Director có quyền     |
| AGT-S-02 | Agent PHẢI dừng sau 5 retry failures liên tiếp — escalate to Human Director    |
| AGT-S-03 | Agent KHÔNG được `git push`, `npm publish`, deploy production tự động          |
| AGT-S-04 | Agent KHÔNG được xóa files ngoài permitted paths mà không có human confirmation |
| AGT-S-05 | Mọi thay đổi schema DB PHẢI qua Human Final Review trước khi execute           |

---

## 5. Data Destruction Prevention

- **Production delete operations**: Luôn preview affected row count trước (SELECT count trước DELETE)
- **Cascade delete**: Phải explicit — không dùng `ON DELETE CASCADE` cho business data
- **Backup before migration**: Script migration PHẢI export backup path trong output log
- **Point-in-time recovery**: DB production PHẢI bật WAL / binlog cho recovery < 5 phút

---

## Violation Response

Khi phát hiện vi phạm layer này:
1. **STOP** — dừng mọi execution ngay lập tức
2. **REVERT** — nếu có thể rollback action vừa thực hiện
3. **ESCALATE** — báo ngay Human Director với evidence
4. **LOG** — ghi incident vào `.sdd/reviews/safety-incident-<timestamp>.md`
