# Research: Project Foundation

**Branch**: `001-project-foundation` | **Date**: 2026-08-25

This document resolves every technology and pattern decision needed to implement the
foundation. Sources: `docs/constitution.md`, `docs/implementation-guide.md`,
`contracts/api/openapi.yaml`, `contracts/ws/asyncapi-ws.md`, `contracts/prd/frontend-prd.md`.

---

## R1: Workspace Orchestration

- **Decision**: [Melos](https://melos.invertase.dev/) manages the three-package workspace
  (`core/`, `app/`, `web/`) with a single bootstrap command (`melos bootstrap`) and scripted
  tasks (`melos run build`, `melos run test`).
- **Rationale**: Constitution mandates exactly three packages with shared-core dependency
  management; Melos is the de-facto Dart monorepo tool, links path dependencies, and provides
  one-command setup (FR-002, SC-001).
- **Alternatives considered**: Plain pub path dependencies + shell scripts (no filtered task
  fan-out, weaker onboarding); Bazel/Earthly (heavyweight for three Dart packages).

## R2: API Client Generation

- **Decision**: Generate the HTTP client from `contracts/api/openapi.yaml` using
  [openapi-generator](https://openapi-generator.tech/) with the `dart-dio` template, wired into
  core's data layer. Generation runs via build/melos task; generated code is committed so CI
  stays hermetic, regenerated only when the contract version changes.
- **Rationale**: PRD Implementation Decisions: frontends are driven by generated clients from
  the contracts, never by reading backend code. `dart-dio` reuses the already-chosen Dio stack
  (interceptors: JWT injection, 401 refresh, error mapping).
- **Alternatives considered**: Hand-written clients (violates FR-006 drift risk);
  `swagger_dart_code_generator` (freezed-based output less aligned with fpdart Either flow).

## R3: Real-Time Channel

- **Decision**: STOMP over WebSocket per `contracts/ws/asyncapi-ws.md`.
  - Mobile (`app/`): `stomp_dart_client` over raw WebSocket to `ws(s)://<host>/api/ws`
    (SockJS is a browser fallback transport, not required natively).
  - Web (`web/`): `stompjs` + `sockjs-client` behind a thin JS-interop adapter.
  - Shared lifecycle logic (connect-after-auth, Authorization header on CONNECT, subscribe
    `/user/queue/orders` + `/topic/orders/{id}`, backoff reconnect, refresh-on-unauthorized)
    lives in `core/data/realtime/`; platform packages supply only the transport.
  - Pushes dispatch "hint" events; consumers re-fetch authoritative REST data.
- **Rationale**: Contract is authoritative (FR-007); hint-then-refetch matches PRD and
  Constitution Principle IV. Splitting transport from lifecycle keeps domain/application pure.
- **Alternatives considered**: Custom STOMP frame parser (unnecessary maintenance);
  polling/refresh timers (violates real-time requirement).

## R4: Credential Storage & Session Renewal

- **Decision**:
  - Mobile: `flutter_secure_storage` (encrypted keystore/keychain-backed).
  - Web: prefer server-set `httpOnly` Secure cookies for refresh tokens; access token kept in
    memory only. Encrypted localStorage is the fallback if cookies are not feasible.
  - Renewal: Dio interceptor retries once through `POST /auth/refresh` on 401 before surfacing
    an authentication Failure; STOMP reconnect path performs the same refresh (contract:
    token TTL default 900s).
- **Rationale**: FR-009/FR-010 + Constitution Principle VIII; httpOnly cookies neutralize XSS
  token theft on web.
- **Alternatives considered**: Plain localStorage (insecure); always-prompt re-login (breaks
  SC-004 silent renewal).

## R5: State Management & DI Composition

- **Decision**: Riverpod with `riverpod_generator` for state (MVVM-style `StateNotifier`s per
  feature), sealed `AsyncState<T>` union (loading/data/error). `get_it` registers long-lived
  services (API client, cache, realtime, storage) in `core/application/injection.dart`;
  platform `main.dart` files register platform-specific implementations; Riverpod providers
  wrap get_it instances.
- **Rationale**: Matches implementation guide exactly; keeps Constitution Principle III
  (reactive, immutable, standardized async states) with testable seams.
- **Alternatives considered**: Bloc (heavier boilerplate); pure get_it without Riverpod
  (loses reactive UI binding).

## R6: In-Memory Cache Design

- **Decision**: A session-scoped keyed cache in `core/data/cache/`: `Map<ResourceKey,
  CacheEntry>` where entries carry payload + fetchedAt timestamp + staleness flag. No disk
  persistence, no eviction policy needed beyond memory scope. Read-heavy screens read through
  the cache; failed fetches serve stale entries flagged as such (Story 3 scenario 6).
- **Rationale**: Clarification Q4 chose in-memory-only caching for the foundation; persistent
  offline caching is deferred to feature epics. Keeping the abstraction in core lets later
  epics swap in a persistent implementation without UI changes.
- **Alternatives considered**: Drift/SQLite now (rejected: deferred scope); no cache at all
  (violates FR-011).

## R7: Observability

- **Decision**: Sentry SDK integrated at startup in both clients for crash reporting;
  structured logger abstraction in `core/infrastructure/observability/` (levels, key-event
  names) writing to console in dev and forwarding errors to Sentry in release. No usage
  analytics. DSN supplied via environment configuration (FR-014).
- **Rationale**: FR-018 requires crash reporting + structured logging; Sentry covers both
  Android and web targets from one vendor with a free tier.
- **Alternatives considered**: Firebase Crashlytics (no first-class web support); custom
  logging-only solution (fails crash-reporting requirement).

## R8: Local Backend Provisioning

- **Decision**: `docker/docker-compose.yml` launches the backend service built from its image
  (Spring Boot inventory backend matching OpenAPI v0.1.0), exposing REST on :8080 and WS on
  `/api/ws`. A documented command starts/stops it; `.env` points both clients at
  `http://localhost:8080`. Integration tests assume this instance (hermetic, seeded).
- **Rationale**: FR-017 clarification: local container for dev/integration, staging reserved
  for manual verification.
- **Alternatives considered**: Shared staging for tests (flaky, mutating); contract mocks only
  (misses real auth/WS behavior needed by Story 3 scenarios).

## R9: Routing & Guards

- **Decision**: Mobile uses `go_router` (ShellRoute for future bottom nav, AuthGuard +
  GuestGuard); web uses `jaspr_router` with equivalent guard redirects. Guard decisions come
  from the auth state provider; roles (CUSTOMER/WAREHOUSE/ADMIN) are part of the session entity
  from day one even though foundation screens don't differentiate yet.
- **Rationale**: FR-005 + Constitution Principle VI.
- **Alternatives considered**: Navigator 1.x imperative routes (not declarative, harder to
  guard).

## R10: Theming Pipeline

- **Decision**: Tokens defined once in `core/design/`. Flutter consumes them via
  `ThemeData` extensions (`AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`); web mirrors
  them as CSS variables consumed by Tailwind utilities (`jaspr_tailwind`), with `dark:` and
  breakpoint prefixes. A lint rule/convention forbids raw color literals outside token
  definitions (SC-003).
- **Rationale**: FR-004 + Constitution Principle VII (single source of truth, cross-platform
  consistency).
- **Alternatives considered**: Independent theme definitions per client (drift risk, violates
  edge-case rule that core wins conflicts).

## R11: CI/CD & Quality Gates

- **Decision**: GitHub Actions pipeline: analyze → format check → unit tests (coverage gate ≥75%
  on core) → integration job (spins local backend container) → build (obfuscated APK; minified
  web) → deploy web to Firebase Hosting staging + mobile artifact to Firebase App Distribution.
  Conventional-commit message lint on PRs. Secrets injected from GitHub Secrets.
- **Rationale**: FR-012/FR-013, implementation guide §10; matches SC-006/SC-007.
- **Alternatives considered**: Codemagic/bitrise (vendor lock-in, cost); no coverage gate
  (violates constitution).

## R12: Platform Floors

- **Decision**: Android minSdk 26 (Android 8.0); web targets evergreen engines — latest two
  versions of Chrome, Firefox, Edge, Safari (ES modules assumed; no legacy transpilation).
- **Rationale**: Clarification Q1 (Option B).
- **Alternatives considered**: API 24 floor (gains negligible devices, complicates secure
  storage APIs); Chrome-only support (excludes Safari/Firefox users unnecessarily).

## R13: Localization Structure

- **Decision**: All user-visible strings centralized in `core/lib/constants/strings.dart`
  grouped by feature, keyed constants only — no inline string literals in widgets. Structure
  chosen so `.arb` extraction is mechanical when i18n arrives (PRD: English-only for now).
- **Rationale**: FR-015 + implementation guide §9.
- **Alternatives considered**: flutter_localizations now (premature per PRD out-of-scope).
