# SDD + ADD Quickstart — Hướng dẫn bắt đầu
# Version: 1.0.0

Đây là điểm vào duy nhất bạn cần đọc trước khi làm bất cứ điều gì với template này.

---

## Tại sao cần SDD + ADD?

Khi làm việc với AI Agent, vấn đề phổ biến nhất không phải Agent viết code sai — mà là:

- Agent không biết dự án của bạn là gì, muốn gì, và giới hạn ở đâu.
- Agent tự quyết định business behavior mà không hỏi.
- Khi xảy ra lỗi, không ai biết đó là lỗi code hay lỗi yêu cầu.
- Không có bằng chứng nào để review, không thể trace lại quyết định.

**SDD** (Spec-Driven Development) giải quyết phần "viết yêu cầu rõ ràng".  
**ADD** (Agent-Driven Development) giải quyết phần "cho Agent thực thi có kiểm soát".

---

## Mental model trong 1 phút

```text
CON NGƯỜI định nghĩa:           AGENT thực thi:
  WHAT (cần gì)            →      HOW (làm thế nào)
  WHY (vì sao)             →      Plan → Code → Test → Fix
  Constraints (giới hạn)   →      (trong phạm vi đã duyệt)
  Approval (phê duyệt)     →      Báo cáo + bằng chứng
```

- **Human Director** = người quyết định mọi thứ liên quan business, risk và phê duyệt.
- **Agent** = executor thông minh, nhưng không được tự approve recommendation của chính mình.

Tỉ lệ thực tế: **Human ≈ 20%** (setup + review); **Agent ≈ 80%** (thực thi).

---

## Bốn artifact cốt lõi

Mỗi feature có 4 artifact, được tạo tuần tự:

| Artifact | Trả lời câu hỏi | Pha |
| :--- | :--- | :--- |
| `CONTEXT.md` | Vì sao làm? Ai bị ảnh hưởng? Ràng buộc nào? | 0 |
| `SPEC.md` | Hệ thống phải làm gì, kể cả lỗi và edge case? | 1 |
| `PLAN.md` | Xây dựng theo ranh giới kiến trúc nào? Rủi ro ra sao? | 2 |
| `TASKS.md` | Ai hoặc Agent làm bước nào, kiểm chứng bằng gì? | 3 |

**Nguyên tắc vàng:** Không nhảy pha. `CONTEXT.md` → `SPEC.md` → `PLAN.md` → `TASKS.md` → Execute.

---

## Hai điều dừng thực thi

Trước khi Agent thực thi bất kỳ code nào, hai điều này phải đúng:

1. **`SPEC.md` ở trạng thái `APPROVED & LOCKED`** — Human Director đã review và chốt yêu cầu.
2. **Architecture Profile có đủ binding** — đã chọn rõ HTTP framework, database, ORM, test command.

Thiếu một trong hai → Agent dừng và báo, không tự đoán.

---

## Quy trình feature chuẩn — nhìn từ trên xuống

```text
1. /sdd-context  → Tạo CONTEXT.md
   Human review → APPROVED

2. /sdd-spec     → Tạo SPEC.md
   Human review → APPROVED & LOCKED

3. /sdd-plan     → Tạo PLAN.md (cần Architecture Profile đủ binding)
   Human review → APPROVED

4. /sdd-tasks    → Tạo TASKS.md
   Human review → APPROVED

5. /add-execute  → Agent thực thi từng task
   Mỗi task: Shadow Plan → Human confirm → Execute

6. /sdd-lint, /sdd-audit, /sdd-trace, /sdd-sync → Kiểm định

7. /git-validate → READY → /git-commit → /git-pr
```

---

## Ba trạng thái bạn cần nhớ

| Trạng thái | Ý nghĩa thực tế |
| :--- | :--- |
| `PENDING` | Chưa có quyết định của người có thẩm quyền. Agent phải dừng. |
| `APPROVED` | Được tiếp tục trong đúng phạm vi đã ghi. |
| `REVISE` / `REJECTED` | Phải sửa và tạo recommendation mới. Agent không được tự tiếp tục. |

`APPROVED` phải có: decision cụ thể + reviewer identity + timestamp ISO-8601.  
Nói miệng "ok" hoặc tin nhắn chat không phải approval hợp lệ.

---

## Bắt đầu: làm theo kịch bản của bạn

### Tôi bắt đầu dự án mới

```bash
# Chưa biết stack → chỉ khởi tạo baseline
/sdd-init --project-name="my-project"

# Đã biết một phần stack
/sdd-init --project-name="my-project" --stack="Node.js + TypeScript + PostgreSQL"

# Team chỉ có 1 người → solo mode (developer = Human Director = Agent)
/sdd-init --project-name="my-project" --team-size=solo
```

Sau đó mở `.sdd/architecture-profile.md`, điền các binding còn thiếu và review.  
Tiếp: `/sdd-context --feature=<slug>` cho feature đầu tiên.

---

### Tôi đã có repository sẵn

```bash
# Linux / macOS / Git Bash
./scripts/adopt.sh /path/to/my-existing-repo

# Windows PowerShell
.\scripts\adopt.ps1 -TargetPath C:\Projects\my-existing-repo
```

Mở repo đích, chạy `/sdd-adopt`.
Agent sẽ đọc manifest, CI, test config và source layout để điền Architecture Profile.
Bạn review và approve trước khi làm feature work.

> **Solo mode?** Thêm `--team-size=solo` khi chạy `/sdd-init` hoặc `/sdd-adopt`. Agent sẽ generate governance file tối giản cho 1 developer.

---

### Tôi muốn làm ngay một feature (profile đã sẵn sàng)

```text
/sdd-context --feature=feat-user-register
```

Làm theo quy trình 7 bước ở trên.

---

## Năm điều không được làm

1. **Không chạy `/sdd-plan`, `/sdd-tasks`, `/add-execute` khi Architecture Profile còn thiếu binding** — Agent sẽ đoán sai stack.
2. **Không approve bằng cách nói "ok" trong chat** — phải dùng `/sdd-review` với đủ fields.
3. **Không để Agent tự approve recommendation của mình** — đây là ranh giới cứng.
4. **Không vá code khi test fail vì thiếu Spec** — phải cập nhật Spec trước.
5. **Không thêm framework, package, ORM ngoài profile đã duyệt** — kể cả Agent kể cả bạn.

---

## Phê duyệt đúng cách — `/sdd-review`

Đây là lệnh quan trọng nhất. Dùng nó thay vì sửa file thủ công:

```text
/sdd-review \
  --feature=feat-user-register \
  --artifact=context \
  --status=APPROVED \
  --decision="Đã duyệt problem, stakeholders, glossary và constraints; đủ cơ sở lập SPEC." \
  --reviewer="Nguyen Van A, Product Owner" \
  --reviewed-at="2026-08-25T09:00:00+07:00" \   # Tùy chọn, mặc định lấy thời gian hiện tại
  --follow-up="/sdd-spec --feature=feat-user-register"
```

Thay `--artifact=context` bằng `spec`, `plan`, `tasks`, `execution` tùy pha.  
Thay `--status=APPROVED` bằng `REVISE` hoặc `REJECTED` nếu cần sửa.

## Cập nhật artifact đã approved — `/sdd-update`

Khi artifact đã approved cần sửa, dùng `/sdd-update` thay vì chạy lại skill tạo:

```text
# Sửa Spec đã lock
/sdd-update --feature=feat-user-register --artifact=spec --bump=patch \
  --reason="[REQ-003] Add OTP rate-limit: max 5 attempts per 10 minutes"

# Cập nhật Context
/sdd-update --feature=feat-user-register --artifact=context \
  --reason="Add GDPR constraint: user data deletable within 30 days"

# Sửa Plan (Spec không đổi)
/sdd-update --feature=feat-user-register --artifact=plan \
  --reason="Add Redis session token risk mitigation"

# Thêm Task (Plan không đổi)
/sdd-update --feature=feat-user-register --artifact=tasks \
  --reason="Add T009 for concurrent registration dedup check"
```

Mỗi update invalidate review cũ, tạo recommendation mới cần Human Director approve.

---

## Khi gặp lỗi, hỏi hai câu này trước

**Câu 1:** Test fail vì code sai Spec hay vì Spec thiếu rule?
- Code sai Spec → sửa code.
- Spec thiếu rule → `/sdd-update --artifact=spec --bump=patch --reason="[REQ-XXX] ..."` trước.

**Câu 2:** Agent bị block vì thiếu gì?
- Thiếu binding → mở `.sdd/architecture-profile.md`, điền decision, `/sdd-review` approve.
- Thiếu approval → `/sdd-review` với đúng reviewer.
- Thiếu exact test command → chọn và ghi vào Architecture Profile.

---

## Bảng điều hướng — đọc gì tiếp theo

| Tôi muốn... | Đọc tài liệu này |
| :--- | :--- |
| Hiểu đầy đủ mọi command và quy tắc | [sdd-add-guide.md](./sdd-add-guide.md) |
| Làm theo kịch bản cụ thể (greenfield, brownfield, solo, multi-agent...) | [sdd-add-scenario-playbook.md](./sdd-add-scenario-playbook.md) |
| Tra nhanh command → kịch bản | [sdd-add-field-guide.md](./sdd-add-field-guide.md) |
| Hiểu cách chọn và approve tech stack | [architecture-profile-guide.md](./architecture-profile-guide.md) |
| Solo workflow (1 developer) hoặc multi-agent orchestration | [multi-agent-orchestration-guide.md](./multi-agent-orchestration-guide.md) |
| Quy tắc bất biến và security gate | [`CONSTITUTION.md`](../CONSTITUTION.md) |
| Quyền hạn và phạm vi Agent | [`AGENTS.md`](../AGENTS.md) |

---

## Checklist để bắt đầu một phiên làm việc

- [ ] Đọc `CONSTITUTION.md`, `AGENTS.md`, `.sdd/constraints/` nếu chưa quen.
- [ ] Mở `.sdd/architecture-profile.md` — xác nhận binding cần cho feature này đã `APPROVED`.
- [ ] Chạy `./scripts/start-claude.ps1` (Windows) hoặc `./scripts/start-claude.sh` (Linux/macOS) để mở Claude với đúng quyền.
- [ ] Nếu tiếp tục phiên cũ: `start-claude.ps1 -Continue` rồi `/sdd-resume --feature=<slug>`.
- [ ] Nếu feature mới: `/sdd-context --feature=<slug>`.
