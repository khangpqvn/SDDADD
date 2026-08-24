---
name: sdd-audit
description: Kiểm định Constitution, Clean Architecture, EARS trace và binding theo Architecture Profile
user-invocable: true
---

# SDD Audit (`/sdd-audit`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`FAIL`, `WARNING`, `PASS`, `CONFIGURATION GAP`, `PENDING HUMAN REVIEW`, `APPROVED`), rule codes (`SEC-01`, `DATA-01`, `ARCH-01`, `ENG-01`), file paths, and CLI commands are language-invariant.

Dùng để kiểm định source và artifact theo `CONSTITUTION.md` trước commit hoặc Pull Request.

## Tham số

- `--feature=<feature-slug>`: Tùy chọn; giới hạn một feature. Không có thì audit toàn repository.

## Architecture Profile

Tuân thủ [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md).

- Audit governance/layer boundary được phép với core-only baseline.
- Route, authentication middleware, ORM/SQL, queue, dependency scan và test command chỉ kiểm tra khi binding tương ứng đã approved/evidenced.
- Binding chưa chọn phải báo `CONFIGURATION GAP`, không kết luận `PASS`/`FAIL` dựa trên framework, SQL dialect, ORM method hay command suy đoán.

## Ba tầng audit

1. **Hard rule:** `SEC-01` secret/PII protection; `SEC-02` identity, authorization ownership và unauthorized behavior cho feature cần access control; `DATA-01` retention, recovery, authorization, audit và deletion policy khi feature đổi core business data.
2. **Architecture:** `ARCH-01` dependency direction và cấm direct DB access từ interface; `ARCH-02` kiểm tra async/reliability behavior theo Spec/profile.
3. **Engineering:** `ENG-01` EARS trace trong `src/usecase/`; `ENG-02` safe error contract theo transport đã approved; `ENG-03` exact approved verification command.

## Kết quả

- `FAIL`: Layer 1 violation hoặc blocker phải sửa.
- `WARNING`: Vấn đề Layer 2/3 cần remediation hoặc rationale approved.
- `PASS`: Check đã chạy và đạt.
- `CONFIGURATION GAP`: Chưa đủ binding/evidence để audit adapter-specific.

## AI Recommendation và Human Final Review

Sau audit, tạo canonical recommendation gồm finding, severity, evidence, remediation option và residual risk. Lưu trong feature artifact hoặc `.sdd/reviews/audit-<slug>.md` với `PENDING HUMAN REVIEW`. Human Director/Tech Lead quyết định disposition; Layer 1 failure và blocker còn mở vẫn block. Agent không tự approve audit.
