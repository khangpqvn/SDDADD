# Hướng dẫn vận hành SDD + ADD

Tài liệu này giải thích **ai quyết định**, **mỗi artifact dùng để làm gì**, và **khi nào được đi tiếp**. Nếu cần làm feature theo từng bước, đọc [Bắt đầu nhanh](./sdd-add-quickstart.md).

## 1. Bốn khái niệm cần nhớ

| Khái niệm | Hiểu đơn giản |
| :--- | :--- |
| **Artifact** | File có cấu trúc lưu Context, Spec, Plan, Tasks hoặc evidence. |
| **Gate** | Điều kiện bắt buộc trước khi sang bước tiếp theo. Chưa đạt thì dừng. |
| **Human Final Review** | Quyết định `APPROVED`, `REVISE` hoặc `REJECTED` do Human ghi bền vững bằng `/sdd-review`. Chat không thay thế review này. |
| **Checkpoint** | Approval bền vững trước material state change như đổi public contract, schema, permission, security config hoặc external action. |

Các tên field, status và format chính thức nằm trong `.claude/skills/_shared/ai-review-protocol.md` và từng `SKILL.md`.

## 2. Ai làm gì?

| Vai trò | Trách nhiệm |
| :--- | :--- |
| **Human reviewer** | Quyết định business, risk, scope và ghi approval. Với `solo`, project owner duy nhất review; với `team`, Human collaborator được ủy quyền review. |
| **Agent** | Phân tích, đề xuất, thực thi trong scope đã duyệt và ghi evidence. Agent không self-approve, không `git push`, không deploy. |
| **Tech Lead/contract owner** | Quyết định binding kiến trúc và xử lý shared contract khi repository giao quyền đó. |

`Project Ownership` và `Agent Execution` là hai trục độc lập trong `.sdd/shared_context.md`:

- `Project Ownership: solo|team` quyết định quyền review và policy delivery.
- `Agent Execution: direct|orchestrated` quyết định `/add-execute` chạy trong session hiện tại hay dùng worker.

`orchestrated` chỉ được dùng khi runtime Claude Code `Agent` capability đã được quan sát. Runtime không khả dụng là `BLOCKED`, không tự fallback sang `direct`.

## 3. Hai pipeline chạy song song

SDD trả lời *làm đúng việc gì*. ADD trả lời *thực thi thế nào cho kiểm chứng được*. Một feature đi qua cả hai.

### SDD pipeline

| Pha | Mục tiêu | Đầu vào | Đầu ra | Gate |
| :--- | :--- | :--- | :--- | :--- |
| Context | Chốt vấn đề, người dùng, boundary, non-goal | Ý tưởng, evidence repository | `CONTEXT.md` | Human `APPROVED` |
| Spec | Chốt hành vi hệ thống bằng EARS và acceptance criteria | `CONTEXT.md` đã duyệt | `SPEC.md` | Human `APPROVED` và Feature Lock |
| Plan | Chốt boundary kỹ thuật, binding và exact command | `SPEC.md` đã lock, Architecture Profile | `PLAN.md` | Human `APPROVED`, Profile gate |
| Tasks | Chia việc thành đơn vị kiểm chứng được | `PLAN.md` đã duyệt | `TASKS.md` | Human `APPROVED` trước execution |
| Validation | Chứng minh hành vi khớp Spec | Code, exact approved command | Action Record, evidence | Post-code review khi trigger áp dụng |

Mỗi requirement phải truy vết được: `REQ-XXX` trong `SPEC.md` → task trong `TASKS.md` → `@ears` annotation trong code → test/evidence. Mất một mắt là spec debt.

### ADD pipeline

| Pha | Mục tiêu | Việc Human phải làm | Dấu hiệu sai |
| :--- | :--- | :--- | :--- |
| Context Setup | Agent có đủ và đúng thông tin | Trỏ artifact, constraint, `.agentignore` | Agent hỏi lại điều đã có trong Spec |
| Intent Communication | Agent hiểu WHAT và Definition of Done | Nêu WHAT + DoD, không đọc HOW từng dòng | Agent làm đúng lệnh nhưng sai mục tiêu |
| Agentic Execution | Thực thi có Shadow Plan và evidence | Duyệt trước material state change | Không có Action Record hoặc command không khớp Profile |
| Human Review | Chốt chất lượng và rủi ro | Ghi `APPROVED`/`REVISE`/`REJECTED` bền vững | Duyệt bằng chat, hoặc duyệt mà không đọc diff |

Hai pipeline không tuần tự tuyệt đối. Context/Spec có thể core-only; nhưng Plan, Tasks, `/add-execute` và `/sdd-layer-edit` dừng khi thiếu binding hoặc exact command.

## 4. Artifact và gate

| Artifact | Câu hỏi cần trả lời | Gate tiếp theo |
| :--- | :--- | :--- |
| `CONTEXT.md` | Làm gì, vì sao, cho ai, boundary nào? | Human `APPROVED` |
| `SPEC.md` | Hệ thống phải làm gì, không làm gì, và kiểm tra ra sao? | Human `APPROVED` và Feature Lock |
| `PLAN.md` | Sẽ thay đổi boundary nào, dùng binding/command nào, rủi ro gì? | Human `APPROVED` |
| `TASKS.md` | Ai làm từng phần, file nào được sửa, dependency và command nào? | Human `APPROVED` trước `/add-execute` |
| `Execution Record` | Attempt nào được chạy, route nào, grant/evidence nào? | Revalidate trước retry/resume |
| `Action Record` | Đã đổi gì, chạy command nào, kết quả và blocker còn lại? | Evidence đủ trước completion |
| Post-code review | Thay đổi có an toàn để delivery không? | Human `APPROVED` khi trigger áp dụng |

`REVISE`, `REJECTED`, review cũ, missing exact command, contract drift hoặc missing checkpoint đều chặn phần việc bị ảnh hưởng.

## 5. Cách xử lý requirement

Requirement thiếu hoặc mơ hồ phải đi theo quy tắc **Fix the Spec, not the Code**:

1. Ghi gap hoặc edge case trong Context/Spec.
2. Human xác nhận rule hoặc approved assumption.
3. Dùng `/sdd-update` nếu artifact đã tồn tại hoặc đã lock.
4. Review và lock lại artifact.
5. Chỉ sau đó mới resume execution.

`Methodology Profile` (`SKIP`, `SKETCH`, `DETAILED`, `FORMAL`) chỉ quyết định độ sâu phân tích. Nó không chọn framework, database hoặc verification command thay Architecture Profile.

## 6. Architecture Profile

`.sdd/architecture-profile.md` là nguồn chuẩn cho technology binding và exact verification command. Trước `PLAN`, `TASKS` hoặc execution:

1. Kiểm tra binding liên quan feature có `APPROVED`.
2. Kiểm tra evidence trỏ đến manifest, config, source hoặc decision bền vững.
3. Kiểm tra exact command tồn tại và khớp evidence.
4. Nếu thiếu hoặc mâu thuẫn, dừng và yêu cầu Human review.

Không thay command bị thiếu bằng `npm test`, `npm run build` hoặc lệnh quen thuộc khác. Xem [Hướng dẫn Hồ sơ kiến trúc](./architecture-profile-guide.md).

## 7. Execution và evidence

`/add-execute` là public entry point duy nhất sau khi `TASKS.md` đã `APPROVED`:

```text
/add-execute --feature=<slug> --task=<T001>
/add-execute --feature=<slug> --all
```

Command tự resolve route từ `.sdd/shared_context.md`, preflight, tạo Execution Record/grant nội bộ, consume grant trước action, thực thi và ghi Action Record. Không truyền grant, consumer, ownership, execution route hoặc dispatch flag thủ công.

`--retry` chỉ dành cho named task ở `RETRY_PENDING` do implementation defect, khi immutable inputs không đổi. `--resume` dành cho task bị interruption hoặc blocker đã được resolve, sau revalidation. Không reuse grant đã consumed.

## 8. Review sau code và delivery

Post-code review áp dụng khi thay đổi source behavior, test, API/shared contract, runtime/dependency/security config, schema hoặc business state. Docs-only change không tự động cần post-code review.

Trước commit:

```text
/git-validate --scope=commit --feature=<slug>
```

Chỉ khi có `GIT VALIDATION: READY` và Human yêu cầu mới dùng `/git-commit`. Agent không `git push`. Với `team`, dùng PR flow; với `solo`, Human có thể delivery trực tiếp theo policy repository.

## 9. Viết Spec: 8 thành phần và EARS

Một `SPEC.md` đủ dùng trả lời hết tám câu hỏi sau. Thiếu thành phần nào thì Agent sẽ tự suy đoán phần đó.

| # | Thành phần | Câu hỏi nó trả lời |
| :--- | :--- | :--- |
| 1 | Context & Goal | Vấn đề gì, vì sao làm bây giờ, thành công đo bằng gì? |
| 2 | Actors & Roles | Ai gọi, ai bị ảnh hưởng, quyền của từng vai trò? |
| 3 | Functional Requirements | Hệ thống phải làm gì, viết bằng EARS, mỗi mục có `REQ-XXX`. |
| 4 | Non-Functional Requirements | Ngưỡng hiệu năng, bảo mật, khả dụng, tuân thủ nào là bắt buộc? |
| 5 | Data Model | Entity, field, ràng buộc, trạng thái và quan hệ nào? |
| 6 | Error Handling | Lỗi nào xảy ra, hệ thống phản ứng thế nào, người dùng thấy gì? |
| 7 | Acceptance Criteria | Kiểm tra bằng cách nào để biết requirement đã đạt? |
| 8 | Out of Scope | Điều gì cố ý không làm trong lần này? |

### Năm mẫu EARS

| Mẫu | Cú pháp | Ví dụ |
| :--- | :--- | :--- |
| Ubiquitous | `THE <system> SHALL <action>` | `THE system SHALL lưu password dưới dạng hash.` |
| Event-driven | `WHEN <event>, THE <system> SHALL <action>` | `WHEN người dùng submit form đăng ký, THE system SHALL gửi email xác thực.` |
| State-driven | `WHILE <state>, THE <system> SHALL <action>` | `WHILE tài khoản chưa xác thực, THE system SHALL từ chối đăng nhập.` |
| Optional | `WHERE <feature> IS ENABLED, THE <system> SHALL <action>` | `WHERE 2FA IS ENABLED, THE system SHALL yêu cầu mã OTP.` |
| Unwanted | `WHERE <condition>, THE <system> SHALL <response>` | `WHERE email đã tồn tại, THE system SHALL trả lỗi 409 và không tạo user.` |

`SHALL` bắt buộc và phải kiểm chứng được. `SHOULD` là khuyến nghị, lệch được nhưng phải ghi lý do. `MAY` là tùy chọn, không tạo nghĩa vụ. Không dùng `SHALL` cho điều không có cách kiểm tra.

### Năm anti-pattern thường gặp

| Anti-pattern | Vì sao hỏng | Sửa thế nào |
| :--- | :--- | :--- |
| Mơ hồ định lượng: "nhanh", "thân thiện", "an toàn" | Không kiểm chứng được | Nêu ngưỡng và cách đo trong NFR |
| Spec mô tả HOW: chọn sẵn class, file, thư viện | Khóa giải pháp trước khi hiểu vấn đề | Giữ WHAT trong Spec, đẩy HOW xuống `PLAN.md` |
| Gộp nhiều hành vi vào một requirement | Không truy vết và không test riêng được | Tách thành nhiều `REQ-XXX` |
| Bỏ trống error và edge case | Agent tự bịa hành vi lỗi | Viết mẫu Unwanted cho từng nhánh lỗi |
| Không có Out of Scope | Scope phình khi thực thi | Liệt kê rõ điều không làm |

### Chọn độ sâu Spec

Độ sâu là quyết định kinh tế: viết ít hơn mức cần thì trả giá khi sai, viết nhiều hơn mức cần thì trả giá bằng thời gian.

| | Phức tạp thấp | Phức tạp cao |
| :--- | :--- | :--- |
| **Rủi ro thấp** | Sketch: mục tiêu, vài requirement chính, acceptance criteria | Detailed: đủ 8 thành phần, EARS cho nhánh chính và lỗi |
| **Rủi ro cao** | Detailed: nhấn NFR, error handling và data constraint | Formal: đủ 8 thành phần, traceability đầy đủ, pre-mortem và checkpoint dày |

Rủi ro cao nghĩa là sai thì mất dữ liệu, mất tiền, rò rỉ thông tin, hoặc phá public contract. `Methodology Profile` trong review protocol dùng cùng thang này: `SKIP`, `SKETCH`, `DETAILED`, `FORMAL`.

## 10. Context Engineering: cho Agent đúng thứ nó cần

Agent chỉ giỏi trong phạm vi context nó nhận được. Context nhiều không đồng nghĩa context tốt.

| Nguyên tắc | Nội dung | Trong template này |
| :--- | :--- | :--- |
| Selection | Chỉ đưa artifact liên quan task đang làm | Trỏ `CONTEXT.md`, `SPEC.md#REQ-XXX`, file trong task boundary |
| Structure | Context có cấu trúc dễ đọc hơn prose dài | Artifact Markdown có heading và ID ổn định |
| Clean | Loại nhiễu: file build, secret, dữ liệu sinh ra | `.agentignore` |
| Layer | Tách constraint toàn cục khỏi chi tiết feature | `CONSTITUTION.md`, `.sdd/constraints/`, rồi mới tới feature artifact |

Thực hành kèm theo:

- Mở session mới cho mỗi task lớn. Session dài mang theo quyết định cũ đã bị thay thế.
- Khi phải tiếp tục session dài, tóm tắt trạng thái hiện tại rồi trỏ lại artifact thay vì dựa vào ký ức hội thoại.
- Giữ tải nhận thức của một task ở mức đọc hiểu được trong một lần: một boundary, một tập file, một exact command để verify.
- Khi Agent bắt đầu hỏi lại điều đã có trong Spec, hoặc bỏ qua chỉ dẫn đã nêu, đó là dấu hiệu context đã quá tải; dừng và mở session mới.

## 11. Spec-as-Code: quản lý đặc tả như quản lý code

### Ba lớp ràng buộc

| Lớp | Nội dung | Ai đổi được |
| :--- | :--- | :--- |
| Hard Rules | Điều không bao giờ được vi phạm: không self-approve, không `git push`, không truy cập DB từ interface | Chỉ Human, qua review có chủ ý |
| Architectural Constraints | Boundary layer, hướng phụ thuộc, binding đã duyệt | Human, kèm evidence trong Architecture Profile |
| Engineering Standards | Convention đặt tên, format, mức test | Human, ảnh hưởng thấp hơn |

Ràng buộc hẹp hơn không được nới ràng buộc rộng hơn. Feature Spec không ghi đè `CONSTITUTION.md` hay `.sdd/constraints/`.

### Clarification-First

Khi requirement còn mơ hồ, hỏi trước khi viết, không đoán rồi viết. Cần Clarification-First khi: có nhiều cách hiểu hợp lý, thiếu business rule cho edge case, hoặc ngưỡng NFR chưa có số. Câu trả lời của Human được ghi vào artifact như approved assumption, không để trong chat.

### Drift và sync-back

Spec-code drift là khi code và Spec nói hai điều khác nhau. Có hai trường hợp:

- Code sai so với Spec: sửa code.
- Spec sai so với thực tế đã được Human chấp nhận: dùng `/sdd-update` để sync-back, review lại, rồi lock. Đây vẫn là *Fix the Spec, not the Code* — Spec được sửa có chủ ý, không bị bỏ mặc cho lệch.

Drift không được phát hiện sẽ tích lại thành spec debt: requirement không còn ai tin, `@ears` annotation trỏ tới mục đã đổi nghĩa, test xanh nhưng không chứng minh điều gì.

## 12. Giao việc cho Agent

Nêu WHAT và Definition of Done, để Agent đề xuất HOW trong boundary đã duyệt. Đọc HOW từng dòng cho Agent là mất lợi thế của ADD mà vẫn giữ rủi ro.

| Loại việc | Nêu rõ điều gì |
| :--- | :--- |
| Feature | `REQ-XXX` liên quan, layer được sửa, acceptance criteria, exact command để verify |
| Bug | Hành vi hiện tại, hành vi mong đợi, cách tái hiện; yêu cầu chứng minh nguyên nhân trước khi sửa |
| Refactor | Hành vi phải giữ nguyên, boundary được phép đổi, test nào chứng minh không hồi quy |
| Test | Requirement cần phủ, nhánh lỗi cần phủ, mức đủ là gì |

Chu trình thực thi là Plan-Act-Check: Agent trình Shadow Plan trước khi sửa, thực thi trong boundary, rồi chạy exact approved command và ghi kết quả vào Action Record. Human gate nằm ở hai chỗ: trước material state change và tại Human Final Review.

## 13. Giới hạn thật của Agent

Agent hoạt động theo vòng Perception → Reasoning → Action. Điểm yếu nằm ở cả ba.

| Giới hạn | Biểu hiện | Cách template xử lý |
| :--- | :--- | :--- |
| Thiếu environmental feedback | Agent tin code chạy được vì đọc thấy hợp lý | Bắt buộc chạy exact approved command và ghi kết quả thật |
| Token burn | Chi phí tăng nhanh khi Agent lục lọi cả repo | Task boundary hẹp, `.agentignore`, trỏ file cụ thể |
| Loop trapping | Sửa đi sửa lại cùng một lỗi mà không hội tụ | Giới hạn attempt; `self-heal` chỉ thu evidence một lần, không retry |
| Context cliff | Context đầy thì bỏ quên chỉ dẫn đã nhận | Session mới cho mỗi task lớn, artifact thay vì ký ức hội thoại |
| API hallucination | Bịa hàm/tham số của library ít phổ biến | Chỉ dùng binding đã `APPROVED`, verify bằng build/test thật |

Mức tự chủ tăng thì checkpoint phải dày hơn, không thưa hơn. Việc đọc hiểu và đề xuất cần ít gate; việc sửa nhiều file cần Shadow Plan và review; việc đổi schema, permission, security config hoặc gọi ra ngoài cần checkpoint bền vững trước khi hành động.

## 14. Khi bị block

| Blocker | Hành động đúng |
| :--- | :--- |
| Context/Describe-back sai | Sửa Context, disposition question, review lại. |
| Spec thiếu rule | `/sdd-update` rồi review/lock lại; không vá code trước. |
| Thiếu binding/command | Bổ sung evidence và review Architecture Profile. |
| Contract hoặc boundary drift | Dừng, để owner/Lead resolve, rồi trace/sync và revalidate. |
| Test/validation fail | Giữ exact command/result, phân loại nguyên nhân, sửa trong scope hoặc quay lại Spec/Profile. |
| Thiếu checkpoint/review | Persist approval trước khi tiếp tục. |
| Runtime orchestrated unavailable | Giữ `BLOCKED`; resolve runtime evidence, không fallback direct. |

## Đọc tiếp

- [Bắt đầu nhanh](./sdd-add-quickstart.md)
- [Tra cứu nhanh](./sdd-add-field-guide.md)
- [Sổ tay tình huống](./sdd-add-scenario-playbook.md)
- [Hướng dẫn điều phối nhiều Agent](./multi-agent-orchestration-guide.md)
