---
name: sdd-agents-edit
description: Quản lý và cập nhật AGENTS.md: Agent Constitution, vai trò, phạm vi và ma trận quyền công cụ
user-invocable: true
---

# SDD Agent Constitution Editor (`/sdd-agents-edit`)

**Output language:** Mirror the invoking prompt. Canonical tokens, paths and commands remain language-invariant.

Dùng khi cập nhật `AGENTS.md`: vai trò, scope, tool permission, security hoặc escalation của AI Agent.

## Parameters

- `--section=<name>`: Optional canonical section: `identity`, `scope`, `tool-permissions`, `security`, `communication`, `error-handling`, `escalation`, `changelog`.
- `--reason=<reason>`: Required reason for permission or rule update.

## Canonical structure

`AGENTS.md` has exactly eight ordered sections: Identity & Persona, Scope & Boundaries, Tool Permissions, Security Rules, Communication Style, Error Handling, Escalation Protocol and Changelog. Modify only the applicable section. Customize generated content to observed stack, paths and exact commands; never copy generic stack commands as evidence.

## Ownership and execution model

Read `.sdd/shared_context.md` before changing roles:

- `Project Ownership: solo` means one Human project owner. It may simplify Human accountability, but never limits agent roles or prevents orchestrated dispatch.
- `Project Ownership: team` means multiple Human collaborators.
- `Agent Execution: direct` executes in the current agent session.
- `Agent Execution: orchestrated` allows `/sdd-dispatch` to coordinate workers with exclusive boundaries.

Agent roles, worker count, Lead→worker escalation and ownership boundaries depend on approved execution/tasks, not Human ownership count. Direct execution retains Human gates, profile evidence, checkpoint and no-push restrictions.

## Procedure

1. Read `AGENTS.md`, `CONSTITUTION.md`, `CLAUDE.md`, Architecture Profile, shared context and relevant constraints.
2. Identify the canonical section; do not expand permissions beyond safety boundaries.
3. Update only that section and record execution/ownership effects where relevant.
4. Bump SemVer and add a Changelog entry with reason and updater.
5. For dispatcher changes, distinguish policy from observed host enforcement; record affected role, no-self-approval/no-commit-push, bounded retry and escalation behavior.
6. Report permission impact, security risk, affected skill and escalation step.

## AI Recommendation and Human Final Review

Before editing `AGENTS.md`, create the canonical recommendation at `.sdd/reviews/agents-edit.md` with permission impact, security risk, execution/ownership effect, alternative and affected skills. A Human review must be `APPROVED` before editing. A solo owner may persist their own Human Final Review; in team ownership an authorized Human collaborator persists it. Agent never self-approves permissions.
