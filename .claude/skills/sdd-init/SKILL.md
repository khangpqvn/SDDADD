---
name: sdd-init
description: Khởi tạo template SDD + ADD, Architecture Profile, governance và cấu trúc dự án
user-invocable: true
---

# SDD Initializer (`/sdd-init`)

Dùng cho greenfield hoặc bootstrap SDD+ADD trong repository hiện có.

## Tham số

- `--project-name=<name>`: Tùy chọn.
- `--stack=<tech-stack>`: Tùy chọn; chỉ nêu binding biết explicit.
- `--team-size=solo|team`: Tùy chọn; `team` là mặc định.

## Baseline và Architecture Profile

1. Tạo `.sdd/architecture-profile.md` làm nguồn canonical cho artifact generation.
2. Chỉ parse `--stack` thành binding được nêu explicit. Không suy ra HTTP framework, ORM, validation hoặc command.
3. Không có `--stack`: seed TypeScript + Node.js + Clean Architecture core-only.
4. Ghi evidence, unresolved binding và canonical `PENDING HUMAN REVIEW` recommendation vào profile.
5. Context/Spec được phép business-neutral. Plan/Tasks/execute bị block đến khi relevant binding và exact command được approved.
6. Methodology Profile chỉ quy định depth/risk/review route; không thay Architecture Profile gate.

## Output

1. Tạo `.sdd/features/`, `.sdd/reviews/`, `.sdd/rfcs/`, `.claude/skills/`, `docs/`, `scripts/`, `src/{domain,usecase,interface,infra,shared}/` và `tests/` theo scope template.
2. Generate `AGENTS.md`, `CLAUDE.md`, `.agentignore` và `.gitignore` theo repository/stack evidence. Không copy manifest-specific rule hay command suy đoán.
3. Khởi tạo `.sdd/README.md`, Architecture Profile, shared context, MCP policy và constraints; ghi `# Collaboration Mode: solo|team` trong shared context theo `--team-size` (mặc định `team`).
4. Cài toàn bộ current template-owned documentation:
   - `docs/sdd-add-quickstart.md`
   - `docs/sdd-add-guide.md`
   - `docs/sdd-add-field-guide.md`
   - `docs/sdd-add-scenario-playbook.md`
   - `docs/architecture-profile-guide.md`
   - `docs/multi-agent-orchestration-guide.md`
5. Cài support scripts `self-heal.sh`, `template-smoke.sh`, `template-smoke.ps1`, `start-claude.sh`, `start-claude.ps1`, `update.sh` và `update.ps1`.
6. Tạo `.sdd/reviews/init.md` với canonical recommendation; Human reviews bootstrap scope before feature work.

## Generated governance requirements

- `AGENTS.md` has eight canonical sections: Identity, Scope, Tool Permissions, Security Rules, Communication Style, Error Handling, Escalation Protocol and Changelog.
- `CLAUDE.md` mirrors approved architecture, actual layout and durable project guidance; it does not choose stack.
- `.agentignore` and `.gitignore` use observed stack/build patterns and protect secret files.
- `CONSTITUTION.md` Layer 1/2 is never changed without approved RFC. If exact verification command is unknown, preserve a review blocker rather than invent one.

## Solo mode

Team mode cài `/sdd-dispatch` để coordinate Claude Code `Agent` worker theo persisted evidence. Skill không cài settings, identity provider hoặc host enforcement giả định; `.sdd/mcp-config.yaml` vẫn policy-only. Solo mode uses one `@developer` role and no multi-agent dispatch table; `/sdd-dispatch --team-size=solo` chỉ dùng solo-bypass. It retains Intent Packet, Methodology Profile, Feature Lock, Shadow Plan, Action Record, Architecture Profile and material-state checkpoint rules.

Solo delivery removes PR overhead only. Agent does not `git push`; Human self-pushes after validation/commit.

## AI Recommendation and Human Final Review

Use `.claude/skills/_shared/ai-review-protocol.md`. Recommendation includes bootstrap scope, profile evidence/unknowns, selected Methodology Profile defaults, missing decisions and next command. Human Final Review remains `PENDING` until a human records a durable decision. `/sdd-review` does not replace `/sdd-rfc --approve=<rfc-number>` for Constitution changes.
