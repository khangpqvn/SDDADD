# Starter Template SDD + ADD

Template khởi tạo dự án theo **Spec-Driven Development (SDD)** và **Agent-Driven Development (ADD)**. Quy trình đảm bảo: Requirement rõ ràng $\rightarrow$ Human duyệt $\rightarrow$ Agent thực thi có evidence.

## 🚀 Bắt đầu ngay
Nếu bạn là người mới hoặc muốn triển khai feature đầu tiên, hãy đi theo lộ trình:
👉 **[Bắt đầu nhanh: Làm feature đầu tiên](docs/sdd-add-quickstart.md)**

## 📚 Hệ thống tài liệu (Điều hướng)
Thay vì đọc hết, hãy chọn tài liệu theo nhu cầu hiện tại của bạn:

| Bạn cần làm gì? | Đọc tài liệu này | Mục tiêu |
| :--- | :--- | :--- |
| **Đi từng bước làm feature** | [Quickstart](./docs/sdd-add-quickstart.md) | Hoàn thành 1 feature từ ý tưởng $\rightarrow$ Git delivery. |
| **Hiểu artifact, gate & ownership** | [Hướng dẫn vận hành](./docs/sdd-add-guide.md) | Hiểu tại sao phải có Spec/Plan và ai là người duyệt. |
| **Tra cứu command theo tình huống** | [Tra cứu nhanh](./docs/sdd-add-field-guide.md) | Tìm đúng lệnh `/sdd-...` cho tình huống cụ thể. |
| **Xử lý lỗi, handoff, resume** | [Sổ tay tình huống](./docs/sdd-add-scenario-playbook.md) | Recovery khi bị block hoặc chuyển giao session. |
| **Thiết lập tech stack & command** | [Hồ sơ kiến trúc](./docs/architecture-profile-guide.md) | Cách định nghĩa binding và lệnh verify trong Profile. |
| **Điều phối nhiều Agent (Worker)** | [Hướng dẫn Execution](./docs/multi-agent-orchestration-guide.md) | Hiểu route `direct` vs `orchestrated` của `/add-execute`. |

## 🛠️ Nguồn chuẩn (Canonical Sources)
Khi có mâu thuẫn, hãy tin vào các tệp này thay vì prose trong docs:
- `.sdd/architecture-profile.md`: Tech binding và exact verification command.
- `.claude/skills/`: Contract của các slash command.
- `CONSTITUTION.md` & `AGENTS.md`: Quy tắc vận hành và quyền hạn Agent.
- `.sdd/shared_context.md`: Cấu hình Ownership và Execution route.

## ⚠️ Ba nguyên tắc "sống còn"
1. **Fix the Spec, not the Code**: Thấy requirement thiếu/sai $\rightarrow$ update Spec $\rightarrow$ review $\rightarrow$ mới sửa code.
2. **Không suy đoán kỹ thuật**: Chỉ dùng binding và command đã được `APPROVED` trong Architecture Profile.
3. **Human quyết định**: Agent đề xuất và thực thi; chỉ Human mới được ghi `APPROVED` và `git push`.
