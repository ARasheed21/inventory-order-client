# Implementation Plan: Account and Role-Based Access

**Branch**: `feature/002-account-and-role-based-access` | **Date**: 2026-09-08 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/feature/002-account-and-role-based-access/spec.md`

## Summary

Deliver the Account and Role-Based Access epic covering PRD onboarding & account stories 1-7 and dashboard Access stories 33-35 via the published OpenAPI auth contract (`/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/me`). Approach: pure-Dart domain/auth entities and value objects in `core/domain`, repository interfaces in domain and implementations in `core/data`, Riverpod `AuthNotifier` holding sealed `AuthState` with standardized loading/error/data, Dio interceptor layer handling single-flight token refresh and error-mapping to `Failure`, platform-secure token storage (`flutter_secure_storage` on mobile, httpOnly cookies with encrypted-localStorage fallback on web), declarative route guards (`go_router` for `app/`, `jaspr_router` for `web/`) enforcing `CUSTOMER/WAREHOUSE/ADMIN` roles with highest-privilege default landing and union-permission multi-role handling. No persistent Drift store is introduced in this feature; session lives in secure storage + in-memory cache per foundation FR-011.

## Technical Context

**Language/Version**: Dart 3 (null-safe); Flutter stable channel (`app/`), Jaspr current stable (`web/`) — per constitution 1.0.0 + implementation-guide §1-2  
**Primary Dependencies**: Melos (workspace), Riverpod + riverpod_generator (reactive state), get_it (DI), Dio + dio interceptors (HTTP, JWT injection, single-flight refresh), fpdart `Either<Failure,T>` (error abstraction), go_router (mobile guards), jaspr_router (web guards), openapi-generator `dart-dio` (contract-driven client), flutter_secure_storage (mobile tokens), Sentry SDK (crash reporting per constitution IX), build_runner (codegen)  
**Storage**: Platform-secure token storage only — `flutter_secure_storage` (Android Keystore), web prefers server-set httpOnly Secure cookies for refresh token with access token in memory; fallback encrypted localStorage if httpOnly infeasible. No Drift/SQLite persisted in this feature; in-memory session-scoped cache (`core/data/cache/`) continues from foundation for read-heavy screens. Tokens never logged.  
**Testing**: `package:test` (core unit, ≥75% enforced coverage on `core`), `flutter_test` + `ProviderContainer` overrides (widget), `jaspr_test` (web component), integration journeys against locally launched backend container (`docker/docker-compose.yml`) for flows register→login→persist→refresh→logout and role-gated navigation; behavior-over-internals assertions  
**Target Platform**: Android 8.0+ (API 26) for `app/`; latest two versions of Chrome, Firefox, Edge, Safari for `web/` (ES modules, no legacy transpilation) — per constitution platform floors  
**Project Type**: Monorepo — one shared library `core/` (domain/application/data/infrastructure) + two application packages `app/` (Flutter mobile-first customer app) + `web/` (Jaspr admin/warehouse dashboard), contract-driven  
**Performance Goals**: Every auth action shows loading within 200 ms and disables duplicate submit (SC-006); session restore on cold start succeeds without credential re-entry when tokens valid (SC-003); silent single-flight refresh retries queued requests transparently (<500 ms added latency on normal network); invalid-credential and rate-limit messages appear within 1 s of response (SC-002); WS reconnect after renewal within 2 s when network healthy  
**Constraints**: Contract-driven only — generated client from `contracts/api/openapi.yaml` + WS contract `contracts/ws/asyncapi-ws.md` (no ad-hoc endpoints); Domain layer pure Dart with zero Flutter/Jaspr imports; export integrity via single `core.dart` entry; tokens never exposed in UI/logs; English-only strings centralized in `core/lib/constants/strings.dart`; obfuscated/minified release builds; offline persistent write-sync out of scope  
**Scale/Scope**: 5 user stories (P1 registration, P1 login+session, P1 RBAC guards, P2 profile+logout, P2 feedback), 18 FRs (FR-001..FR-018 with clarifications 2026-09-08), 4 key entities (Account, Session, Role, Profile) plus Failure/AsyncState reused from foundation, 7 measurable success criteria

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. Clean Architecture**: Dependencies point inward; Domain layer is pure Dart (no Flutter/Jaspr imports) — domain holds `Account`, `Email`, `Username`, `Password` value objects, `Role` enum, `AuthRepository` interface, `Failure` sealed type; `application/` exposes `AuthNotifier`/`AuthState`; `data/` implements repository and network; `presentation` only consumes providers. No domain import of `flutter/*` or `jaspr/*`.
- [x] **II. Monorepo Structure**: Code lands in exactly one of `core/`, `app/`, `web/`; Core accessed only via its public entry point — auth code in `core/domain|application|data|infrastructure`; `app/features/auth/` and `web/pages|routes` import only `package:core/core.dart`. Violations fail analyzer custom lint gate.
- [x] **III. State Management**: Reactive, immutable state with standardized loading/error/data states — `AuthState` sealed union (`initial/authenticating/authenticated/renewing/failure/loggedOut`) immutable with `copyWith`; Riverpod `StateNotifier` drives both clients; async `ProfileState = AsyncState<Profile>` reuses foundation pattern.
- [x] **IV. Data Layer**: Failures mapped to domain `Failure` types; WS pushes treated as hints followed by REST re-fetch — `Either<Failure, Session>` at repository boundary; Dio interceptor maps 400→ValidationFailure, 401→AuthenticationFailure, 409→ValidationFailure, 429→RateLimitedFailure, 5xx→ServerFailure, network→NetworkFailure; WS lifecycle re-authenticates with renewed token then re-subscribes (hint-only).
- [x] **V. Domain Contracts**: Repository interfaces in Domain, implementations in Data — `AuthRepository` declares `register/registerLogin/refresh/fetchProfile/logout`; `AuthRepositoryImpl` in `data/repositories/` delegates to `AuthRemoteDataSource` generated from OpenAPI.
- [x] **VI. Presentation**: UI renders from state only; route guards per role (CUSTOMER/WAREHOUSE/ADMIN) — declarative `go_router` (`app/lib/config/router.dart`) and `jaspr_router` (`web/lib/routes/`) with `AuthGuard`/`RoleGuard` reading `authProvider`; highest-privilege landing (ADMIN→dashboard, else WAREHOUSE→queue, else CUSTOMER→catalog) and union-permission multi-role handling per clarification 2026-09-08.
- [x] **VII. Design Tokens**: No raw color/style constants; shared tokens across clients — auth forms use `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography` from `core/design/`; web Tailwind mirrors tokens; disabled/loading/error visuals token-driven.
- [x] **VIII. Security**: Tokens in secure storage; no raw exceptions to UI; transport secured — mobile `flutter_secure_storage`, web httpOnly cookie fallback encrypted storage; JWT injected via Dio interceptor; transport validation/pinning per implementation-guide §7; input sanitization on username/email/password; release obfuscation retained.
- [x] **IX. Testing**: Unit + widget/component + integration journey tests planned — unit on value objects/role-visibility/single-flight logic; widget tests for loading/success/error/empty/429-countdown/permission-denied; integration for register→login→persist→refresh→logout and per-role navigation, run against local container, ≥75% core coverage gate.
- [x] **X. Code Quality**: Null-safe, no `dynamic`, sealed finite states — analyzer `strict-casts`/`strict-inference`; `AuthState`, `Failure`, `AsyncState` are `sealed` classes; no `dynamic` except Dio unsafe boundary wrapped and mapped immediately.
- [x] **XI. Workflow**: Conventional Commits; PR review required — branch `feature/002-account-and-role-based-access` merges to `main` via PR; commits prefixed `feat(auth):`/`fix(auth):`/`test(auth):`.

Violations MUST be documented in Complexity Tracking below.

## Project Structure

### Documentation (this feature)

```text
specs/feature/002-account-and-role-based-access/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   └── auth.openapi.md  # Auth subset extracted from contracts/api/openapi.yaml
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
core/
└── lib/
    ├── core.dart                 # Public API entry point - re-exports auth domain/application
    ├── constants/
    │   └── strings.dart          # Auth string keys added (registration, login, profile, errors)
    ├── domain/
    │   ├── entities/
    │   │   ├── account.dart      # Account entity (pure Dart)
    │   │   ├── session.dart      # Session entity (tokens as SecretString, expiry, role set)
    │   │   └── profile.dart      # Profile view (id, username, email, roles)
    │   ├── value_objects/
    │   │   ├── username.dart     # 3-30 chars, [a-zA-Z0-9._-], sanitized
    │   │   ├── email.dart        # RFC-5322 simplified validation
    │   │   └── password.dart     # >=8 chars, letter+digit
    │   ├── repositories/
    │   │   └── auth_repository.dart
    │   └── failures.dart         # Sealed Failure + RateLimitedFailure(RetryAfter) extension
    ├── application/
    │   ├── providers/
    │   │   └── auth_provider.dart # Riverpod AuthNotifier + AuthState sealed union
    │   └── injection.dart        # Auth bindings registered (get_it)
    ├── data/
    │   ├── repositories/
    │   │   └── auth_repository_impl.dart
    │   ├── datasources/
    │   │   └── auth_remote_datasource.dart  # Generated client wrapper + DTO mapping
    │   ├── network/
    │   │   ├── dio_client.dart             # Singleton Dio + interceptors
    │   │   ├── auth_interceptor.dart       # JWT injection + single-flight refresh
    │   │   └── error_mapper.dart           # HTTP→Failure mapping + Retry-After parse
    │   ├── cache/
    │   │   └── session_cache.dart          # In-memory profile/session cache (stale flag)
    │   └── realtime/
    │       └── auth_realtime_adapter.dart  # Re-auth CONNECT frame after renewal
    ├── design/                   # Reuses tokens - no new tokens unless auth needs error state color already present
    └── infrastructure/
        ├── security/
        │   ├── credential_storage.dart      # Abstraction
        │   ├── secure_storage_mobile.dart   # flutter_secure_storage impl
        │   └── secure_storage_web.dart      # httpOnly/encrypted localStorage impl
        └── observability/
            └── auth_logging.dart            # Structured auth event logging (no token logging)

app/                              # Flutter mobile (customer auth)
├── lib/
│   ├── features/
│   │   └── auth/
│   │       ├── presentation/
│   │       │   ├── screens/
│   │       │   │   ├── registration_screen.dart
│   │       │   │   ├── login_screen.dart
│   │       │   │   └── profile_screen.dart
│   │       │   └── widgets/
│   │       │       ├── auth_form_field.dart  # Token-driven, i18n-keyed
│   │       │       └── rate_limit_banner.dart
│   │       └── application/
│   │           └── auth_ui_state.dart       # Thin UI state mapping over AuthState
│   └── config/
│       └── router.dart             # go_router with AuthGuard/RoleGuard + landing resolver
└── test/
    └── (unit/widget/integration for auth - mirrors core + app)

web/                              # Jaspr dashboard (admin/warehouse auth)
├── lib/
│   ├── pages/
│   │   ├── login_page.dart
│   │   ├── profile_page.dart
│   │   └── unauthorized_page.dart  # Friendly permission-denied (Constitution VI)
│   ├── components/
│   │   └── auth/
│   │       ├── login_form.dart
│   │       └── rate_limit_countdown.dart
│   └── routes/
│       └── router.dart             # jaspr_router guards + ADMIN/WAREHOUSE checks + landing resolver
└── test/

docker/
└── docker-compose.yml              # Already from foundation - reused for auth integration tests

.github/workflows/
└── ci.yml                         # No new workflow for auth; coverage gate still ≥75% core
melos.yaml                        # No new scripts beyond foundation harness
```

**Structure Decision**: Three-package monorepo per Constitution II and implementation-guide §1. The `core/` layering follows Clean Architecture (§I) with zero client-to-internal-src imports (enforced via `core.dart` export). No Drift introduction in this feature — foundation in-memory cache + secure storage suffices for auth session as Drift was explicitly deferred to feature epics needing offline persistence. Platform `main.dart` files register the storage implementation appropriate to the target, keeping domain/application portable and testable.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none) | — | — |

