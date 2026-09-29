# Testing Workflow trong SDD + ADD Template

**Phiên bản:** 1.0.0  
**Ngày:** 2026-09-29  
**Mục tiêu:** Hướng dẫn cách setup và thực thi test khi áp dụng template SDD/ADD cho dự án thật

---

## Tóm tắt nhanh

Để test được dự án, bạn phải:

1. **Chọn test framework** (Jest, Vitest, Mocha, vv.)
2. **Cập nhật Architecture Profile** với binding và exact command
3. **Theo flow SDD/ADD** từ feature requirement → SPEC → PLAN → TASKS → execution
4. **Chạy exact approved command** không đoán hay thay đổi

Test không được thực thi ngay lập tức. Test là verification command, được ghi trong Architecture Profile và chỉ chạy khi **approved binding + feature requirement** đã rõ ràng.

---

## Giai đoạn 1: Bootstrap và chọn Test Framework

### 1.1 Khởi tạo repository mới

```bash
cd /path/to/your-project
/sdd-init --project-name="my-project"
```

Hoặc với repository đã có code:

```bash
scripts/adopt.sh /path/to/your-project
cd /path/to/your-project
/sdd-adopt
```

**Output:** `.sdd/architecture-profile.md` ở trạng thái `DRAFT` với binding chưa chọn.

### 1.2 Chọn test framework

Quyết định framework phù hợp dự án của bạn:

| Framework | Phù hợp khi | Lệnh verify |
| :--- | :--- | :--- |
| **Jest** | TypeScript, Node.js, React, unit + integration | `npm test` hoặc `jest` |
| **Vitest** | TypeScript, ESM, nhanh, modern | `npm test` hoặc `vitest run` |
| **Mocha + Chai** | Custom setup, flexibility cao | `npm test` hoặc `mocha` |
| **ts-jest** | TypeScript + Jest | `npm test` hoặc `jest` |
| **Node native test** | Node.js 18+, zero dependency | `npm test` hoặc `node --test` |

**Quyết định thêm:**
- Build command: `npm run build`, `tsc`, `tsup`, vv.
- Lint command: `eslint`, `oxlint`, vv.
- Test watch mode: `jest --watch`, `vitest` (default)
- Coverage: `jest --coverage`, `vitest --coverage`

### 1.3 Cập nhật package.json

```json
{
  "name": "my-project",
  "version": "1.0.0",
  "scripts": {
    "test": "jest --passWithNoTests",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "build": "tsc --noEmit",
    "lint": "eslint src tests"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "ts-jest": "^29.0.0",
    "@types/jest": "^29.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.0.0",
    "typescript": "^5.0.0"
  }
}
```

Chạy:

```bash
npm install
```

### 1.4 Cập nhật Architecture Profile

Mở `.sdd/architecture-profile.md` và thay thế hàng binding `Test framework / command`:

**Từ:**
```markdown
| Test framework / command | Chưa chọn | BLOCKED trước executable task | Không có `package.json`, script hoặc Human decision |
```

**Sang:**
```markdown
| Test framework / command | Jest + TypeScript via `npm test` | APPROVED | `package.json#scripts.test = "jest --passWithNoTests"`, `jest.config.js` |
```

Tương tự cho build/lint:

```markdown
| Build / lint command | TypeScript compiler + ESLint via `npm run build` và `npm run lint` | APPROVED | `package.json#scripts.build` và `package.json#scripts.lint`, `tsconfig.json`, `.eslintrc.json` |
```

### 1.5 Review Architecture Profile

Yêu cầu Human review xác nhận binding:

```bash
/sdd-review --target=.sdd/architecture-profile.md \
  --status=APPROVED \
  --decision="Selected Jest + TypeScript, npm test verified against package.json, tsconfig.json and jest.config.js" \
  --reviewer="<your-name>" \
  --follow-up="/sdd-context --feature=<first-feature>"
```

**Status sau review:** Architecture Profile = `APPROVED`, test framework binding rõ ràng, sẵn sàng feature development.

---

## Giai đoạn 2: Feature Development Flow

### 2.1 Tạo CONTEXT cho feature

```bash
/sdd-context --feature=user-authentication
```

**Output:** `.sdd/features/user-authentication/CONTEXT.md`

Ghi: WHAT (feature là gì), WHY (tại sao cần), Definition of Done, boundary, exclusion, glossary.

**Review và approve:**

```bash
/sdd-review --feature=user-authentication --artifact=context \
  --status=APPROVED \
  --decision="Feature scope clear, authentication flow boundary set" \
  --reviewer="<your-name>" \
  --follow-up="/sdd-spec --feature=user-authentication"
```

### 2.2 Viết SPEC (behavior & acceptance criteria)

```bash
/sdd-spec --feature=user-authentication
```

**Output:** `.sdd/features/user-authentication/SPEC.md`

Ghi requirement theo EARS format (Given-When-Then), acceptance criteria, error case, out of scope.

**Ví dụ:**
```markdown
## REQ-001: User login with valid credentials

**Given** a registered user with email and password  
**When** user submits login form with correct credentials  
**Then** system returns JWT token and HTTP 200

## REQ-002: User login with invalid credentials

**Given** a registered user  
**When** user submits login with wrong password  
**Then** system returns error message and HTTP 401
```

Lint spec:

```bash
/sdd-lint --feature=user-authentication
```

**Review và lock:**

```bash
/sdd-review --feature=user-authentication --artifact=spec \
  --status=APPROVED \
  --decision="Spec complete, EARS format valid, acceptance criteria testable" \
  --reviewer="<your-name>" \
  --follow-up="/sdd-plan --feature=user-authentication"
```

### 2.3 Lập PLAN (design + test strategy)

```bash
/sdd-plan --feature=user-authentication
```

**Output:** `.sdd/features/user-authentication/PLAN.md`

Ghi: REQ mapping, component/file path, data flow, state change, error contract, **test strategy** (unit/integration/e2e breakdown).

**Ví dụ test strategy:**
```markdown
## Test Strategy

### Unit Tests
- `tests/domain/user.test.ts`: User entity validation
- `tests/usecase/login.test.ts`: Login business logic, REQ-001, REQ-002
- Command: `npm test tests/usecase/login.test.ts`

### Integration Tests
- `tests/infra/user-repository.test.ts`: Database + ORM behavior
- `tests/interface/auth-controller.test.ts`: HTTP endpoint mapping
- Command: `npm test tests/interface/`

### Validation Command
- Type check: `npm run build`
- Lint: `npm run lint`
- All tests: `npm test`
```

**Review và approve:**

```bash
/sdd-review --feature=user-authentication --artifact=plan \
  --status=APPROVED \
  --decision="Design testable, layer separation clear, test command matches Architecture Profile" \
  --reviewer="<your-name>" \
  --follow-up="/sdd-tasks --feature=user-authentication"
```

### 2.4 Chia TASKS (executable work unit)

```bash
/sdd-tasks --feature=user-authentication
```

**Output:** `.sdd/features/user-authentication/TASKS.md`

Mỗi task ghi: requirement mapping, file boundary, exact command, sizing.

**Ví dụ:**
```markdown
## T001: Domain layer — User entity

- **REQ:** REQ-001, REQ-002 (validation)
- **Boundary:** `src/domain/user.ts`, `tests/domain/user.test.ts`
- **Exact command:** `npm test tests/domain/user.test.ts`
- **Sizing:** ~2h
- **Post-code route:** `/sdd-lint --feature=user-authentication` then `/sdd-audit`

## T002: Use-case layer — Login business logic

- **REQ:** REQ-001, REQ-002 (logic)
- **Boundary:** `src/usecase/login.ts`, `tests/usecase/login.test.ts`
- **Exact command:** `npm test tests/usecase/login.test.ts`
- **Sizing:** ~3h
- **Post-code route:** `/sdd-trace --feature=user-authentication --diff`

## T003: Interface layer — HTTP adapter

- **REQ:** REQ-001, REQ-002 (HTTP mapping)
- **Boundary:** `src/interface/auth-controller.ts`, `tests/interface/auth-controller.test.ts`
- **Exact command:** `npm test tests/interface/`
- **Sizing:** ~2h
- **Post-code route:** `/sdd-audit --feature=user-authentication`

## T004: Integration test + validation

- **REQ:** All (end-to-end)
- **Boundary:** Full feature test suite
- **Exact command:** `npm test && npm run lint && npm run build`
- **Sizing:** ~1h
- **Post-code route:** `/git-validate --scope=commit --feature=user-authentication`
```

**Review và approve:**

```bash
/sdd-review --feature=user-authentication --artifact=tasks \
  --status=APPROVED \
  --decision="Tasks boundary clear, exact commands tied to Architecture Profile, sizing realistic" \
  --reviewer="<your-name>" \
  --follow-up="/add-execute --feature=user-authentication --all"
```

---

## Giai đoạn 3: Execution và Test Run

### 3.1 Execute một task với test

```bash
/add-execute --feature=user-authentication --task=T001
```

Agent sẽ:
1. Validate task scope, requirement mapping, boundary
2. Xác nhận Architecture Profile approved
3. Tạo Execution Record
4. Implement feature code
5. Chạy exact command: `npm test tests/domain/user.test.ts`
6. Ghi Action Record với test result

**Output:** Test pass/fail, coverage report, error message (nếu có).

### 3.2 Execute tất cả task

```bash
/add-execute --feature=user-authentication --all
```

Agent chạy task T001 → T002 → T003 → T004 theo dependency order. Mỗi task:
1. Thực thi scope
2. Chạy exact command từ TASKS.md
3. Validate output
4. Dừng nếu fail; không tiếp tục task sau

### 3.3 Post-execution validation

Sau mỗi execute, trigger validation route:

```bash
# Nếu SPEC thay đổi
/sdd-lint --feature=user-authentication

# Nếu source/contract đổi
/sdd-audit --feature=user-authentication

# Nếu requirement ↔ code diverge
/sdd-trace --feature=user-authentication --diff

# Trước commit
/git-validate --scope=commit --feature=user-authentication
```

**All validation pass = READY để commit.**

---

## Giai đoạn 4: Test Maintenance & Recovery

### 4.1 Khi test fail

**Không được:** đổi command để qua test, edit code bằng chat trước khi hiểu root cause.

**Làm:**
1. Đọc test output, xác định fail reason
2. Phân loại: implementation defect (code bug) hay test defect (sai test assumption)?
3. Fix code hoặc test, rerun exact command
4. Validate lại với `/sdd-audit --feature=...`

**Ví dụ:**
```bash
npm test tests/usecase/login.test.ts
# Output: FAIL - User validation failed
# Root: Password hash not implemented

# Fix code
# Rerun
npm test tests/usecase/login.test.ts
# Output: PASS
```

### 4.2 Khi Spec thay đổi

Nếu requirement thay đổi (e.g., password validation rule):

```bash
/sdd-update --feature=user-authentication --artifact=spec --bump=patch --reason="Add password min-length requirement"
```

Agent sẽ:
1. Invalidate downstream approval (PLAN, TASKS, code)
2. Update SPEC.md
3. Mark test as stale (cần rewrite)
4. Dừng execution cho tới re-review

**Sau update:**
```bash
# Review spec update
/sdd-review --feature=user-authentication --artifact=spec ...

# Plan lại test strategy
/sdd-plan --feature=user-authentication

# Re-write tasks với new requirement
/sdd-tasks --feature=user-authentication

# Execute lại
/add-execute --feature=user-authentication --all
```

### 4.3 Khi test command thay đổi

Nếu chuyển từ Jest → Vitest:

```bash
# Update Architecture Profile
# Edit .sdd/architecture-profile.md: "Test framework / command" → Vitest

# Review xác nhận binding
/sdd-review --target=.sdd/architecture-profile.md \
  --status=APPROVED \
  --decision="Migrated to Vitest, npm test now runs vitest run" \
  --reviewer="<your-name>"

# Update TASKS.md để reflect new command
/sdd-update --feature=user-authentication --artifact=tasks --reason="Vitest migration"

# Re-execute với new command
/add-execute --feature=user-authentication --all
```

---

## Giai đoạn 5: Test Best Practices trong Template

### 5.1 Test file organization

```
tests/
├── domain/
│   └── user.test.ts            # Domain entity, no framework dependency
├── usecase/
│   ├── login.test.ts           # Use-case business logic
│   └── list-users.test.ts
├── infra/
│   ├── user-repository.test.ts # DB/ORM adapter
│   └── cache.test.ts
├── interface/
│   ├── auth-controller.test.ts # HTTP controller
│   └── user-controller.test.ts
└── shared/
    ├── error.test.ts           # Error handling
    └── logger.test.ts
```

### 5.2 Test structure per layer

**Domain layer test** — No mocking, pure TypeScript:
```typescript
// tests/domain/user.test.ts
import { User } from '../../src/domain/user';

describe('User', () => {
  it('should validate email format', () => {
    const user = new User('invalid-email', 'password123');
    expect(user.isValid()).toBe(false);
  });
  
  it('REQ-001: should hash password', () => {
    const user = new User('user@example.com', 'password123');
    expect(user.password).not.toBe('password123');
  });
});
```

**Use-case layer test** — Mock port interface:
```typescript
// tests/usecase/login.test.ts
import { LoginUsecase } from '../../src/usecase/login';
import { UserRepository } from '../../src/infra/user-repository'; // interface only

describe('LoginUsecase - REQ-001, REQ-002', () => {
  it('REQ-001: should return token on valid credentials', async () => {
    const mockRepository = {
      findByEmail: jest.fn().mockResolvedValue(validUser),
    };
    const usecase = new LoginUsecase(mockRepository);
    const result = await usecase.execute('user@example.com', 'password123');
    expect(result.token).toBeDefined();
  });
});
```

**Interface layer test** — Full request/response:
```typescript
// tests/interface/auth-controller.test.ts
import request from 'supertest';
import app from '../../src/app';

describe('Auth Controller - REQ-001, REQ-002', () => {
  it('REQ-001: POST /auth/login should return 200 with token', async () => {
    const res = await request(app)
      .post('/auth/login')
      .send({ email: 'user@example.com', password: 'password123' });
    
    expect(res.status).toBe(200);
    expect(res.body.token).toBeDefined();
  });
});
```

### 5.3 Test command per Architecture Profile

**Approved commands** (never changed):
```bash
# Unit test (domain + usecase)
npm test tests/domain tests/usecase

# Integration test (infra + interface)
npm test tests/infra tests/interface

# All tests
npm test

# Coverage
npm test -- --coverage

# Watch mode
npm test -- --watch
```

### 5.4 Traceability: `@ears` comment

**Requirement:** REQ-001 in SPEC.md
```typescript
/**
 * @ears .sdd/features/user-authentication/SPEC.md#REQ-001
 */
async execute(email: string, password: string): Promise<LoginResult> {
  const user = await this.userRepository.findByEmail(email);
  if (!user || !user.verifyPassword(password)) {
    throw new UnauthorizedError('Invalid credentials');
  }
  const token = this.generateJWT(user);
  return { token, user };
}
```

**Test:**
```typescript
/**
 * @ears .sdd/features/user-authentication/SPEC.md#REQ-001
 */
it('REQ-001: should return token on valid credentials', async () => {
  // test implementation
});
```

---

## Checklist: Ready to Test

- [ ] **Architecture Profile approved** dengan exact test command
- [ ] **package.json** cập nhật scripts (test, build, lint)
- [ ] **Test framework installed** (`npm install`)
- [ ] **CONTEXT approved** cho feature
- [ ] **SPEC approved & locked** với requirement rõ ràng
- [ ] **PLAN approved** với test strategy per layer
- [ ] **TASKS approved** với exact command per task
- [ ] **Test file structure** tạo (`tests/domain/`, `tests/usecase/`, vv.)
- [ ] **First test written** chạy qua `/add-execute --task=T001`
- [ ] **`/git-validate` pass** trước commit
- [ ] **Coverage report** reviewed (nếu có target)

---

## Command Reference

| Mục đích | Command |
| :--- | :--- |
| Choose framework | Cập nhật `.sdd/architecture-profile.md` + review |
| Run unit test | `npm test tests/domain tests/usecase` |
| Run integration test | `npm test tests/infra tests/interface` |
| Run all tests | `npm test` |
| Watch mode | `npm test -- --watch` |
| Coverage | `npm test -- --coverage` |
| Lint before commit | `npm run lint` |
| Type check | `npm run build` |
| Validate before commit | `/git-validate --scope=commit --feature=<slug>` |
| Execute feature task | `/add-execute --feature=<slug> --task=<T001>` |
| Update Spec + re-test | `/sdd-update --feature=<slug> --artifact=spec ...` |

---

## Thường gặp

**Q: Tôi có thể chạy `npm test` ngay bây giờ không?**  
A: Không. Chỉ khi Architecture Profile approved binding. Template strict: không đoán command.

**Q: Test được chạy ở đâu trong workflow?**  
A: Trong `/add-execute`. Task phải ghi exact command; agent chạy nó tự động sau code change.

**Q: Nếu test fail, tôi làm gì?**  
A: Phân loại cause (code bug vs test defect), fix, rerun exact command, validate lại qua `/sdd-audit`.

**Q: Có thể thay đổi test command không?**  
A: Chỉ qua `/sdd-review` cho Architecture Profile. Không tự đổi command giữa task.

**Q: Nếu Spec thay đổi, test cũ còn hợp lệ không?**  
A: Không. `/sdd-update --artifact=spec` invalidate downstream. Phải rewrite test và re-approve.

---

## Liên kết

- `.sdd/architecture-profile.md` — Tech binding & exact command
- `.sdd/features/{slug}/SPEC.md` — Requirement & acceptance criteria
- `.sdd/features/{slug}/PLAN.md` — Test strategy per layer
- `.sdd/features/{slug}/TASKS.md` — Test command per task
- `docs/sdd-add-quickstart.md` — Feature flow
- `CONSTITUTION.md` § ENG-03 — Test command verification rule
