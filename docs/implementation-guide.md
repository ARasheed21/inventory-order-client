
---

# Implementation Guide & Technical Blueprint

## Overview
This guide provides the specific libraries, folder structures, and code patterns used to fulfill the Project Constitution. **This document is mutable**—update it when you swap dependencies or restructure modules.

---

## 1. Monorepo & Folder Structure (Specifics)
- **Tool**: [`Melos`](https://melos.invertase.dev/) manages the workspace.
- **Packages**:
  - `core/` - Shared logic.
  - `app/` - Flutter mobile application.
  - `web/` - Jaspr web application.
- **`core` Package Layout**:
  ```
  lib/
  ├── core.dart (Public API export)
  ├── domain/
  │   ├── entities/
  │   └── repositories/ (Interfaces)
  ├── application/
  │   └── providers/ (Riverpod providers)
  ├── data/
  │   ├── repositories/ (Implementations)
  │   ├── network/ (API clients, DTOs)
  │   └── datasources/
  └── infrastructure/
      ├── database/ (Drift files)
      └── websocket/
  ```
- **`app` Package Layout**: `lib/features/` (feature-first), `lib/config/`, `main.dart`.
- **`web` Package Layout**: `lib/components/`, `lib/pages/`, `lib/layouts/`, `lib/routes/`, `main.dart`.

---

## 2. State Management (Tools)
- **Library**: [`Riverpod`](https://riverpod.dev/) with `riverpod_generator` for code-generation.
- **Provider Types**: Use `Provider` (static), `FutureProvider`, `StreamProvider`, and `StateNotifierProvider`.
- **UI Consumption**: Use `ref.watch` for data, `ref.listen` for side-effects, and `ref.read` for callbacks.
- **MVVM Pattern**: Use `StateNotifier` classes to encapsulate business logic for a specific feature.

---

## 3. Data Layer (Tools & Patterns)
- **HTTP Client**: [`Dio`](https://pub.dev/packages/dio).
  - *Interceptors*: JWT injection, automatic 401 token refresh, logging (dev), error mapping.
- **Local Database (DEFERRED)**: [`Drift`](https://drift.simonbinder.eu/) (SQLite) is the
  designated persistence tool for feature epics that need an offline store. The foundation
  itself ships with **in-memory, session-scoped caching only** (`core/data/cache/`) — see
  spec 001-project-foundation FR-011. Do not introduce Drift until a feature epic requires
  persistent offline data.
  - When introduced: use stream queries for reactive UI, transactions for atomic writes,
    and mirror backend entities with appropriate indexes.
- **Result Handling**: Use [`fpdart`](https://pub.dev/packages/fpdart) `Either<Failure, T>` for repository returns.
- **Real-Time**: STOMP over WebSocket. Connect after Auth, subscribe to `/user/queue/orders`
  and `/topic/orders/{orderId}`. Mobile: `stomp_dart_client` over raw WebSocket; web:
  `stompjs` + `sockjs-client`. Shared lifecycle in `core/data/realtime/`; pushes are hints —
  re-fetch authoritative data over REST after each push.

---

## 4. Routing (Specifics)
- **Flutter**: [`go_router`](https://pub.dev/packages/go_router) with `ShellRoute` for bottom nav, `AuthGuard`, and `GuestGuard`.
- **Web (Jaspr)**: [`jaspr_router`](https://pub.dev/packages/jaspr_router) with nested routes and guard redirects.

---

## 5. Theming & Styling (Specifics)
- **Flutter**: `ThemeData` with custom extensions. Use predefined `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography` from `core`. Never use raw `Colors.` constants.
- **Web (Jaspr)**: [`jaspr_tailwind`](https://pub.dev/packages/jaspr_tailwind). Use utility classes only.
  - Responsive: `sm:`, `md:`, `lg:` prefixes.
  - Dark mode: `dark:` prefix.
  - Tailwind config mirrors `AppSpacing` and `AppColors` via CSS variables.

---

## 6. Dependency Injection (Tools)
- **Library**: [`get_it`](https://pub.dev/packages/get_it) for service singletons (Clients, DB, Repos).
- **Registration**: Core services registered in `core/application/injection.dart`. Platform-specific services registered in respective `main.dart` files.
- **Riverpod Wrappers**: Riverpod providers wrap `get_it` instances or use `Provider` for pure dependencies.

---

## 7. Security Implementation (Specifics)
- **Token Storage**: 
  - Flutter: [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage).
  - Web: `httpOnly` secure cookies (preferred) or encrypted localStorage.
- **Certificate Pinning (Dio)**:
  ```dart
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) {
        if (kReleaseMode) {
          final pin = sha256.convert(cert.der).toString();
          return allowedPins.contains(pin);
        }
        return true;
      };
      return client;
    },
  );
  ```
- **Obfuscation**:
  - Flutter: `flutter build apk --obfuscate --split-debug-info=build/symbols`.
  - Web: `jaspr build --release` (minifies/mangles JS).
- **Web Headers**: Implement CSP headers and enforce HTTPS.

---

## 8. Testing Specifics
- **Unit Tests**: `test/` folders using `package:test`.
- **Flutter Widget Tests**: `WidgetTester` with `ProviderContainer` overrides.
- **Jaspr Component Tests**: `jaspr_test` to verify rendered Tailwind classes.
- **Integration**: Testcontainers for spinning up a Spring Boot test backend.
- **Coverage**: Enforce ≥75% coverage for `core` (via `lcov` or `coveralls`).

---

## 9. Localization
- **Flutter**: `flutter_localizations` package.
- **Web**: Custom translation service.
- **Strings**: All user-visible strings stored in `core/lib/constants/strings.dart`.
- *Note*: Currently English-only, but structured for i18n (`.arb` files).

---

## 10. CI/CD Pipeline (Specifics)
- **Platform**: GitHub Actions.
- **Steps**: Lint → Format → Unit Tests → Integration (optional) → Build (APK/IPA/Web) → Deploy.
- **Deployment Targets**:
  - Web: Firebase Hosting.
  - Mobile: Firebase App Distribution.
- **Env**: `.env` files injected via GitHub Secrets.

---

## 11. Development Commands (Cheat Sheet)
- Setup: `git clone` → `melos bootstrap` → create `.env`
- Run App: `flutter run` (from `/app`)
- Run Web: `jaspr serve` (from `/web`)
- Code Gen: `melos run build` (watches for Drift/Riverpod generators)
- Tests: `melos run test`

---