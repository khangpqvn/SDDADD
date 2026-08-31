---
name: sdd-tasks
description: Pha 3 SDD — phân rã PLAN.md thành TASKS.md có ownership, dependency và verification command
user-invocable: true
---

# SDD Phase 3 — Task Decomposition (`/sdd-tasks`)

**Output language:** All output mirrors the language of the invoking prompt. Vietnamese prompt → Vietnamese output; English prompt → English output. Canonical tokens (`PENDING HUMAN REVIEW`, `PENDING`, `APPROVED`), `@ears` references, file paths, and CLI commands are language-invariant.

Dùng `PLAN.md` đã approved để tạo `.sdd/features/{feature-slug}/TASKS.md`.

## Tham số

- `--feature=<feature-slug>`: Feature identifier.

> **Sửa TASKS.md đã approved mà Plan không đổi?** Dùng `/sdd-update --artifact=tasks --reason="..."`. `/sdd-tasks` tạo Tasks từ đầu từ Plan đã approved — dùng khi Tasks chưa có hoặc Plan thay đổi yêu cầu phân rã lại.

## Shared methodology contract

Đọc [AI Review Protocol](../_shared/ai-review-protocol.md), Intent Packet, Methodology Profile, Feature Lock, Plan consistency map và shared-contract impact trước khi phân rã. Task chỉ thực hiện locked scope; deferred work phải giữ ngoài TASKS.md.

## Architecture Profile gate (BLOCKING)

- Tuân thủ [Architecture Profile Protocol](../_shared/architecture-profile-protocol.md).
- Đọc profile và `PLAN.md` đã approved trước khi sinh task.
- Chỉ ghi exact path, package, migration, config và command có profile evidence.
- `TASKS.md` bị block nếu thiếu test/build/lint command hoặc feature binding cần thiết. Không dùng `npm test` làm giá trị thay thế.
- Mỗi task phải nêu architecture layer, profile binding, `@ears` reference và exact verification command.

## Task record bắt buộc

Mỗi task dùng format sau, bổ sung additive cho format legacy:

```markdown
### T00X — <title>
- Intent reference: <Intent Packet WHAT/DoD và REQ-XXX>
- Input and expected outcome: <verifiable starting state and observable result>
- Layer and file boundary: <owned paths>
- Owner and dependencies: <owner; blockedBy or none>
- Profile binding and exact verification command: <approved evidence>
- Scope category: none | <material state-change category>
- Human checkpoint: required | N/A; <review route/evidence>
- Shared contract and sync-back: <contract responsibility; /sdd-trace and /sdd-sync decision>
- High-risk review route: <approved route or N/A>
```

`Scope category` dùng taxonomy từ protocol. Task material state change không được bắt đầu nếu Human checkpoint persisted thiếu. Task high-risk phải tham chiếu review route đã approved; normal Plan approval không thay thế route đó.

## Các bước

1. Phân rã task theo ba tiêu chí: Atomic, Independent và Verifiable.
2. Gắn requirement `@ears .sdd/features/{slug}/SPEC.md#REQ-XXX` cho business behavior.
3. Ghi Intent reference, verifiable input/outcome, owner, dependency, file boundary, profile binding, exact command, scope category, checkpoint và contract/sync-back responsibility cho từng task.
4. **Solo mode** (`--team-size=solo`): Developer xử lý toàn bộ ownership nhưng vẫn đọc và cập nhật shared contract khi task chạm contract dùng chung. **Team mode**: chỉ owner/Lead cập nhật `.sdd/shared_context.md`; contract chưa thuộc ownership phải block dispatch.
5. Ghi risk và tạo recommendation.

## DoD

- [ ] Task atomic, independent hoặc có `blockedBy`, và verifiable.
- [ ] Task có Intent reference, input/outcome, path, layer, owner, profile binding, requirement và exact command.
- [ ] Task có scope category, checkpoint disposition và high-risk review route khi applicable.
- [ ] Task nêu contract/sync-back responsibility cùng `/sdd-trace`/`/sdd-sync` decision.
- [ ] Không task nào vượt Feature Lock hoặc Out of Scope.
- [ ] Shared contract đã đồng bộ khi applicable.
- [ ] Human Final Review `APPROVED` trước `/add-execute`.

## AI Recommendation và Human Final Review

Sau khi tạo/sửa `TASKS.md`, lưu canonical recommendation gồm thứ tự task, dependency, file, verification command, state-change checkpoint, high-risk review route, shared contract/sync-back và delivery risk. Giữ `Human Final Review.Status: PENDING`; `/add-execute` không được bắt đầu đến khi Human Director ghi `APPROVED`. Agent không tự approve task plan.
