# CONSTRAINT LAYER 1: GLOBAL TECH STANDARDS
# Version: 1.0.0
# Scope: All agents, all features — non-negotiable baseline
# Reference: Slide 10.4 — 3-Layer Constraint Hierarchy

---

## 1. Approved Tech Stack

| Category        | Approved                              | Banned                            |
| :-------------- | :------------------------------------ | :-------------------------------- |
| Runtime         | Node.js ≥ 20 LTS, TypeScript ≥ 5.0   | Deno (requires RFC)               |
| Framework       | NestJS, Express, Fastify              | Bun HTTP (requires RFC)           |
| ORM / DB Client | TypeORM, Prisma, pg (raw)             | Sequelize (legacy, banned)        |
| Cache           | Redis (ioredis), in-memory Map        | Memcached                         |
| Testing         | Jest, Vitest, Supertest               | Mocha (legacy, banned)            |
| Message Queue   | Bull/BullMQ, RabbitMQ                 | Redis Pub/Sub for durable queues  |
| Auth            | passport-jwt, better-auth             | Session cookies for APIs          |

---

## 2. Approved / Banned Packages

### Approved (pre-vetted, no consent needed)
- `zod` — schema validation
- `dayjs` — date manipulation (NOT `moment.js`)
- `pino` / `winston` — logging
- `dotenv` — env loading
- `uuid` — ID generation
- `bcrypt` / `argon2` — password hashing

### Banned (requires RFC + Tech Lead approval to unban)
- `moment.js` — deprecated, heavy; use `dayjs`
- `lodash` — prefer native ES2022+ methods
- `request` / `node-fetch@2` — use native `fetch` (Node 18+)
- `eval`, `Function()` constructor — security risk

---

## 3. File Naming Conventions

| Type             | Convention          | Example                       |
| :--------------- | :------------------ | :---------------------------- |
| Source files     | kebab-case          | `order-repository.ts`         |
| Classes/Types    | PascalCase          | `OrderRepository`             |
| Constants        | SCREAMING_SNAKE     | `MAX_RETRY_COUNT`             |
| Environment vars | SCREAMING_SNAKE     | `DATABASE_URL`                |
| Test files       | `*.spec.ts`         | `order-service.spec.ts`       |
| SDD artifacts    | UPPERCASE.md        | `SPEC.md`, `PLAN.md`          |
| Scripts          | kebab-case          | `self-heal.sh`                |

---

## 4. Code Size Limits (Context Hygiene)

- Max lines per source file: **200 lines** — split into modules if exceeded
- Max lines per SDD artifact (SPEC, PLAN): **300 lines**
- Max function/method body: **50 lines** — extract helpers otherwise

---

## 5. Environment Variables Protocol

- ALL secrets loaded via `process.env.VAR_NAME` — no inline values
- Required vars documented in `.env.example` — never `.env` committed to git
- Validation at boot: throw `ConfigurationError` if required var missing
