# Branch Update Rules (applies ONLY to updates on NEW branches)

Do NOT refactor existing working code to comply with these rules. These rules apply exclusively to NEW branches and new changes.

1. **Keep each file under 100 lines of code** (counting real code lines). This is the hard limit per file.
2. **One feature per folder** — when adding a new feature, put it in its own folder under `lib/features/`.
3. **Follow SRP (Single Responsibility Principle)** — each file/class does one thing, with a clear purpose.
4. **Keep everything very simple** — prefer small, obvious solutions over clever ones.
5. **Use very clear names** — names must explain what is going on (files, classes, vars, fields).
6. **Additive & safe** — never break existing behavior; default new fields/values so old records/data remain compatible.
7. **End-to-end tests only** — always test against the real backend, real database, and real HTTP. Never mock or fake tests.
8. **Local test DB only** — never run tests, e2e, or review links against the production database. Locally use `scripts/local_stack.sh` (Docker MongoDB); CI uses a throwaway MongoDB container. Production is only touched by the deploy workflow's final prod e2e check.

---

# Testing & Merge Policy

## 1. Test Real Behavior

Every new feature and bug fix MUST include automated tests proving its expected behavior and observable results. HTTP 200 responses, UI element existence, and method execution alone are insufficient.

## 2. E2E First, Integration Second

E2E tests MUST cover affected critical user workflows. Integration tests MUST cover backend behavior not adequately verified by E2E. Unit tests are NOT required. Tests MUST exercise real application components; mocking the system under test is prohibited.

## 3. Prove Tests Detect Failures

Every new test MUST fail when its targeted behavior is deliberately broken and pass when the behavior is correct. Tests that cannot detect the defect they claim to cover are invalid.

**Verification required before opening a PR:** Deliberately break the behavior the test covers (e.g., change the expected status code, remove the feature flag, invert a condition), run the test, confirm it fails. Restore the behavior, run the test, confirm it passes. Document this verification in the PR.

*Invalid example:* A test that only asserts `response.status_code == 200` or that a page contains a header — it still passes when the actual behavior is broken. Such a test does not satisfy this rule.

## 4. Automatic Test Discovery

Tests MUST remain in independent files and be automatically discovered by the test runner. Every PR MUST execute the required test suite through GitHub Actions. No manual test registration or file concatenation.

**This project's discovery:**
- Backend: all `backend/e2e_*.py` files are executed in CI
- Flutter: `flutter test` discovers all `*_test.dart` files

## 5. No Green CI, No Merge

All required checks MUST pass before merging into `main`. Agents MUST NOT skip, delete, weaken, or bypass failing tests. Failures MUST be fixed at their source. Direct pushes to `main` are prohibited.

**Enforcement:** Configure GitHub repository rulesets to require pull requests and passing CI checks. The CI workflow must run the tests and fail on errors. Rules 1–3 also require automated test-quality checks or review; GitHub branch protection alone cannot verify their semantics.

Core principle: No demonstrated behavior, no merge.
