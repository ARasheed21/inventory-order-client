# Implementation Plan: Project Foundation

**Branch**: `001-project-foundation` | **Date**: 2026-08-25 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-project-foundation/spec.md`

## Summary

Stand up the first development round for the Inventory & Order Management frontends: a
three-package monorepo (shared Dart core, Flutter mobile client, Jaspr web client) with shared
design tokens and navigation shells, contract-driven data plumbing generated from the published
OpenAPI and AsyncAPI contracts (secure credential storage, transparent session renewal, mapped
domain failures, in-memory caching, real-time-as-hint channel), and CI/delivery quality gates.
Every later epic builds on this structure without re-deciding architecture or dependencies.

## Technical Context

**Language/Version**: Dart 3 (null-safe); Flutter stable channel (`app/`), Jaspr current stable (`web/`)
**Primary Dependencies**: Melos (workspace), Riverpod + riverpod_generator (state),
get_it (DI), Dio (HTTP), fpdart `Either` (error handling), go_router (mobile routing),
jaspr_router (web routing), openapi-generator `dart-dio` client generation,
stomp_dart_client (real-time, mobile/raw WS), stompjs + sockjs-client (real-time, web),
flutter_secure_storage (mobile credential storage), Sentry SDK (crash reporting),
build_runner (codegen)
**Storage**: None persisted in this foundation — in-memory session-scoped cache only;
credentials held in platform secure storage (mobile) / httpOnly cookies (web)
**Testing**: `package:test` (core unit), `flutter_test` (widget), `jaspr_test` (web component),
integration journeys against a locally launched backend container; ≥75% enforced coverage on
`core`
**Target Platform**: Android 8.0+ (API 26); latest two versions of Chrome, Firefox, Edge,
Safari
**Project Type**: Monorepo — one shared library + two application packages
**Performance Goals**: Real-time push → refreshed on-screen data within 2s (normal network);
cold start under 3s on target-floor devices/browsers
**Constraints**: Contract-driven only (no ad-hoc endpoints); no persistent offline store;
no usage analytics; English-only strings centralized in core; obfuscated/minified release
builds
**Scale/Scope**: 3 packages, placeholder screens + auth shell, ~15 functional requirements

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. Clean Architecture**: Dependencies point inward; Domain layer is pure Dart (no Flutter/Jaspr imports) — core layered as domain/application/data/infrastructure; domain has zero UI imports
- [x] **II. Monorepo Structure**: Code lands in exactly one of `core/`, `app/`, `web/`; Core accessed only via its public entry point — single `melos` workspace, export-integrity lint gate planned
- [x] **III. State Management**: Reactive, immutable state with standardized loading/error/data states — Riverpod StateNotifier-based MVVM, sealed async state union
- [x] **IV. Data Layer**: Failures mapped to domain `Failure` types; WS pushes treated as hints followed by REST re-fetch — fpdart `Either<Failure, T>` at repository boundary; push handlers trigger re-fetch
- [x] **V. Domain Contracts**: Repository interfaces in Domain, implementations in Data
- [x] **VI. Presentation**: UI renders from state only; route guards per role (CUSTOMER/WAREHOUSE/ADMIN) — Auth/Guest guards in declarative routers; role model established now even though only placeholder screens exist
- [x] **VII. Design Tokens**: No raw color/style constants; shared tokens across clients — tokens defined once in core; web Tailwind config mirrors tokens via CSS variables
- [x] **VIII. Security**: Tokens in secure storage; no raw exceptions to UI — flutter_secure_storage / httpOnly cookies; certificate pinning hook prepared for release builds
- [x] **IX. Testing**: Unit + widget/component + integration journey tests planned — three test layers per PRD testing decisions; local backend container keeps journeys hermetic
- [x] **X. Code Quality**: Null-safe, no `dynamic`, sealed finite states — analyzer strict config in every package
- [x] **XI. Workflow**: Conventional Commits; PR review required — commitlint-style gate in CI

Violations MUST be documented in Complexity Tracking below.

## Project Structure

### Documentation (this feature)

```text
specs/001-project-foundation/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
core/
└── lib/
    ├── core.dart                 # Public API entry point (the ONLY import surface for clients)
    ├── constants/
    │   └── strings.dart          # All user-visible strings (i18n-ready)
    ├── domain/
    │   ├── entities/             # Pure Dart entities & value objects
    │   ├── repositories/         # Repository interfaces
    │   └── failures.dart         # Sealed Failure hierarchy
    ├── application/
    │   ├── providers/            # Riverpod providers (generated)
    │   └── injection.dart        # get_it registration for core services
    ├── data/
    │   ├── repositories/         # Repository implementations
    │   ├── network/              # Generated API client wiring, interceptors, token refresh
    │   ├── cache/                # In-memory session-scoped cache
    │   └── realtime/             # STOMP connection lifecycle, hint dispatch
    ├── design/                   # Design tokens: AppColors, AppSpacing, AppRadius, AppTypography
    └── infrastructure/
        ├── observability/        # Crash reporting + structured logging abstractions
        └── security/             # Credential storage abstraction + release pinning hooks

app/                              # Flutter mobile client
├── lib/
│   ├── features/                 # feature-first organization (auth shell, home placeholder)
│   ├── config/                   # Environment, theme binding, router assembly
│   └── main.dart                 # Platform bootstrap + platform-specific DI
└── test/

web/                              # Jaspr web client
├── lib/
│   ├── components/               # Shared web components
│   ├── pages/                    # Page components (home placeholder, auth)
│   ├── layouts/                  # Layout shells
│   ├── routes/                   # Router + guards
│   └── main.dart                 # Platform bootstrap + platform-specific DI
└── test/

docker/                           # Local backend provisioning
└── docker-compose.yml            # Launches backend built from published contracts

.github/workflows/                # CI: lint → format → test → coverage → build → deploy
melos.yaml                        # Workspace orchestration
analysis_options.yaml             # Strict analyzer baseline (per-package overrides allowed)
.env.example                      # Environment template (real .env files are git-ignored)
```

**Structure Decision**: Three-package monorepo exactly as mandated by Constitution Principle II
and detailed in `docs/implementation-guide.md`. The `core/` layering follows Clean
Architecture (Principle I). Platform packages contain only bootstrap, configuration, and UI —
all logic lives in `core/`. The `docker/` folder exists solely to satisfy FR-017 (local backend
provisioning) without polluting client code.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none) | — | — |
