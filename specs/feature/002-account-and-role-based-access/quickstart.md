# Quickstart: Account and Role-Based Access — Manual Verification

**Branch**: `feature/002-account-and-role-based-access` | **Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
Pre-req: foundation `001` already on `main` (or at least `melos bootstrap` completed); Docker Desktop available.

## 1. Bootstrap & Backend

```bash
git checkout feature/002-account-and-role-based-access
melos bootstrap          # links core/app/web, installs pub deps
cp .env.example .env     # set API_BASE_URL=http://localhost:8080, WS_URL=ws://localhost:8080/api/ws, SENTRY_DSN=
docker compose -f docker/docker-compose.yml up -d   # start Spring Boot backend matching openapi.yaml v0.1.0
# wait for: curl -s http://localhost:8080/health -> 200
```

## 2. Generate & Verify Build

```bash
melos run build           # build_runner for riverpod/auth + openapi-generator auth client
melos run analyze         # must pass with zero infos/warnings (strict)
melos run format          # verify formatting
melos run test            # core unit (value objects, role guards, refresh single-flight) — expect ≥75% core coverage
```

## 3. Customer App (Flutter) — Registration → Login → Profile → Logout

```bash
cd app && flutter run -d <emulator|device>
```

- Unauthenticated launch → redirected to `/login` with link to `/register` (Story 3 scenario 1).
- `/register`: try weak password `abc12` (<8, letter+digit fails) → inline "8+ chars, letter+digit" (FR-002); try invalid email `alice@` → email inline error; try username `ab` (<3) or `alice!` (char fail) → username inline per clarification Q1; submit valid `alice / alice@example.com / Secr3tPwd1` → 201, success snackbar, auto-routed to `/catalog` as `CUSTOMER` (FR-001/FR-004/SC-001).
- Register same `alice` again → 409 banner "already registered" (FR-003).
- Kill and relaunch app → still authenticated, `/auth/me` shows `alice / alice@example.com / CUSTOMER` on Profile page with id+roles (SC-003 / FR-010).
- Profile → Logout → redirected to `/login`, back gesture does not restore session, relaunch requires login (FR-011/SC-007).
- `/login` with wrong password → 401 inline "Invalid username or password." (FR-006); try email `alice@example.com` as username → 401 as well (Q2 contract-strict).
- Login `customer / customer` (seeded) → succeeds; hammer wrong password 5+x → 429 banner with countdown respecting `Retry-After` seconds when returned by server, otherwise 60 s generic window, submit disabled until elapsed (FR-006+Q4/SC-002).

## 4. Session Renewal (Single-Flight) — Manual Forcing

- Lower server token TTL via `.env` if supported, or force 401 by patching interceptor to expire `accessToken` early.
- While `authenticated`, trigger 3 parallel protected calls (open profile twice + navigate to orders) after expiry → observe only one `POST /auth/refresh` in proxy logs, all 3 succeed after single renewal (FR-008+Q5).
- Invalidate `refreshToken` in storage (dev tool clear) then trigger protected call → refresh 401 → cleared, redirected to `/login` "Session expired." (FR-009).

## 5. Dashboard (Jaspr Web) — Role Guards

```bash
cd web && jaspr serve
# open http://localhost:3000
```

- Unauthenticated direct nav to `/fulfillment` → redirected to `/login?redirect=/fulfillment` (FR-012).
- Login as seeded `admin / admin` → lands on `/admin/dashboard` (highest-privilege ADMIN default, Q3), sidebar shows catalog management + audit + fulfillment; profile shows roles `ADMIN`.
- Login as seeded `warehouse / warehouse` → lands on `/fulfillment` (WAREHOUSE queue), sidebar hides product create/edit/audit (FR-013); attempt direct `/admin/products/new` → friendly `UnauthorizedPage` "You don't have permission." with back link (SC-004).
- Multi-role user `adminwarehouse` (if seeded) → lands on `/admin/dashboard` (priority `ADMIN > WAREHOUSE`, Q3) but can navigate to queue freely (union permission).
- Login as customer `alice` on web login page → if routed to web at all, should still authenticate but immediately see `UnauthorizedPage` for any dashboard route (CUSTOMER 1:1 screen map, SC-005). Order scoping: on web, CUSTOMER token listing `/orders` shows only own orders; another customer's order id returns 403 → `AuthorizationFailure` banner (FR-014).

## 6. Feedback & Security Checks

- Every submit shows disabled button + spinner within 200 ms, no double POST (FR-016/SC-006).
- Network kill (docker stop) mid-login → `NetworkFailure` snackbar "No internet. Try again." with Retry that replays call (FR-015).
- Search logs/device storage for strings of `accessToken` — none (SC-007). Web inspect `localStorage` when httpOnly not used → entry encrypted, not plaintext JWT.
- Release builds locally: `flutter build apk --obfuscate --split-debug-info=build/symbols` and `jaspr build --release` must succeed (constitution VIII).

## 7. Test & Coverage Gate

```bash
melos run flutter_test
# check core coverage
dart test --coverage=coverage && format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.packages --report-on=lib
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
# assert core ≥75%
```

Expected artifacts for this feature: 5 user stories pass reliably; SC-001..SC-007 thresholds satisfied on manual run.
