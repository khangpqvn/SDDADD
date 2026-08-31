# Starter Template SDD + ADD

Template này giúp khởi tạo dự án theo **Phát triển dựa trên đặc tả** (Spec-Driven Development — SDD) và **Phát triển do Agent hỗ trợ** (Agent-Driven Development — ADD). Mọi yêu cầu, quyết định của con người, bằng chứng thực thi và hợp đồng dùng chung đều nằm trong Git. Agent chỉ thực hiện trong phạm vi đã được duyệt.

## Bắt đầu từ đâu?

| Bạn đang cần làm gì? | Đọc tài liệu này | Kết quả nhận được |
| :--- | :--- | :--- |
| Lần đầu dùng template | [Bắt đầu nhanh](docs/sdd-add-quickstart.md) | Hoàn thành feature đầu tiên theo từng bước. |
| Hiểu đầy đủ quy trình, vai trò và cổng duyệt | [Hướng dẫn vận hành](docs/sdd-add-guide.md) | Biết khi nào tạo artifact, review hay dừng. |
| Đang làm việc và cần chọn lệnh | [Tra cứu nhanh](docs/sdd-add-field-guide.md) | Chọn đúng action theo tình huống. |
| Cần xử lý một trường hợp cụ thể | [Sổ tay tình huống](docs/sdd-add-scenario-playbook.md) | Làm theo quy trình greenfield, lỗi test, handoff hoặc delivery. |
| Chưa chọn stack hoặc lệnh kiểm tra | [Hướng dẫn Hồ sơ kiến trúc](docs/architecture-profile-guide.md) | Ghi binding có bằng chứng trước khi lập kế hoạch kỹ thuật. |
| Điều phối nhiều Agent hoặc làm việc một mình | [Hướng dẫn điều phối nhiều Agent](docs/multi-agent-orchestration-guide.md) | Chọn solo/team và giữ ownership không chồng lấn. |

> **Người mới:** Mở [Bắt đầu nhanh](docs/sdd-add-quickstart.md), chọn greenfield hoặc brownfield, rồi làm lần lượt. Không bỏ qua điểm dừng Human review.

## Vòng đời một feature

```text
CONTEXT → SPEC → PLAN → TASKS → execute → verify → sync
```

1. `CONTEXT.md` ghi ý định: việc cần đạt, lý do, Definition of Done, ranh giới, phần không làm và người quyết định.
2. `SPEC.md` ghi requirement EARS, tiêu chí chấp nhận, rủi ro và Feature Lock.
3. `PLAN.md` và `TASKS.md` liên kết `REQ-XXX` với kiến trúc, bằng chứng profile, thay đổi trạng thái và lệnh xác minh chính xác.
4. `/add-execute` thực hiện từng task. Team mode có thể dùng `/sdd-dispatch` để tạo Dispatch Record và điều phối worker Claude Code `Agent` trong ranh giới file độc quyền.
5. `/sdd-trace` kiểm tra tính nhất quán. `/sdd-sync` cập nhật registry và shared contract khi có trigger phù hợp.

## Thực hành đầu tiên

Làm theo [Bắt đầu nhanh](docs/sdd-add-quickstart.md) để tạo feature đầu tiên. Tài liệu này có đủ checkpoint theo đúng thứ tự: Context review → Spec lint/review/lock → profile review → Plan review → Tasks review → execution.

Nếu đưa template vào dự án sẵn có:

```bash
# Linux/macOS/Git Bash
./scripts/adopt.sh /path/to/existing-repository

# Windows PowerShell
.\scripts\adopt.ps1 -TargetPath C:\Projects\existing-repository
```

Mở repository đích rồi chạy `/sdd-adopt`. Chỉ dùng binding tìm thấy từ evidence; mâu thuẫn giữ `PENDING HUMAN REVIEW` để Human quyết định.

## Quy tắc không được bỏ qua

1. **Fix the Spec, not the Code.** Requirement thiếu hoặc mơ hồ: dùng `/sdd-update` và review lại trước khi đổi behavior.
2. **Không suy đoán kỹ thuật.** Baseline không tự chọn HTTP framework, database, ORM/query layer, validation library, package hoặc verification command.
3. **Không tự thực hiện action cần phê duyệt.** Human Final Review phải được lưu; Agent không tự approve, không `git push`, không deploy.

## Tài liệu và nguồn sự thật

- [Hướng dẫn vận hành](docs/sdd-add-guide.md): vai trò, artifact, gate và delivery.
- [Tra cứu nhanh](docs/sdd-add-field-guide.md): tình huống → action.
- [Sổ tay tình huống](docs/sdd-add-scenario-playbook.md): quy trình điều kiện và recovery.
- [Hướng dẫn Hồ sơ kiến trúc](docs/architecture-profile-guide.md): binding và exact verification command.
- [Hướng dẫn điều phối nhiều Agent](docs/multi-agent-orchestration-guide.md): ownership, dispatch và handoff.
- [`CONSTITUTION.md`](CONSTITUTION.md): hard rule về bảo mật, kiến trúc và chất lượng.
- [`AGENTS.md`](AGENTS.md): phạm vi, quyền và quy tắc làm việc của Agent.
- [`CLAUDE.md`](CLAUDE.md): bộ nhớ kiến trúc cho con người.
- [`.sdd/architecture-profile.md`](.sdd/architecture-profile.md): nguồn canonical cho tech binding và exact verification command.
- `.claude/skills/`: command contract chi tiết.

## Tiện ích template

| Tiện ích | Mục đích |
| :--- | :--- |
| `scripts/self-heal.sh` | Thu thập evidence cho `implementation-defect` đã được duyệt; không sửa source. |
| `scripts/template-smoke.sh` / `.ps1` | Kiểm tra file, link, policy token và distribution coverage. |
| `scripts/adopt.*` | Cài template vào brownfield mà không overwrite file đích nếu không explicit force. |
| `scripts/update.*` | Nhận template-owned update an toàn; governance file được stage, không tự overwrite. |

Xem chi tiết tại [Hướng dẫn vận hành](docs/sdd-add-guide.md) và command contract liên quan.
