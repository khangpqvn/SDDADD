# SDD + ADD Template Version

template-version: 1.3.0
adopted-at:
last-updated:
template-source:

---

## Hướng dẫn

File này được `scripts/adopt.sh` / `adopt.ps1` tạo khi áp dụng template lần đầu và được `scripts/update.sh` / `update.ps1` cập nhật sau mỗi lần update.

- `template-version`: version template tại thời điểm adopt / update gần nhất.
- `adopted-at`: timestamp lần adopt đầu tiên (ISO-8601).
- `last-updated`: timestamp lần update gần nhất (ISO-8601).
- `template-source`: URL hoặc path của template gốc (tuỳ chọn, để trace nguồn).

Không sửa file này thủ công. Dùng `/sdd-template-update` để kiểm tra và cập nhật template.
