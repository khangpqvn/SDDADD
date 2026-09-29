# Test Case Governance — Kiểm soát Test Case Sinh Ra

**Phiên bản:** 1.0.0  
**Ngày:** 2026-09-29  
**Mục tiêu:** Control test case generation qua requirement traceability, coverage definition, layer separation, và hybrid approval

---

## Tóm tắt nhanh

Để kiểm soát test case, bạn phải:

1. **Tie test vào requirement** — mỗi test case phải map tới REQ-XXX trong SPEC.md
2. **Define coverage strategy** — ghi rõ happy path, edge case, error case trong PLAN.md
3. **Allocate test vào layer** — domain/usecase/infra/interface test location được ghi trong TASKS.md
4. **Automated gate** — lint, naming convention, coverage % check tự động
5. **Human gate** — Lead review test logic complexity trước merge

---

## 1. Requirement Traceability

### 1.1 Tie Test Case vào Requirement

**SPEC.md** định nghĩa requirement:

```markdown
## REQ-001: User login with valid credentials

**Given** a registered user with email and password  
**When** user submits login form with correct credentials  
**Then** system returns JWT token and HTTP 200  
**And** token is valid for 24 hours

**Acceptance Criteria:**
- AC-001: Token format is valid JWT
- AC-002: Token contains user ID and email
- AC-003: Token exp claim is set to 24 hours from issue time
```

**Test case** phải cite requirement:

```typescript
// tests/usecase/login.test.ts

/**
 * @ears .sdd/features/user-auth/SPEC.md#REQ-001
 */
describe('LoginUsecase - REQ-001: User login with valid credentials', () => {
  /**
   * @ears .sdd/features/user-auth/SPEC.md#REQ-001:AC-001
   */
  it('AC-001: should return valid JWT token', async () => {
    const result = await usecase.execute('user@example.com', 'password123');
    expect(result.token).toMatch(/^eyJ/); // JWT format
  });

  /**
   * @ears .sdd/features/user-auth/SPEC.md#REQ-001:AC-002
   */
  it('AC-002: token should contain user ID and email', async () => {
    const result = await usecase.execute('user@example.com', 'password123');
    const decoded = jwt.decode(result.token);
    expect(decoded.user_id).toBeDefined();
    expect(decoded.email).toBe('user@example.com');
  });

  /**
   * @ears .sdd/features/user-auth/SPEC.md#REQ-001:AC-003
   */
  it('AC-003: token exp should be 24 hours from issue', async () => {
    const before = Math.floor(Date.now() / 1000);
    const result = await usecase.execute('user@example.com', 'password123');
    const after = Math.floor(Date.now() / 1000);
    const decoded = jwt.decode(result.token);
    const expectedExp = before + 86400; // 24 hours
    expect(decoded.exp).toBeBetween(expectedExp - 5, expectedExp + 5);
  });
});
```

### 1.2 Validate Traceability

**Automated check** qua `/sdd-trace`:

```bash
/sdd-trace --feature=user-auth --diff
```

Output:

```
✓ REQ-001 covered by 3 test case (AC-001, AC-002, AC-003)
✓ REQ-002 covered by 2 test case (AC-004, AC-005)
✓ All acceptance criteria traced

✗ Orphan test: tests/usecase/login.test.ts:45 — @ears reference not in SPEC
  → Review: is requirement obsolete or test mislabeled?
```

**Control:** Không được có orphan test (test không map tới requirement). Nếu requirement dihapus, test phải delete hoặc requirement phải restore.

---

## 2. Test Coverage Strategy

### 2.1 Define Coverage vào PLAN.md

**PLAN.md** ghi test strategy per layer:

```markdown
## Test Strategy — REQ-001, REQ-002

### Domain Layer Tests
**File:** `tests/domain/user.test.ts`  
**Scope:** User entity validation, password hashing

| Requirement | Happy Path | Edge Case | Error Case |
| :--- | :--- | :--- | :--- |
| REQ-001 (validation) | Valid email format | Whitespace email | Invalid format → Error |
| REQ-001 (password) | Min 8 chars hashed | Max 128 chars | Empty → Error |

**Expected: 6 test case**

### Use-case Layer Tests
**File:** `tests/usecase/login.test.ts`  
**Scope:** Login workflow, token generation, database query

| Requirement | Happy Path | Edge Case | Error Case |
| :--- | :--- | :--- | :--- |
| REQ-001 (login flow) | Valid cred → token | Case-insensitive email | Wrong password → 401 |
| REQ-002 (audit log) | Log on success | Concurrent login | Failed attempt logged |

**Expected: 7 test case**

### Infrastructure Layer Tests
**File:** `tests/infra/user-repository.test.ts`  
**Scope:** Database + ORM behavior, transaction

| Requirement | Happy Path | Edge Case | Error Case |
| :--- | :--- | :--- | :--- |
| REQ-001 (persistence) | User stored correctly | Duplicate email | DB error → throw |

**Expected: 4 test case**

### Interface Layer Tests
**File:** `tests/interface/auth-controller.test.ts`  
**Scope:** HTTP endpoint, request/response mapping

| Requirement | Happy Path | Edge Case | Error Case |
| :--- | :--- | :--- | :--- |
| REQ-001 (HTTP mapping) | POST /auth/login → 200 | Missing field | Malformed JSON → 400 |
| REQ-001 (response schema) | Returns token in body | Large request | Request timeout → 408 |

**Expected: 5 test case**

### Summary
- **Total: 22 test case** across 4 layers
- **Coverage ratio:** 1 test per 0.5 acceptance criteria (2:1 coverage)
- **Target pass rate:** 100% before merge
- **Target coverage %:** 80% statements + 75% branches
```

### 2.2 Size per Requirement

**Rule:** Mỗi requirement ≥ 1 happy path + 1 edge case + 1 error case.

```
REQ-001: 3 test case (1 happy + 1 edge + 1 error)
REQ-002: 2 test case (1 happy + 1 edge)
REQ-003: 1 test case (happy only, no edge/error)
Total: 6 test case
```

**Control:** PLAN ghi expected count, tester sinh đúng số, automated check verify.

---

## 3. Test Layer Separation

### 3.1 Layer Ownership Matrix

**TASKS.md** ghi test file → layer → requirement:

```markdown
## T002: Use-case layer — Login business logic

- **REQ:** REQ-001, REQ-002 (login, audit)
- **Test File:** `tests/usecase/login.test.ts`
- **Layer:** Usecase (no HTTP, no DB adapter)
- **Test Cases:**
  - AC-001: Valid credential → token (happy path)
  - AC-002: Wrong password → 401 error (error case)
  - AC-003: Concurrent login attempt (edge case)
  - AC-004: Audit log on successful login (REQ-002)
  - AC-005: Audit log on failed login (REQ-002)
  - AC-006: Rate limit after 5 failed attempts (edge case, if Spec says)

- **Mocking Strategy:**
  - Mock `UserRepository` (port interface)
  - Mock `JwtService` for token generation
  - Do NOT mock User domain class
  - Use real `LoginError` domain error type

- **Expected Assertions:**
  - Token structure correct (JWT format)
  - User not exposed in error message (security)
  - Audit log called with correct context

- **Exact Command:** `npm test tests/usecase/login.test.ts`
```

### 3.2 Layer-Specific Rules

**Domain layer:**
```
✓ Pure function/class test
✓ No mocking (if needed, architecture is wrong)
✓ No async, no I/O
✓ Validate: invariant, calculation, transformation
```

**Use-case layer:**
```
✓ Test orchestration, port contract
✓ Mock port interface only (repository, external service)
✓ Do NOT mock domain class
✓ Mock minimal; let real domain run
```

**Infra layer:**
```
✓ Test real DB/ORM behavior
✓ Use test database instance
✓ Validate query correctness, transaction
✓ Test error case (constraint violation, timeout)
```

**Interface layer:**
```
✓ Test HTTP request → response mapping
✓ Test DTO validation
✓ Test error serialization (no stack trace, secret leak)
✓ Test HTTP status code per error type
```

### 3.3 Validate Layer Placement

**Automated check — ESLint rule** (custom):

```javascript
// .eslintrc.json
{
  "overrides": [
    {
      "files": ["tests/domain/**/*.test.ts"],
      "rules": {
        "no-restricted-imports": [
          "error",
          {
            "patterns": [
              "src/interface/*",
              "src/infra/*",
              "src/usecase/*"
            ]
          }
        ]
      }
    },
    {
      "files": ["tests/usecase/**/*.test.ts"],
      "rules": {
        "no-restricted-imports": [
          "error",
          {
            "patterns": ["src/interface/*", "src/infra/*"]
          }
        ]
      }
    }
  ]
}
```

Control: Linter block test import cross-layer. Domain test cannot import usecase; usecase test cannot import interface.

---

## 4. Automated Gates (Pre-Human Review)

### 4.1 Naming Convention

**Test file naming:**
```
tests/{layer}/{feature}.test.ts
tests/domain/user.test.ts           ✓
tests/usecase/login.test.ts         ✓
tests/infra/user-repository.test.ts ✓
tests/interface/auth-controller.test.ts ✓

tests/user-login.test.ts            ✗ (no layer folder)
tests/test-login.ts                 ✗ (wrong pattern)
```

**Test case naming:**
```typescript
// ✓ Descriptive, requirement-tied
it('REQ-001: should return JWT token on valid credentials', () => {});
it('AC-001: token should include user ID', () => {});
it('should fail with 401 when password is wrong', () => {});

// ✗ Vague
it('should work', () => {});
it('test login', () => {});
it('error handling', () => {});
```

**Lint rule:**
```bash
# Check test naming via custom script
scripts/lint-test-names.sh

# Output
✓ tests/usecase/login.test.ts:12 — REQ-001: should return JWT token...
✓ tests/usecase/login.test.ts:20 — AC-001: token should include user ID...
✓ tests/interface/auth-controller.test.ts:5 — should return 200 on valid login...
✗ tests/domain/user.test.ts:30 — should work (too vague)
```

### 4.2 Coverage Requirement

**Automated gate — Coverage check:**

```bash
npm test -- --coverage --collectCoverageFrom="src/**/*.ts" --coverageThreshold='{
  "global": {
    "statements": 80,
    "branches": 75,
    "functions": 80,
    "lines": 80
  }
}'
```

Control: Test must meet 80% statement + 75% branch coverage, enforced before pass.

### 4.3 @ears Annotation Check

**Automated check:**

```bash
# Verify all @ears references exist in SPEC.md
/sdd-trace --feature=user-auth --diff

# Block if orphan or missing
if [ $(grep -c "@ears" tests/**/*.test.ts) -ne $(grep -c "^## REQ-\|^## AC-" .sdd/features/user-auth/SPEC.md) ]; then
  echo "ERROR: Test count ≠ Requirement count"
  exit 1
fi
```

### 4.4 Test Run Before Gate

**Must pass exactly:**
```bash
npm test -- --passWithNoTests  # All test pass
npm run lint                    # No lint error
npm run build                   # Type check pass
npm test -- --coverage          # Coverage threshold met
/sdd-trace --feature=user-auth --diff  # No orphan test
```

All 5 must PASS; any fail blocks merge.

---

## 5. Human Review Gate (Post-Automated)

### 5.1 What Human Reviews

**Automated check handles:**
- Naming convention ✓
- @ears annotation ✓
- Coverage % ✓
- Type check ✓
- Lint ✓

**Human reviews (spot-check):**
1. **Test logic complexity** — mock strategy correct? assertion overkill?
2. **Spec alignment** — test really validate requirement or just exercise code?
3. **Edge case coverage** — missed critical scenario?
4. **Layer violation** — test importing wrong layer?
5. **Security/performance** — test expose secret, slow query, N+1 problem?

### 5.2 Code Review Checklist

**Lead review per task:**

```markdown
## Code Review — T002: Use-case Layer Login Test

### Automated passed:
- ✓ Naming convention
- ✓ @ears reference to SPEC
- ✓ Coverage 85% (target 80%)
- ✓ Lint clean
- ✓ Type check pass

### Human review:

#### Mock Strategy
- [ ] Repository mock matches port interface signature
- [ ] No over-mocking (domain class is NOT mocked)
- [ ] Mock setup is clear and maintainable

#### Assertion Quality
- [ ] Each test has exactly one logical assertion (focused)
- [ ] Assertion message is clear
- [ ] Not asserting implementation detail (e.g. internal state)

#### Spec Alignment
- [ ] Test really validate AC-001, not just exercise code
- [ ] Error case in test match Spec error contract
- [ ] Happy path ≠ just "no exception"

#### Security / Performance
- [ ] No credential leak in test setup
- [ ] Mock database query count reasonable (no N+1)
- [ ] Timeout set if async operation

#### Decision
- [ ] Approved — merge ready
- [ ] Request changes — specific comments below
- [ ] Decline — design issue, need redesign

### Comments
(Lead provides specific feedback or approves)
```

### 5.3 Review Workflow in Git

**Branch:** `feature/user-auth`

**PR description includes test strategy:**
```markdown
## Test Coverage

**Expected:** 22 test case across 4 layers
**Actual:** 22 test case

- Domain: 6 test (user validation, hashing)
- Use-case: 7 test (login flow, audit)
- Infra: 4 test (persistence, transaction)
- Interface: 5 test (HTTP mapping, error response)

**Coverage:** 85% (target 80%)
**Lint:** Pass
**All test:** Pass

See `.sdd/features/user-auth/PLAN.md#test-strategy` for detail.
```

**Review comment by Lead:**
```
✓ Approved with note: 
  - Mock strategy is clear (repository only)
  - AC-002 assertion is tight (no over-check)
  - Coverage exceeded target, good
  → Ready to merge
```

---

## 6. Control Checklist

### Pre-Implementation
- [ ] SPEC.md define requirement + acceptance criteria
- [ ] PLAN.md define test strategy (happy/edge/error per layer)
- [ ] PLAN.md estimate test count per layer (22 total)
- [ ] PLAN.md define mock strategy per layer
- [ ] TASKS.md allocate test file + required test case

### During Implementation
- [ ] Test file location = `tests/{layer}/{feature}.test.ts`
- [ ] Test case name include `@ears REQ-XXX:AC-YYY`
- [ ] Mock strategy follow layer rules (domain not mocked, port interface mocked)
- [ ] Each test has single logical assertion
- [ ] Security: no credential/secret in test setup

### Post-Implementation (Automated)
- [ ] `npm test` pass 100%
- [ ] `npm run lint` pass 100%
- [ ] `npm run build` pass (type check)
- [ ] `npm test -- --coverage` meet 80% threshold
- [ ] `/sdd-trace --diff` no orphan test

### Pre-Merge (Human Gate)
- [ ] Lead review checklist pass
- [ ] Mock strategy approved
- [ ] Spec alignment verified
- [ ] Security/performance OK
- [ ] Approved in PR comment

---

## 7. Example: Feature Full Control

### Feature: User Login (REQ-001, REQ-002)

**SPEC.md:**
```markdown
## REQ-001: Login with valid credentials
- AC-001: Return JWT token
- AC-002: Token contain user ID
- AC-003: Token exp = 24 hours

## REQ-002: Audit login attempt
- AC-004: Log success
- AC-005: Log failure
```

**PLAN.md:**
```markdown
## Test Strategy
- Domain: 3 test (user validation)
- Use-case: 5 test (login flow + audit) ← REQ-001, REQ-002
- Infra: 2 test (persistence)
- Interface: 4 test (HTTP mapping)
Total: 14 test
```

**TASKS.md:**
```markdown
## T002: Use-case layer

- **Test File:** `tests/usecase/login.test.ts`
- **REQ:** REQ-001, REQ-002
- **Expected test case:** 5
  - AC-001: Happy path → token
  - AC-002: Edge case — concurrent login
  - AC-003: Error case — wrong password
  - AC-004: REQ-002 — audit log on success
  - AC-005: REQ-002 — audit log on failure

- **Mock Strategy:**
  - Mock UserRepository
  - Mock AuditLogger
  - Do NOT mock User domain
  - Real LoginError

- **Exact Command:** `npm test tests/usecase/login.test.ts`
```

**Test file (`tests/usecase/login.test.ts`):**
```typescript
/**
 * @ears .sdd/features/user-auth/SPEC.md#REQ-001
 * @ears .sdd/features/user-auth/SPEC.md#REQ-002
 */
describe('LoginUsecase - REQ-001, REQ-002', () => {
  /**
   * @ears .sdd/features/user-auth/SPEC.md#REQ-001:AC-001
   */
  it('AC-001: should return JWT token on valid credentials', async () => {
    const result = await usecase.execute('user@example.com', 'password123');
    expect(result.token).toMatch(/^eyJ/);
  });

  /**
   * @ears .sdd/features/user-auth/SPEC.md#REQ-001:AC-002
   */
  it('AC-002: should handle concurrent login gracefully', async () => {
    const promise1 = usecase.execute('user@example.com', 'password123');
    const promise2 = usecase.execute('user@example.com', 'password123');
    const [result1, result2] = await Promise.all([promise1, promise2]);
    expect(result1.token).not.toBe(result2.token);
  });

  /**
   * @ears .sdd/features/user-auth/SPEC.md#REQ-001:AC-003
   */
  it('AC-003: should fail with 401 on wrong password', async () => {
    expect(() => usecase.execute('user@example.com', 'wrongpassword'))
      .toThrow(LoginError);
  });

  /**
   * @ears .sdd/features/user-auth/SPEC.md#REQ-002:AC-004
   */
  it('AC-004: should audit log on successful login', async () => {
    await usecase.execute('user@example.com', 'password123');
    expect(auditLogger.log).toHaveBeenCalledWith(
      expect.objectContaining({ action: 'LOGIN_SUCCESS' })
    );
  });

  /**
   * @ears .sdd/features/user-auth/SPEC.md#REQ-002:AC-005
   */
  it('AC-005: should audit log on failed login', async () => {
    try {
      await usecase.execute('user@example.com', 'wrongpassword');
    } catch {}
    expect(auditLogger.log).toHaveBeenCalledWith(
      expect.objectContaining({ action: 'LOGIN_FAILED' })
    );
  });
});
```

**Automated check passes:**
```bash
npm test tests/usecase/login.test.ts
# ✓ 5 test case pass
# ✓ All @ears reference traced to SPEC
# ✓ Coverage 92% (target 80%)
# ✓ No lint error
```

**Lead review passes:**
```
✓ Mock strategy correct (UserRepository mocked, domain not)
✓ Spec alignment verified (5 AC covered)
✓ Concurrent login edge case good
✓ Audit log verification correct
✓ Ready to merge
```

---

## Summary: Three Control Layers

| Layer | Tool | Pass Condition |
| :--- | :--- | :--- |
| **1. Traceability** | `/sdd-trace --diff` | 0 orphan test, 100% AC covered |
| **2. Automation** | `npm test`, lint, coverage, build | All pass, no error |
| **3. Human** | Code review checklist | Lead approved specific test logic |

All three layers must pass before merge.

---

## Quick Command Reference

| Purpose | Command |
| :--- | :--- |
| Check test coverage | `npm test -- --coverage` |
| Trace requirement ↔ test | `/sdd-trace --feature=user-auth --diff` |
| Validate layer separation | `npm run lint` (custom rules) |
| Run test per layer | `npm test tests/{domain\|usecase\|infra\|interface}/` |
| Pre-merge validation | `npm test && npm run lint && npm run build` |
| Approve test in PR | `/sdd-review --feature=user-auth --artifact=tasks --status=APPROVED` |
