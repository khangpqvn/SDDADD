# Constraint Layer 3: Quy tắc an toàn
# Version: 1.0.0
# Phạm vi: Mọi Agent — ngưỡng an toàn tuyệt đối, không có ngoại lệ
# Tham chiếu: Slide 10.4 — 3-Layer Constraint Hierarchy
# CRITICAL: Vi phạm layer này làm CI/CD `FAIL` ngay lập tức.

---

## 1. DB safety (HARD BLOCK)

| Rule ID | Quy tắc | Enforcement |
| :--- | :--- | :--- |
| DB-S-01 | Cấm `DROP TABLE`, `DROP DATABASE`, `TRUNCATE` trên production. | Pre-commit hook + CI |
| DB-S-02 | Cấm `DELETE FROM <table>` không có `WHERE` clause. | Static analysis |
| DB-S-03 | Cấm `UPDATE <table>` không có `WHERE` clause. | Static analysis |
| DB-S-04 | Cấm raw SQL string interpolation. | Code review gate |
| DB-S-05 | Phải có migration rollback plan trước khi chạy migration lên production. | Human review gate |
| DB-S-06 | Phải xác minh backup trước schema migration có breaking change. | Human review gate |

---

## 2. Git commit safety

| Rule ID | Quy tắc | Enforcement |
| :--- | :--- | :--- |
| GIT-S-01 | Cấm commit `.env`, `.env.*` trừ `.env.example`. | `.gitignore` + hook |
| GIT-S-02 | Cấm commit file chứa `sk-ant-`, `sk-proj-`, `-----BEGIN`. | Secret scan/hook đã được project chọn |
| GIT-S-03 | Cấm `git push --force` lên `main`, `master` hoặc `production`. | Branch protection |
| GIT-S-04 | Cấm commit trực tiếp lên `main`; phải qua PR + review. | Branch protection |
| GIT-S-05 | Commit message phải theo Conventional Commits. | Commit-msg hook |

---

## 3. Secret và credential safety

Không được output, ghi, log hoặc commit:

- API key (`sk-ant-*`, `sk-proj-*`, `AKIA*`, `ghp_*`).
- JWT secret, private key (`-----BEGIN RSA/EC PRIVATE KEY-----`).
- DB connection string chứa password.
- Password, PIN hoặc OTP dưới mọi hình thức.

Chỉ dùng secret scan tool/command đã được Architecture Profile hoặc CI chọn; không suy đoán `gitleaks`, `trufflehog` hoặc hook cụ thể tồn tại.

---

## 4. Agent execution safety

| Rule ID | Quy tắc |
| :--- | :--- |
| AGT-S-01 | Agent không được self-approve recommendation; chỉ Human Director có quyền. |
| AGT-S-02 | Agent phải dừng sau năm retry failure liên tiếp và escalate cho Human Director. |
| AGT-S-03 | Agent không được `git push`, `npm publish` hoặc deploy production tự động. |
| AGT-S-04 | Agent không được xóa file ngoài permitted path khi chưa có Human confirmation. |
| AGT-S-05 | Mọi DB schema change phải qua Human Final Review trước execution. |

---

## 5. Phòng tránh hủy dữ liệu

- Preview affected row count trước production delete operation.
- Cascade delete phải explicit; không dùng `ON DELETE CASCADE` cho business data mặc định.
- Migration script phải ghi backup path trong output log.
- Production DB cần recovery capability phù hợp RTO/RPO đã được Spec hoặc operations policy chấp thuận.

---

## 6. Phản hồi khi vi phạm

1. **STOP** — dừng execution ngay.
2. **REVERT** — rollback action vừa thực hiện nếu an toàn và có thể.
3. **ESCALATE** — báo Human Director kèm evidence.
4. **LOG** — ghi incident vào `.sdd/reviews/safety-incident-<timestamp>.md`.
