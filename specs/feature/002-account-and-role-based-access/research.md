# Research: Account and Role-Based Access

**Branch**: `feature/002-account-and-role-based-access` | **Date**: 2026-09-08
**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

This document resolves every technical unknown for the Account/RBAC epic against `docs/constitution.md` (v1.0.0), `docs/implementation-guide.md`, `contracts/api/openapi.yaml` (v0.1.0), `contracts/ws/asyncapi-ws.md`, and `contracts/prd/frontend-prd.md`. All decisions are made within the three-package monorepo constraint — no persistent offline store is introduced in this feature.

---

## R1: Username / Email / Password Value Objects & Sanitization

- **Decision**: Introduce three pure-Dart value objects in `core/lib/domain/value_objects/` — `Username`, `Email`, `Password` — each exposing `Either<ValidationFailure, T>` via `validate()`. `Username` enforces clarified rule: 3-30 chars, alphabet `[a-zA-Z0-9._-]` only, trimmed, no spaces/controls, validated both on-field-change and pre-submit; `Email` uses RFC-5322 simplified pattern + `email_validator` equivalent logic already available via Dart core patterns (no extra dependency); `Password` enforces ≥8 chars with at least one letter and one digit (contract rule), checked locally before any network call and re-validated server-side 400 mapping. All raw inputs are trimmed and sanitized (strip controls, prevent injection per constitution VIII) at value-object construction.
- **Rationale**: FR-002 + clarification 2026-09-08 Q1; domain purity (constitution V) requires validation in domain, not presentation. Prevents unnecessary 400 round-trips and satisfies SC-006 field-level feedback.
- **Alternatives considered**: Validation only in presentation validators (duplicated, not testable as domain); regex-only in data layer (leaks UX requirement downstream); external validator library (adds dependency for trivial rules).

## R2: Contract-Driven Auth Client

- **Decision**: Reuse foundation R2: `openapi-generator` `dart-dio` client from `contracts/api/openapi.yaml` wired in `core/data/datasources/auth_remote_datasource.dart`. Use generated `RegisterRequest`, `LoginRequest`, `RefreshRequest` DTOs verbatim; no hand-written endpoint paths. DTO→entity mapping lives in the data layer; validation errors (400) decode `ApiError` into `ValidationFailure(fieldMessages: Map<String,String>)`.
- **Rationale**: Implementation Decisions (PRD): frontends are driven by generated clients, never backend source reading; constitution Contract & Platform Constraints forbids ad-hoc endpoints. Guarantees 409 conflict and 429 handling match server contract exactly.
- **Alternatives considered**: Hand-written Dio calls (violates FR-006 drift risk); `swagger_dart_code_generator` (generated Freezed models duplicate fpdart Either flow).

## R3: Token Storage Per Platform

- **Decision**:
  - Mobile (`app/`): `flutter_secure_storage` (already in guide §7) for `accessToken`, `refreshToken`, and `expiresIn` hint. `EncryptedSharedPreferences` on Android API 26+. Tokens created on register/login/refresh, deleted on logout/refresh-401.
  - Web (`web/`): Prefer server-set `httpOnly` Secure SameSite=Strict cookies for refresh token (requires backend `Set-Cookie`; no JS read). Access token kept only in memory (`core/data/cache/session_cache.dart`). Fallback when httpOnly infeasible: Web Crypto API (via `dart:js_interop`) encrypted localStorage entry using AES-GCM with a per-install random key stored in IndexedDB — still not JS-readable by XSS without key exfiltration. Tokens never logged or rendered (SC-007).
- **Rationale**: Constitution VIII (encrypted where possible) + spec Assumption/FR-017 + foundation R4. httpOnly neutralizes XSS theft; in-memory access token limits exposure window.
- **Alternatives considered**: Plain localStorage on both platforms (insecure, violates SC-007); shared_preferences on mobile (unencrypted); always-encrypted-localStorage on web without httpOnly attempt (adds crypto overhead and key-management complexity prematurely).

## R4: Single-Flight Token Refresh & Automatic Retry

- **Decision**: Dio interceptor `AuthInterceptor` implements QueuedInterceptor pattern: on 401, acquire a `Completer<Session>` single-flight guard; first 401 triggers `POST /auth/refresh` with stored refresh token; concurrent 401s await the same future. On success: update storage, rewrite `Authorization` header, retry original request via `dio.fetch()`, re-authenticate STOMP CONNECT frame. On 401 from refresh itself: clear storage, emit `AuthState.loggedOut(reason: sessionExpired)`, cancel queued retries, redirect to login with banner. `Retry-After` on 429 is surfaced as `RateLimitedFailure(retryAfter: Duration?)`.
- **Rationale**: FR-008/FR-009 + clarification 2026-09-08 Q5 (single-flight queued retry) prevents thundering refresh and token race; matches foundation R4 renewal pattern (Dio retry once). Avoids multiple refresh token uses that server might treat as replay.
- **Alternatives considered**: Each 401 independently refreshes (thundering, last-write wins, possible server revocation); fail-fast without queue (breaks SC-003 transparent renewal promise).

## R5: Declarative RBAC Guards & Landing Resolution

- **Decision**: Auth state carries `Set<Role> roles` decoded from `/auth/me` (`ROLE_` prefix stripped, upper-cased to `Role` enum). Guards:
  - `AuthGuard`: unauthenticated → `/login?redirect=<original>` (preserves deep link for return when role permits per FR-012).
  - `RoleGuard(routeRoles)` checks `session.roles ∩ routeRoles ≠ ∅`; CUSTOMER sees only customer routes (`/catalog`, `/cart`, `/orders`, `/profile`); WAREHOUSE sees fulfillment queue routes (`/fulfillment` etc.); ADMIN sees union (everything). Unauthorized direct navigation renders `UnauthorizedPage` (friendly denial, not crash, per constitution VI). Hidden nav items via `role.canView(routeId)` helper consumed by both `app` nav shell and `web` sidebar.
  - Post-login landing resolver: if `?redirect` present and authorized → go there; else highest-privilege default per clarification Q3: `if ADMIN→/admin/dashboard else if WAREHOUSE→/fulfillment else→/catalog`. Union-permission for multi-role (ADMIN+WAREHOUSE gets admin default but can navigate to queue freely).
- **Rationale**: FR-012/FR-013/FR-014 + constitution VI (declarative routing, route guards per role) + PRD "Roles map 1:1 to screens" + clarification Q3 multi-role.
- **Alternatives considered**: Imperative `Navigator.push` guards (non-declarative, violates principle VI); server-side redirect (requires backend screen awareness); chooser screen for multi-role (extra friction, rejected for MVP per Q3).

## R6: Rate-Limit Feedback with Retry-After Countdown

- **Decision**: `error_mapper.dart` parses 429: reads `Retry-After` header (seconds or HTTP-date) into `Duration`; if absent, defaults to 60 s generic window per clarification Q4. UI consumes `RateLimitedFailure(retryAfter)` to render `RateLimitBanner` with live countdown (updates per second via `Stream.periodic`) and disables submit until elapsed. Uses design-token timing/colors; banner accessible via `Semantics(liveRegion: true)`.
- **Rationale**: FR-006 + clarification Q4 (respect Retry-After with countdown). Prevents hammering locked endpoint and satisfies SC-002 within-1 s error appearance + SC-006 disabled submit.
- **Alternatives considered**: Generic static message (fails Q4 requirement); fixed 5/15 min countdown regardless of header (ignores server control, violates contract window hint).

## R7: State Shape & Error Abstraction

- **Decision**: `AuthState` sealed union: `initial`, `unauthenticated`, `authenticating`, `authenticated(Session)`, `renewing(Session)`, `failure(Failure)`, `rateLimited(RetryAfter)`, `loggedOut(Reason)` — immutable, `@immutable` with `copyWith`. `AsyncState<Profile>` for profile fetch. Repository returns `Either<Failure,T>` with variants: `NetworkFailure`, `AuthenticationFailure`, `AuthorizationFailure`, `ValidationFailure(fieldMessages)`, `RateLimitedFailure(retryAfter)`, `ServerFailure`, `UnknownFailure`. No raw `DioException` escapes to presentation. `AuthNotifier` extends `StateNotifier<AuthState>` (Riverpod) per guide §2.
- **Rationale**: Constitution III (reactive immutable, standardized loading/error/data), IV (error abstraction as sealed type), V (pure domain), X (finite states as sealed).
- **Alternatives considered**: `freezed` union only (already implied but sealed Dart 3 suffices); `Result` class (violates fpdart Either convention in guide).

## R8: Session Cache & WS Re-Authentication

- **Decision**: `SessionCache` in-memory map (`Session`, `Profile`) plus STOMP adapter. Flow: intercept → refresh → update storage/cache → emit `AuthState.authenticated(newSession)` → `auth_realtime_adapter` triggers `disconnect()+connect( newAccessToken )` with `Authorization` header in CONNECT frame → re-subscribe `/user/queue/orders` + product topics. Pushes remain hints (no payload rendered directly); consumers re-fetch REST. Cache cleared on logout, marked stale on reconnect failure for UI staleness indicator.
- **Rationale**: Constitution IV (real-time as hint, reconnect with backoff + token refresh) + FR-018 + foundation R3/R6. Keeps offline-resilience for read-heavy screens without introducing Drift persistence yet.
- **Alternatives considered**: Persistent cache now (rejected: Drift deferred per guide §3 until feature epic needs offline writes); no WS re-auth (breaks FR-018 and leaves channel unauthenticated).

## R9: Testing Strategy for Auth/RBAC

- **Decision**:
  - Unit: value-object validation (Username 3-30 rules, Email, Password), `Role.canView`, `Failure` mapping table (400/401/409/429/5xx + Retry-After parsing), single-flight refresh guard (verify only one HTTP call for 3 concurrent 401s), landing resolver priority table.
  - Widget/Component: loading skeleton vs disabled submit, field-level inline errors, 409 already-registered banner, 429 countdown banner, unauthorized page, per-role nav visibility (mocked `ProviderContainer` overrides on mobile, `jaspr_test` class checks on web) — all four states: loading/success/error/empty.
  - Integration: journeys `register→auto-login→/me→persist across restart→refresh on 401→logout` and per-role guard journeys (`CUSTOMER` blocked from `/admin/*`, `WAREHOUSE` sees queue not audit, `ADMIN` sees all) against `docker-compose` backend. Coverage ≥75% on `core` enforced; integration asserted via `Either` behavior not widget internals per PRD testing decisions.
- **Rationale**: Constitution IX + spec Testing Mandates + PRD implementation decisions (tests verify user-visible behavior).
- **Alternatives considered**: End-to-end only (slow, flaky); golden-only screenshots (misses logic coverage).

## R10: Security Hardening In Scope

- **Decision**: Input sanitization at `Username/Email/Password` construction (trim, strip control chars, limit length before regex to avoid ReDoS); transport enforces TLS validation (certificate pinning toggled on release per guide §7 snippet toggling `kReleaseMode`); obfuscation via `flutter build apk --obfuscate --split-debug-info` and `jaspr build --release` (constitution VIII); structured auth logging (`login_attempt`, `register_validation_failed`, `refresh_succeeded`, `rate_limited`) without token payloads; no credential analytics.
- **Rationale**: Constitution VIII + §11 development workflow; prevents injection and token leakage (SC-007).
- **Alternatives considered**: Client-side certificate pinning in debug (breaks local docker backend on `localhost`); verbose token logging (violates SC-007).

## R11: Platform Floors & Build Verification

- **Decision**: Re-affirm foundation R12: `minSdk 26`, evergreen web (last-two). CI gate remains `analyze → format → test(cover ≥75%) → integration(docker) → obfuscated build`; auth adds no new CI jobs, but coverage gate must include new `core/auth` code.
- **Rationale**: Constitution §6 Platform Constraints / §11 Development Workflow.
- **Alternatives considered**: Raising minSdk (no auth requirement); adding Codemagic (vendor lock-in).

---

All NEEDS CLARIFICATION items from Technical Context are resolved above; no unresolved unknowns block Phase 1. The choices above introduce zero constitution violations.
