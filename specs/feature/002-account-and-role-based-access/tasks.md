# Tasks: Account and Role-Based Access

**Input**: Design documents from `/specs/feature/002-account-and-role-based-access/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Tests are included per constitution IX (≥75% core coverage) and spec Constitution Alignment. Generate test tasks FIRST and ensure they FAIL before implementation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Core**: `core/lib/...` (shared library, pure Dart domain)
- **Mobile app**: `app/lib/...` (Flutter)
- **Web dashboard**: `web/lib/...` (Jaspr)
- **Tests**: `core/test/...`, `app/test/...`, `web/test/...`
- Adjust paths per plan.md Project Structure

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and auth scaffolding (no business logic yet)

- [X] T001 Create feature working directory and verify branch `feature/002-account-and-role-based-access` with contracts copy
- [X] T002 Run `melos bootstrap` and confirm `core/app/web` dependencies resolve per `melos.yaml`
- [X] T003 [P] Configure `core/lib/core.dart` public barrel to export new `auth` domain/application symbols (no internal `src/` imports allowed per constitution II)
- [X] T004 [P] Add auth string keys to `core/lib/constants/strings.dart` (registration, login, validation messages, rate-limit, permission-denied) per constitution i18n structure
- [X] T005 Verify Docker backend available via `docker compose -f docker/docker-compose.yml up -d` and `curl -s http://localhost:8080/health`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T006 Create sealed `Failure` hierarchy extension with `RateLimitedFailure(retryAfter: Duration?)` in `core/lib/domain/failures.dart`
- [X] T007 Create sealed `AsyncState<T>` reuse wrapper if not already present in `core/lib/domain/async_state.dart` (Loading/Data/Error per constitution III)
- [X] T008 [P] Implement `CredentialStorage` abstraction in `core/lib/infrastructure/security/credential_storage.dart`
- [X] T009 [P] Implement mobile `SecureStorageMobile` via `flutter_secure_storage` in `core/lib/infrastructure/security/secure_storage_mobile.dart`
- [X] T010 [P] Implement web `SecureStorageWeb` with httpOnly cookie preference and encrypted localStorage fallback (Web Crypto) in `core/lib/infrastructure/security/secure_storage_web.dart`
- [X] T011 Extend `Dio` singleton with base config in `core/lib/data/network/dio_client.dart` (timeouts, baseUrl from `.env`, certificate validation per implementation-guide §7)
- [X] T012 Implement `ErrorMapper` mapping 400→ValidationFailure, 401→AuthenticationFailure, 403→AuthorizationFailure, 409→ValidationFailure, 429→RateLimitedFailure (parse `Retry-After` seconds or HTTP-date), 5xx→ServerFailure, network→NetworkFailure in `core/lib/data/network/error_mapper.dart`
- [X] T013 Implement `AuthInterceptor` skeleton with JWT injection (read accessToken from storage) and placeholder for single-flight refresh in `core/lib/data/network/auth_interceptor.dart`
- [X] T014 [P] Implement in-memory `SessionCache` for `Session` and `AsyncState<Profile>` with stale flag in `core/lib/data/cache/session_cache.dart`
- [X] T015 Register core auth bindings (storage, dio, cache) in `core/lib/application/injection.dart` via `get_it` (platform-specific registrations remain in `app/lib/main.dart` and `web/lib/main.dart`)
- [X] T016 Configure `Auth` observability helper with structured events (`login_attempt`, `register_validation_failed`, `refresh_succeeded`, `rate_limited`) without logging tokens in `core/lib/infrastructure/observability/auth_logging.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin (storage, network, error abstraction, cache, DI all verifiable via unit test)

---

## Phase 3: User Story 1 — Customer Registration (Priority: P1) 🎯 MVP

**Goal**: Unauthenticated visitor can register with username (3-30 `[a-zA-Z0-9._-]`), email, password (≥8 letter+digit), receive distinct 400/409 errors, and on success be immediately authenticated and routed to catalog (FR-001..FR-004, SC-001).

**Independent Test**: Open customer app unauthenticated, submit registration form with valid/invalid inputs, verify 201 auto-login vs 400 field errors vs 409 already-registered banner without needing catalog/order features (spec US1 Independent Test).

### Tests for User Story 1

- [ ] T017 [P] [US1] Unit test `Username` value object validation (3-30 charset, trim, sanitization, error messages) in `core/test/domain/value_objects/username_test.dart`
- [ ] T018 [P] [US1] Unit test `Email` and `Password` value objects in `core/test/domain/value_objects/email_password_test.dart`
- [ ] T019 [P] [US1] Unit test `Account` and `ValidationFailure` invariants in `core/test/domain/entities/account_test.dart`
- [ ] T020 [P] [US1] Widget test registration form shows loading/disabled submit, field-inline errors, and 409 banner in `app/test/features/auth/registration_screen_test.dart`

### Implementation for User Story 1

- [ ] T021 [P] [US1] Create `Username` value object with `validate()` returning `Either<ValidationFailure,Username>` in `core/lib/domain/value_objects/username.dart`
- [ ] T022 [P] [US1] Create `Email` value object in `core/lib/domain/value_objects/email.dart`
- [ ] T023 [P] [US1] Create `Password` value object (SecretString, ≥8 letter+digit, redacted toString) in `core/lib/domain/value_objects/password.dart`
- [ ] T024 [P] [US1] Create `Account` and `Profile` entities in `core/lib/domain/entities/account.dart` and `core/lib/domain/entities/profile.dart`
- [ ] T025 [US1] Create `AuthRepository` interface declaring `register(username,email,password)` → `Either<Failure,Session>` in `core/lib/domain/repositories/auth_repository.dart`
- [ ] T026 [US1] Generate/wrap OpenAPI client DTOs and implement `AuthRemoteDataSource.register` in `core/lib/data/datasources/auth_remote_datasource.dart`
- [ ] T027 [US1] Implement `AuthRepositoryImpl.register` mapping DTO→entity, validating via value objects pre-call and mapping 400/409 via `ErrorMapper` in `core/lib/data/repositories/auth_repository_impl.dart`
- [ ] T028 [US1] Implement `AuthNotifier` + `AuthState` sealed union covering `initial/authenticating/authenticated/failure` in `core/lib/application/providers/auth_provider.dart`
- [ ] T029 [US1] Create reusable `AuthFormField` widget with token styling and i18n keys in `app/lib/features/auth/presentation/widgets/auth_form_field.dart`
- [ ] T030 [US1] Implement `RegistrationScreen` with username/email/password fields, inline errors, disabled submit + spinner while `authenticating`, success snackbar and 409/400 banners in `app/lib/features/auth/presentation/screens/registration_screen.dart`
- [ ] T031 [US1] Export new auth symbols via `core/lib/core.dart` barrel and verify no internal `src/` import violations

**Checkpoint**: At this point, User Story 1 should be fully functional and independently testable (registration happy path + validation + conflict, auto-login, routing to catalog)

---

## Phase 4: User Story 2 — Customer and Staff Login with Persisted Session (Priority: P1)

**Goal**: Returning users (CUSTOMER/WAREHOUSE/ADMIN) can log in with username-only (not email), stay logged in across restarts, see 401 vs 429 distinct errors with Retry-After countdown, and have expired access tokens silently single-flight refreshed or cleared to login on refresh-401 (FR-005..FR-009, SC-002/SC-003, clarifications Q2/Q4/Q5).

**Independent Test**: Log in as each role, kill/relaunch app (session persists), force access-token expiry and observe silent single-flight renewal for concurrent requests, force refresh-token expiry and observe redirect to login with session-expired banner (spec US2 Independent Test + quickstart §3-§4).

### Tests for User Story 2

- [ ] T032 [P] [US2] Unit test `Role` enum stripping `ROLE_` prefix and landing resolver priority `admin>warehouse>customer` in `core/test/domain/entities/role_test.dart`
- [ ] T033 [P] [US2] Unit test `ErrorMapper` 429 parsing (seconds + HTTP-date, default 60s when missing) in `core/test/data/network/error_mapper_test.dart`
- [ ] T034 [P] [US2] Unit test single-flight refresh guard (3 concurrent 401s → 1 `POST /auth/refresh`, queued retries succeed) in `core/test/data/network/auth_interceptor_test.dart`
- [ ] T035 [P] [US2] Integration test `register→login→persist→force 401→single-flight refresh→success` and `refresh 401→logout` against local backend in `core/test/integration/auth_session_test.dart`

### Implementation for User Story 2

- [ ] T036 [P] [US2] Create `Role` sealed enum with `fromWire(String)` and `canView(RouteId)` helper in `core/lib/domain/entities/role.dart`
- [ ] T037 [US2] Extend `ErrorMapper` to parse `Retry-After` header into `RateLimitedFailure.retryAfter` per research R6 in `core/lib/data/network/error_mapper.dart`
- [ ] T038 [US2] Implement single-flight `AuthInterceptor` queued refresh (Completer guard, retry original via `dio.fetch`, clear on refresh-401, re-auth STOMP) in `core/lib/data/network/auth_interceptor.dart`
- [ ] T039 [US2] Extend `AuthRepository` with `login(username,password)` and `refresh(refreshToken)` in `core/lib/domain/repositories/auth_repository.dart`
- [ ] T040 [US2] Implement `Session` entity with `SecretString` tokens, `expiresIn`, `issuedAt`, derived `roles` set in `core/lib/domain/entities/session.dart`
- [ ] T041 [US2] Implement `AuthNotifier.login`, `tryRestoreSession` (cold-start hydration before router resolves), and `clear OnRefreshFailure` logic in `core/lib/application/providers/auth_provider.dart`
- [ ] T042 [US2] Implement `AuthRealtimeAdapter` that re-connects STOMP with new accessToken after renewal in `core/lib/data/realtime/auth_realtime_adapter.dart`
- [ ] T043 [P] [US2] Create `RateLimitBanner` with live per-second countdown and disabled submit in `app/lib/features/auth/presentation/widgets/rate_limit_banner.dart`
- [ ] T044 [US2] Implement `LoginScreen` labeled "Username" (not email), shows 401 vs 429 (countdown) distinct banners, disabled submit while `authenticating` in `app/lib/features/auth/presentation/screens/login_screen.dart`
- [ ] T045 [US2] Implement web `LoginForm` with rate-limit countdown in `web/lib/components/auth/login_form.dart`
- [ ] T046 [US2] Update `core/lib/data/cache/session_cache.dart` to persist/restore session via `CredentialStorage` and expose `isStale` for profile

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently (registration auto-login persists across restart, silent renewal or logout on expiry)

---

## Phase 5: User Story 3 — Role-Based Access and Route Protection (Priority: P1)

**Goal**: Declarative route guards enforce `CUSTOMER/WAREHOUSE/ADMIN` per PRD 1:1 screen map, hide unauthorized nav items, redirect unauthenticated deep links to login with return-to-original when authorized, land with highest-privilege default (ADMIN→dashboard, else WAREHOUSE→queue, else CUSTOMER→catalog), and show friendly permission-denied instead of crash (FR-012..FR-014, SC-004/SC-005, clarification Q3).

**Independent Test**: Log in as each role, navigate all routes, verify visibility: CUSTOMER only catalog/cart/orders/profile; WAREHOUSE only fulfillment queue; ADMIN all; deep-link without auth redirects to login; unauthorized direct nav shows friendly denial (spec US3 Independent Test + quickstart §5).

### Tests for User Story 3

- [ ] T047 [P] [US3] Unit test `Role.canView` matrix and `LandingResolver` priority per clarification Q3 in `core/test/application/landing_resolver_test.dart`
- [ ] T048 [P] [US3] Widget test `app` nav shell hides admin items for CUSTOMER and hides product create/audit for WAREHOUSE in `app/test/config/router_test.dart`
- [ ] T049 [P] [US3] Component test `UnauthorizedPage` renders friendly denial with back link (not crash) in `web/test/pages/unauthorized_page_test.dart`
- [ ] T050 [P] [US3] Integration test per-role guard journeys (CUSTOMER blocked from `/admin/*`, WAREHOUSE sees queue not audit, ADMIN sees all) in `core/test/integration/rbac_guard_test.dart`

### Implementation for User Story 3

- [ ] T051 [US3] Implement landing resolver utility `resolvePostLoginRoute({requested, roles})` with priority `admin>warehouse>customer` in `core/lib/application/landing_resolver.dart`
- [ ] T052 [US3] Implement `AuthGuard` and `RoleGuard` helpers reading `authProvider` state in `core/lib/application/guards/role_guard.dart`
- [ ] T053 [US3] Wire `go_router` with `AuthGuard`/`RoleGuard` + `?redirect` preservation and landing resolver in `app/lib/config/router.dart`
- [ ] T054 [US3] Wire `jaspr_router` with equivalent guards + ADMIN/WAREHOUSE checks and landing resolver in `web/lib/routes/router.dart`
- [ ] T055 [US3] Create `UnauthorizedPage` shared friendly denial component (token styling, back navigation) in `web/lib/pages/unauthorized_page.dart`
- [ ] T056 [US3] Add `canView` helper consumption to `app` bottom nav shell and `web` sidebar so nav items hide per role in `app/lib/features/auth/application/auth_ui_state.dart` and `web/lib/components/nav/sidebar.dart`
- [ ] T057 [P] [US3] Enforce CUSTOMER own-orders scoping (repository ensures customerId filter is always current user id; admin/warehouse bypass) in `core/lib/data/repositories/order_scoping.dart` (or extension in auth guard layer if orders repo not yet in auth epic)
- [ ] T058 [P] [US3] Integration test CUSTOMER GET /orders returns only own orders and GET /orders/{foreignId} -> 403 AuthorizationFailure in `core/test/integration/rbac_order_scoping_test.dart`

**Checkpoint**: All P1 stories (registration, login+session, RBAC) should now be independently functional; MVP candidate if US4/US5 deferred

---

## Phase 6: User Story 4 — View Profile and Log Out (Priority: P2)

**Goal**: Authenticated user can view profile (id, username, email, roles from `GET /auth/me` with loading/error states) and log out which clears secure storage/cache, closes realtime, and blocks back-navigation without re-login (FR-010/FR-011, SC-007).

**Independent Test**: Log in as each role, open profile/profile page, verify identity display, trigger logout, verify protected routes now redirect to login and relaunch requires login (spec US4 Independent Test).

### Tests for User Story 4

- [ ] T059 [P] [US4] Unit test `Profile` mapping from `/auth/me` `ROLE_` stripping in `core/test/domain/entities/profile_test.dart`
- [ ] T060 [P] [US4] Widget test `ProfileScreen` loading skeleton vs `AsyncState.Error` retry vs `Data` display in `app/test/features/auth/profile_screen_test.dart`
- [ ] T061 [P] [US4] Integration test `login→profile→logout→protected route blocked` journey in `core/test/integration/profile_logout_test.dart`

### Implementation for User Story 4

- [ ] T062 [US4] Extend `AuthRepository` with `fetchProfile()` and `logout()` (clear storage+cache, close WS) in `core/lib/domain/repositories/auth_repository.dart`
- [ ] T063 [US4] Implement `AuthRemoteDataSource.fetchProfile` (`GET /auth/me`) and `logout` cleanup in `core/lib/data/datasources/auth_remote_datasource.dart`
- [ ] T064 [US4] Implement `AuthRepositoryImpl.fetchProfile/logout` with `AsyncState<Profile>` caching in `core/lib/data/repositories/auth_repository_impl.dart`
- [ ] T065 [US4] Add `ProfileNotifier` / extend `AuthNotifier` to expose `AsyncState<Profile>` with fetch+retry in `core/lib/application/providers/profile_provider.dart`
- [ ] T066 [US4] Implement `ProfileScreen` (mobile) showing id/username/email/roles with loading/error states per `AsyncState` in `app/lib/features/auth/presentation/screens/profile_screen.dart`
- [ ] T067 [US4] Implement `ProfilePage` (web) with same states in `web/lib/pages/profile_page.dart`
- [ ] T068 [US4] Ensure logout clears `CredentialStorage` + `SessionCache` + closes STOMP channel and emits `loggedOut` without token leakage in `core/lib/application/providers/auth_provider.dart`

**Checkpoint**: At this point, User Stories 1-4 should all work; profile+logout lifecycle closed

---

## Phase 7: User Story 5 — Authentication Feedback and Recovery (Priority: P2)

**Goal**: Every auth action shows immediate feedback within 200 ms (disabled submit + spinner), distinct success/error banners (network/server/validation/rate-limited) with recovery action, field-level inline errors, and never leaks raw `DioException` to UI (FR-015/FR-016, SC-006, constitution VI).

**Independent Test**: Trigger each auth path (register field errors, 409, login 401/429, network kill mid-login, refresh expiry) and verify spinner within 200 ms, disabled submit blocks double POST, correct banner/inline message, and no raw exception text (spec US5 Independent Test + quickstart §6).

### Tests for User Story 5

- [ ] T069 [P] [US5] Widget test auth forms show disabled submit + spinner within 200 ms in `authenticating`, prevent double submit, and assert error/banner appears within 1 s of 401/429 response in `app/test/features/auth/auth_feedback_test.dart` (use `fakeAsync` or `pump` duration assert)
- [ ] T070 [P] [US5] Widget test failure mapping renders correct friendly messages (network/server/validation/rate-limit/auth) in `app/test/features/auth/error_banner_test.dart`
- [ ] T071 [P] [US5] Component test validation inline messages and submit blocking in `web/test/components/auth/auth_feedback_test.dart`

### Implementation for User Story 5

- [ ] T072 [US5] Harden `ErrorMapper` to ensure zero raw-`DioException` escapes (wrap all parse branches) and centralize `strings.dart` keys per message variant in `core/lib/data/network/error_mapper.dart`
- [ ] T073 [US5] Ensure every auth screen/form consumes `AsyncState`/`RateLimitedFailure` to render disabled submit + spinner within 200 ms and success snackbar vs categorized error banner in `app/lib/features/auth/presentation/screens/*` and `web/lib/components/auth/*`
- [ ] T074 [US5] Add `Semantics(liveRegion:true)` and token-styling error visuals via `AppColors`/`AppSpacing` to all auth banners/fields in `app/lib/features/auth/presentation/widgets/auth_form_field.dart` and `web/lib/components/auth/rate_limit_countdown.dart`

**Checkpoint**: All 5 user stories should now be independently functional with constitution VI feedback guarantees met

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final validation

- [ ] T075 Run `melos run analyze` and `melos run format --set-exit-if-changed` and fix all strict analyzer lints (constitution X)
- [ ] T076 [P] Sanitize inputs at `Username/Email/Password` construction (trim, strip controls, length guard before regex to avoid ReDoS) audit in `core/lib/domain/value_objects/*`
- [ ] T077 [P] Verify certificate validation/pinning toggles on release vs debug (`dio_client.dart` per implementation-guide §7) and that `localhost` docker backend still connects in debug
- [ ] T078 Verify `flutter build apk --obfuscate --split-debug-info=build/symbols` and `jaspr build --release` succeed (constitution VIII)
- [ ] T079 Run `melos run test` and `melos run flutter_test` and ensure `core` coverage ≥75% and all auth unit/widget/integration tests pass
- [ ] T080 Execute `quickstart.md` end-to-end (bootstrap→register→409→persist→401→refresh single-flight→429 countdown→per-role guards→logout→network failure) and capture results in `specs/feature/002-account-and-role-based-access/quickstart-results.md`
- [ ] T081 [P] Remove legacy orphan directory `specs/002-account-and-role-based-access/` after confirming canonical `specs/feature/002-account-and-role-based-access/` is sole source (or keep sync and document canonical path in plan.md:Project Structure)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed) or sequentially in priority order (P1 → P1 → P1 → P2 → P2)
  - Each story is independently testable per its own checkpoint
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1) Registration**: Can start after Foundational - No dependencies on other stories; provides value objects + Account/Profile entities used by later stories
- **User Story 2 (P1) Login+Session**: Can start after Foundational - Depends on US1 entities (`Username/Password` already exist) but independently testable for login/session flows
- **User Story 3 (P1) RBAC Guards**: Can start after Foundational - Depends on `Role` and `Session.roles` from US2 but guard logic is independently testable with mocked session
- **User Story 4 (P2) Profile+Logout**: Can start after Foundational - Uses `Profile` from US1 and `Session` from US2, independent lifecycle test
- **User Story 5 (P2) Feedback**: Can start after Foundational - Cross-cutting but scoped to auth screens; can overlay any prior story's UI

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Value objects/entities before repository interface before data source before notifier before UI
- Core `Either<Failure,T>` returns before presentation mapping
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel (different files)
- Foundational storage/mobile/web implementations (T008-T010) can run in parallel
- Once Foundational completes, User Stories can start in parallel (if team capacity allows)
- All unit/widget tests marked [P] for a story can run in parallel (different files)
- `Username/Email/Password` value objects (T021-T023) can be built in parallel
- Mobile `app/` and web `web/` login/profile screens for the same story can proceed in parallel by different owners after core contracts land

---

## Parallel Example: User Story 1

```bash
# Launch all value-object tests for User Story 1 together:
Task: "Unit test Username value object validation in core/test/domain/value_objects/username_test.dart"  # T017
Task: "Unit test Email and Password value objects in core/test/domain/value_objects/email_password_test.dart"  # T018
Task: "Unit test Account and ValidationFailure invariants in core/test/domain/entities/account_test.dart"  # T019

# Launch all value-object implementations in parallel:
Task: "Create Username value object in core/lib/domain/value_objects/username.dart"  # T021
Task: "Create Email value object in core/lib/domain/value_objects/email.dart"  # T022
Task: "Create Password value object in core/lib/domain/value_objects/password.dart"  # T023
```

## Parallel Example: User Story 2

```bash
# Run refresh discipline tests together before fixing interceptor:
Task: "Unit test single-flight refresh guard in core/test/data/network/auth_interceptor_test.dart"  # T034
Task: "Unit test ErrorMapper 429 parsing in core/test/data/network/error_mapper_test.dart"  # T033
Task: "Integration test register→login→persist→refresh→logout journey in core/test/integration/auth_session_test.dart"  # T035

# Mobile and web login UIs can be built in parallel after core auth core lands:
Task: "Implement LoginScreen in app/lib/features/auth/presentation/screens/login_screen.dart"  # T044
Task: "Implement web LoginForm with rate-limit countdown in web/lib/components/auth/login_form.dart"  # T045
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T005)
2. Complete Phase 2: Foundational (T006-T016) — CRITICAL blocks all stories
3. Complete Phase 3: User Story 1 (T017-T031)
4. **STOP and VALIDATE**: Test registration independently per quickstart §3 (valid 201 auto-login, 400 field errors per 3-30 username rule Q1, 409 already-registered)
5. Deploy/demo if ready — customer acquisition path works without login/session complexity

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready (storage, Dio, Failure mapping, cache, DI)
2. Add User Story 1 → Test independently → Deploy/Demo (MVP! registration+auto-login)
3. Add User Story 2 → Test independently → Deploy/Demo (persisted login, silent single-flight refresh Q5, 429 countdown Q4, username-only Q2)
4. Add User Story 3 → Test independently → Deploy/Demo (highest-privilege landing Q3, union multi-role, guards)
5. Add User Story 4 → Test independently → Deploy/Demo (profile + logout lifecycle closed)
6. Add User Story 5 → Test independently → Deploy/Demo (all feedback within 200 ms, no token leakage SC-007)
7. Each story adds value without breaking previous stories; polish phase gates release

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (storage/network experts pair on Dio+mapper+cache)
2. Once Foundational is done:
   - Developer A: User Story 1 (value objects + registration screen)
   - Developer B: User Story 2 (refresh discipline + login screens)
   - Developer C: User Story 3 (guards + landing resolver + routers)
3. Stories complete and integrate independently; P2 stories (profile/logout, feedback) can be picked up by any freed developer

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability (US1..US5)
- Each user story is independently completable and testable per its Checkpoint
- Verify tests fail before implementing (TDD discipline expected by constitution IX)
- Commit after each task or logical group with Conventional Commits (`feat(auth):`, `fix(auth):`, `test(auth):`)
- Stop at any checkpoint to validate story independently via quickstart scenarios
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- Constitution reminders embedded: domain purity (no Flutter/Jaspr in `core/domain`), export integrity via `core.dart`, `Either<Failure,T>` everywhere, `sealed` states, token secrecy, design-token-only styling, ≥75% core coverage gate, obfuscated release builds, GitHub Flow branch `feature/002-account-and-role-based-access` → PR → `main`
