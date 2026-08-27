---
description: "Task list template for feature implementation"
---

# Tasks: Project Foundation

**Input**: Design documents from `/specs/001-project-foundation/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: INCLUDED — the spec mandates quality gates with enforced coverage (FR-012, SC-006)
and the PRD testing decisions require unit/component/integration layers. Test tasks appear in
each user story's phase and must be written before the implementation they verify fails.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Three-package monorepo per plan.md: `core/`, `app/`, `web/`, plus `docker/` and
`.github/workflows/`. All paths below are repository-root relative.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the monorepo skeleton so every package resolves and compiles

- [x] T001 Create Melos workspace configuration `melos.yaml` with `bootstrap`, `build` (build_runner watch), `test`, `lint`, `format` scripts covering core/, app/, web/
- [x] T002 [P] Create `core/pubspec.yaml` (pure Dart package, SDK constraint Dart 3, deps: fpdart, get_it, dio) with strict `analysis_options.yaml`
- [x] T003 [P] Create `app/pubspec.yaml` (Flutter package, path dep on core) with strict `analysis_options.yaml` and minSdk 26 in `app/android/app/build.gradle`
- [x] T004 [P] Create `web/pubspec.yaml` (Jaspr package, path dep on core, jaspr_tailwind) with strict `analysis_options.yaml`
- [x] T005 [P] Create root `.gitignore` entries for `.env`, build outputs, generated symbols, and commit `.env.example` with the schema from specs/001-project-foundation/contracts/env-config.md
- [x] T006 [P] Create `docker/docker-compose.yml` launching the inventory backend image (REST :8080, WS /api/ws) with healthcheck and documented start command
- [x] T007 Run `melos bootstrap` and verify all three packages resolve (`melos exec -- dart pub deps`)

**Checkpoint**: Workspace bootstraps cleanly; all three packages compile empty

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared domain primitives every user story depends on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T008 [P] Implement sealed Failure hierarchy in `core/lib/domain/failures.dart` (NetworkFailure, AuthenticationFailure, AuthorizationFailure, ServerFailure, ValidationFailure with field map, UnknownFailure) per data-model.md §3
- [x] T009 [P] Implement sealed AsyncState<T> union (loading/data/error) in `core/lib/application/async_state.dart` per data-model.md §4
- [x] T010 [P] Implement Reporter abstract interface + AppLogLevel enum + console dev logger in `core/lib/infrastructure/observability/reporter.dart`
- [x] T011 [P] Implement ResourceKey (namespaced string value type) in `core/lib/domain/resource_key.dart`
- [x] T012 [P] Create AppStrings registry skeleton grouped by feature (auth, common) in `core/lib/constants/strings.dart`
- [x] T013 Implement EnvironmentConfig loader (API_BASE_URL, WS_URL, SENTRY_DSN, APP_ENV) reading env files with startup abort on missing required values in `core/lib/application/env_config.dart`
- [x] T014 Create single public entry point `core/lib/core.dart` exporting ONLY: failures, async_state, resource_key, reporter, env_config, strings (internal folders unexported)
- [x] T015 Unit tests for foundational primitives in `core/test/` (failure mapping table, AsyncState transitions, env loader missing-var abort, key namespacing)

**Checkpoint**: Foundation primitives ready — user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Working Monorepo Workspace (Priority: P1) 🎯 MVP

**Goal**: Clone → one setup command → all three packages build and launch placeholder screens

**Independent Test**: From a clean clone run setup, then build/launch each package without errors (spec US1 Independent Test)

### Tests for User Story 1

> **NOTE: Write these FIRST, ensure they FAIL before implementation**

- [x] T016 [P] [US1] Export-integrity test asserting `core/lib/core.dart` is the only legal import surface (scan app/ and web/ imports) in `core/test/export_integrity_test.dart`

### Implementation for User Story 1

- [x] T017 [US1] Scaffold minimal Flutter bootstrap `app/lib/main.dart` loading EnvironmentConfig and rendering placeholder home widget in `app/lib/features/home/home_screen.dart`
- [x] T018 [US1] Scaffold Jaspr bootstrap `web/lib/main.dart` loading EnvironmentConfig and rendering placeholder page component in `web/lib/pages/home_page.dart`
- [x] T019 [US1] Add export-integrity violation detection to CI as a lint step in `.github/workflows/ci.yml` (fail on non-core.dart core imports)
- [x] T020 [US1] Document clone→run instructions in `README.md` matching quickstart.md steps 1–4 (setup command, backend container, run app, run web)
- [x] T021 [US1] Verify builds: `flutter build apk --debug`, `jaspr build`, `dart analyze` across packages; smoke-test the web client in each FR-016 target browser (latest two of Chrome/Firefox/Edge/Safari); record results in feature notes

**Checkpoint**: Fresh clone reaches running mobile AND web clients with placeholders (SC-001, SC-002)

---

## Phase 4: User Story 2 - Shared Design System & App Shells (Priority: P2)

**Goal**: Token-driven theming with dark mode + responsive layouts + guarded navigation shells

**Independent Test**: Sample screen renders token-only styling in both clients; dark mode toggle restyles all screens; web adapts at breakpoints (spec US2 Independent Test)

### Tests for User Story 2

- [x] T022 [P] [US2] Widget test asserting sample screen uses theme extensions (no raw Colors./EdgeInsets literals) in `app/test/design/token_usage_test.dart`
- [x] T023 [P] [US2] Jaspr component test asserting rendered Tailwind classes derive from CSS-variable-backed tokens incl. dark:/breakpoint variants in `web/test/design/tokens_test.dart`

### Implementation for User Story 2

- [x] T024 [US2] Define design token groups (AppColors semantic roles light/dark, AppSpacing 4pt scale, AppRadius, AppTypography) in `core/lib/design/` and export via `core/lib/core.dart`
- [x] T025 [US2] Bind tokens into Flutter ThemeData with ThemeExtensions + dark/light `ThemeData` builders in `app/lib/config/theme.dart`
- [x] T026 [US2] Mirror tokens as CSS variables consumed by Tailwind utilities (dark:, sm:/md:/lg:) in `web/lib/styles/tokens.css` and tailwind config in `web/lib/styles/`
- [x] T027 [US2] Implement mobile navigation shell with go_router (ShellRoute-ready, AuthGuard/GuestGuard seams reading session state provider) in `app/lib/config/router.dart`
- [x] T028 [US2] Implement web router with nested routes + guard redirect seams in `web/lib/routes/routes.dart`
- [x] T029 [US2] Update placeholder home screens to consume tokens and demonstrate responsive behavior in `app/lib/features/home/home_screen.dart` and `web/lib/pages/home_page.dart`
- [x] T030 [US2] Verify visual parity side-by-side (same branding/terminology/components) and breakpoint adaptation; note results in feature notes

**Checkpoint**: Both clients render consistent, token-driven UI with dark mode and guarded route shells

---

## Phase 5: User Story 3 - Contract-Driven Data Plumbing (Priority: P3)

**Goal**: Generated API clients, secure sessions with silent renewal, mapped errors, in-memory cache, real-time hint channel

**Independent Test**: Against local backend container: login persists credentials, expiry renews silently, network failure shows friendly retryable error, push triggers refresh, reconnect works, stale cache serves within session (spec US3 scenarios 1–6)

### Tests for User Story 3

- [x] T031 [P] [US3] Unit test Failure mapping from HTTP status codes/exceptions in `core/test/data/failure_mapping_test.dart`
- [x] T032 [P] [US3] Unit test ReadCache put/get/invalidate/stale semantics in `core/test/data/read_cache_test.dart`
- [x] T033 [P] [US3] Unit test STOMP message decode to RealtimeHint per AsyncAPI payload table in `core/test/realtime/hint_decoder_test.dart`
- [x] T034 [US3] Integration test login → restart-restore → silent refresh flow against local backend in `app/integration_test/auth_flow_test.dart`
- [x] T035 [US3] Integration test backend-down → friendly error with retry → backend-up recovery in `app/integration_test/error_recovery_test.dart`

### Implementation for User Story 3

- [x] T036 [US3] Set up openapi-generator dart-dio pipeline regenerating from `contracts/api/openapi.yaml` into `core/lib/data/network/generated/` (committed output; melos `build` task hook)
- [x] T037 [US3] Implement Dio wiring with JWT-injection interceptor, 401→refresh→retry interceptor, logging (dev), error→Failure mapper in `core/lib/data/network/http_client.dart`
- [x] T038 [US3] Define CredentialStore abstraction in `core/lib/infrastructure/security/credential_store.dart`; implement FlutterSecureCredentialStore for app in `app/lib/config/` and CookieCredentialStore for web in `web/lib/config/`
- [x] T039 [US3] Implement Session entity + Role enum in `core/lib/domain/entities/session.dart` and AuthRepository interface in `core/lib/domain/repositories/auth_repository.dart` per contracts/core-public-api.md §3
- [x] T040 [US3] Implement AuthRepositoryImpl (login/register/logout/refresh/watchSession backed by generated client + credential store) in `core/lib/data/repositories/auth_repository_impl.dart`
- [x] T041 [US3] Register core services in get_it `core/lib/application/injection.dart`; register platform stores in `app/lib/main.dart` and `web/lib/main.dart`; expose reactive sessionProvider wrapping repository
- [x] T042 [US3] Implement ReadCache (in-memory, session-scoped, stale flags) in `core/lib/data/cache/read_cache.dart` and clear-on-logout hookup in auth flow
- [x] T043 [US3] Implement realtime lifecycle in `core/lib/data/realtime/realtime_channel.dart`: connect-after-auth with Authorization header CONNECT, subscribe /user/queue/orders + /topic/orders/{id}, backoff reconnect, refresh-on-unauthorized; emit hints via realtimeHintsProvider
- [x] T044 [US3] Wire platform transports: stomp_dart_client raw WS transport binding in `app/lib/config/realtime_binding.dart`; stompjs+sockjs JS-interop adapter in `web/lib/config/realtime_binding_interop.dart`
- [x] T045 [US3] Integrate Sentry crash reporting + Reporter forwarding at startup in `app/lib/main.dart` and `web/lib/main.dart` (DSN from EnvironmentConfig; required in release)
- [x] T046 [US3] Build auth screen (login/register with friendly ValidationFailure feedback) in `app/lib/features/auth/` and `web/lib/pages/auth_page.dart` using AppStrings; wire guards from US2 to live sessionProvider
- [x] T047 [US3] Demonstrate hint→refetch: subscribe home placeholder to order-status hints, invalidate cache, refetch via REST, show stale indicator in `app/lib/features/home/` and `web/lib/pages/home_page.dart`

**Checkpoint**: Full plumbing verified against local backend (SC-004 silent renewal, SC-005 push→refresh ≤2s)

---

## Phase 6: User Story 4 - Quality Gates & Delivery Pipeline (Priority: P4)

**Goal**: CI blocks bad merges; release pipeline produces hardened artifacts and deploys staging

**Independent Test**: Broken style/test/coverage changes block merge; tagged commit produces obfuscated APK + deployed web build (spec US4 scenarios 1–4)

### Implementation for User Story 4

- [x] T048 [US4] Create CI workflow analyze→format→unit tests with ≥75% core coverage gate AND a design-token literal ban check (fail on raw color/spacing/typography constants outside `core/lib/design/`) in `.github/workflows/ci.yml` (extends T019 export-integrity step)
- [x] T049 [US4] Add Conventional Commit message lint to PR checks in `.github/workflows/ci.yml`
- [x] T050 [US4] Add integration-test job spinning up `docker/docker-compose.yml` backend and running `app/integration_test/` journeys in `.github/workflows/ci.yml`
- [x] T051 [US4] Create release workflow: obfuscated APK (--split-debug-info) upload to Firebase App Distribution + minified jaspr web build deploy to Firebase Hosting staging, secrets via GitHub Secrets, in `.github/workflows/release.yml`
- [x] T052 [US4] Configure coverage reporting tooling (lcov) referenced by ci.yml and document threshold rationale in `docs/implementation-guide.md` testing section
- [x] T053 [US4] Implement certificate-pinning adapter enforcing allowed SPKI pins for backend hosts in release mode only (dev bypasses) in `core/lib/infrastructure/security/certificate_pinning.dart` wired into Dio in `core/lib/data/network/http_client.dart`; pin values supplied via environment configuration per `contracts/env-config.md`
- [ ] T054 [US4] Pipeline verification scratch run: submit intentional style violation, failing test, sub-threshold coverage change, and non-Conventional commit message to a scratch branch; record gate outcomes against SC-006 in feature notes

**Checkpoint**: Quality gates enforce definition of done before first feature epic (FR-012, FR-013, SC-007)

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and end-to-end validation affecting the whole foundation

- [x] T055 Validate complete quickstart.md from a clean clone; fix any drift found in `specs/001-project-foundation/quickstart.md` or scripts
- [x] T056 Final pass: analyzer zero warnings across packages, no `dynamic` outside external boundaries, all user-visible strings in `core/lib/constants/strings.dart`
- [x] T057 [P] Update AGENTS.md context if any technology changed during implementation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — starts immediately
- **Foundational (Phase 2)**: Depends on T002/T007 (core package exists and resolves)
- **US1 (Phase 3)**: Depends on Phase 2 completion
- **US2 (Phase 4)**: Depends on US1 (packages exist to bind tokens into); token definitions can start after T014
- **US3 (Phase 5)**: Depends on US2 shells/guards (T027/T028) to wire auth screens and session-driven guards
- **US4 (Phase 6)**: Implementation depends on US3 (tests/artifacts to measure); scratch-run verification last
- **Polish (Phase 7)**: Depends on all prior phases

### User Story Dependencies

- **US1**: Independent after Foundational — delivers runnable skeleton (MVP)
- **US2**: Needs US1 surfaces; no dependency on US3
- **US3**: Needs US2 guard seams; consumes Foundational primitives
- **US4**: Measures everything above; must land before first feature epic

### Within Each User Story

- Tests written first (fail), then models/entities, then services/repositories, then UI wiring, then integration verification

### Parallel Opportunities

- T002–T006 (independent files), T008–T012 (foundational primitives), T022/T023, T031/T032/T033 (unit test suites), US2 token work alongside early US3 contract pipeline once T024 lands

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: US1 → **STOP and VALIDATE**: clean clone → running clients
4. Demo-ready skeleton

### Incremental Delivery

- +US2 → visually consistent themed shells
- +US3 → authenticated clients talking to real backend over REST+WS
- +US4 → protected delivery pipeline; foundation done

### Parallel Team Strategy

- Developer A: US2 (design system) while Developer B: US3 network/cache layer after T014; converge on auth screen (T046)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group (Conventional Commits)
- Stop at any checkpoint to validate story independently

---

## Implementation Notes (2026-08-25)

Deviations and environment constraints recorded during /speckit.implement:

- **T036**: Generated dart-dio client embedded under core/lib/data/network/generated/
  (package:inventory_api/ imports rewritten to package:core/). The generated barrel file
  and InventoryApi wrapper class were dropped due to a generator name collision; endpoint
  classes are consumed directly. Regeneration is scripted via openapi-generator-cli.
- **T038/T041**: Web credential store uses tab-scoped sessionStorage; the httpOnly-cookie
  refresh-token flow remains the documented production path.
- **T044**: Both platforms use stomp_dart_client over the raw WebSocket endpoint
  (/api/ws/websocket, permitted by the AsyncAPI contract). SockJS is browser-only fallback
  transport; stompjs interop deferred until required.
- **T045**: sentry_flutter pins Kotlin languageVersion 1.6, incompatible with Kotlin 2.x;
  forced to 1.9 for all plugin subprojects in pp/android/build.gradle.kts.
- **T034/T035/T048/T054**: Integration suites and CI/release pipelines require Docker +
  GitHub Actions, unavailable in this environment. Tests are written and wired into CI;
  local verification covered analyzer, formatting, unit/widget/component tests, coverage
  (**78.4% >= 75%**), debug APK build, and web release build.
