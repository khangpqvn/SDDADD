# Architecture Profile Guide
# Version: 1.1.0

`.sdd/architecture-profile.md` is the machine-readable source of truth for technology bindings and exact verification commands. `CLAUDE.md` reflects approved architecture for humans; it does not select stack.

## Precedence

```text
approved Architecture Profile
→ clear repository evidence
→ explicit command input
→ core-only baseline
```

Conflict is a configuration blocker. Create a `PENDING HUMAN REVIEW` recommendation; do not select a side.

## Core-only baseline

The starter confirms only:

```text
TypeScript + Node.js + Clean Architecture / Hexagonal Architecture
```

It does not choose HTTP transport, database, ORM/query layer, validation library, cache/broker, test/build/lint command or deployment tooling.

## Artifact gates

| Artifact/action | Binding requirement |
| :--- | :--- |
| Context and Spec | May remain technology-neutral. Record unknowns and blockers. |
| Plan and Tasks | Need every feature-relevant binding plus exact runnable verification commands. |
| Execute and layer edit | Need approved prerequisite artifacts, relevant profile evidence and exact commands. |
| Technical audit | May audit framework-neutral rules; adapter-specific work returns `CONFIGURATION GAP` until binding exists. |

Methodology Profile controls depth, risk posture and review route. It cannot choose a technology, replace evidence, invent a command or bypass these gates.

## Greenfield

```text
/sdd-init --project-name="<name>"
/sdd-context --feature=<slug>
/sdd-spec --feature=<slug>
```

Before technical Plan/Tasks, record binding evidence and exact commands. Then use the supported review target:

```text
/sdd-review --target=.sdd/architecture-profile.md --status=APPROVED \
  --decision="Approved bindings and exact verification commands for <scope>." \
  --reviewer="<human reviewer>" --follow-up="/sdd-plan --feature=<slug>"
```

Profile review confirms presented evidence. It does not fill a missing binding or command.

## Brownfield

`/sdd-adopt` gathers manifest, lockfile, runtime bootstrap, DB/migration configuration, CI, test configuration and source-layout evidence. Human review must verify:

- every selected dependency/binding has a source path;
- layer mapping reflects the actual repository;
- conflicting input was explicitly decided;
- test/build/lint commands are exact and runnable;
- discovered values remain draft until durable review.

## Required Planning Decisions

| Feature behavior | Profile information needed |
| :--- | :--- |
| Route/controller/middleware | transport framework and validation approach |
| Persist/query/migrate | database and query/ORM layer |
| External service/cache/queue | implementation binding for the used adapter |
| Test task | exact test command and its evidence |
| Build/lint/CI task | exact command and its evidence |

If missing, stop technical planning and record the requested decision, inspected evidence, risk and next review command.

## Stack change

1. Propose profile binding, rationale, evidence, migration risk and `PENDING HUMAN REVIEW`.
2. Obtain profile review; then synchronize `CLAUDE.md` using `/sdd-claude-edit` when human-readable architecture changed.
3. Identify invalidated Context/Spec/Plan/Tasks/code/tests/contracts.
4. Use `/sdd-update` for behavior or artifact changes and review affected downstream work.
5. Run only commands approved in the new profile.

## Dispatch

Lead provides every sub-agent profile version/status, selected binding/evidence and exact approved command. A sub-agent stops on mismatch or missing binding; it does not borrow a tool or infer a package to bypass the profile gate.

## Checklist

- [ ] Profile binding is approved for every technical behavior in scope.
- [ ] Evidence points to manifest/config/source or a durable Human decision.
- [ ] Plan/Tasks use only approved adapters and commands.
- [ ] Shadow Plan names profile version, evidence and exact commands.
- [ ] Methodology Profile does not bypass technical gates.
- [ ] Stack changes invalidate and review affected downstream artifacts.
