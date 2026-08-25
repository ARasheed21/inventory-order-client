# Project Constitution: Full-Stack Monorepo with Flutter Mobile & Jaspr Web Dashboard

## Important Guidelines for Development

This constitution defines the architectural principles and development practices for building a cross-platform monorepo with a Flutter mobile app and Jaspr web dashboard, sharing a common Dart codebase. These guidelines focus on general practices and avoid feature-specific details.

---

## 1. Monorepo & Structure

- **Melos** manages 3 packages: `core` (pure Dart), `app` (Flutter), `web` (Jaspr).
- `core` exports via `core.dart`; never import `src/` directly.
- **Dependency inversion**: Presentation → Application → Domain ← Data.  
  `core` has **zero** Flutter/Jaspr/UI dependencies.

**Package layouts**:

- **core**: `domain/` (entities, repo interfaces), `application/` (Riverpod providers), `data/` (repo impls, DTOs, API clients), `infrastructure/` (Dio interceptors, Drift DB, WebSocket).
- **app**: `features/` (feature-first: `presentation/`, `providers/`), `config/`, `main.dart`.
- **web**: `components/`, `pages/`, `layouts/`, `routes/`, `main.dart`.

---

## 2. State Management (Riverpod)

- **Core principles**:
  - Providers live in `core/application/providers/`.
  - Types: `Provider`, `FutureProvider`, `StreamProvider`, `StateNotifierProvider`.
  - Use `AsyncValue` for loading/error/data.
  - Code‑generate with `riverpod_generator`.
- **MVVM** via StateNotifier/FutureProvider.
- **Optimistic updates** for immediate UI + rollback on failure.
- **Caching** – offline‑first with Drift (SQLite) as source of truth; sync in background; TTL invalidation.

---

## 3. Data Layer

- **Dio client** in `core`:
  - Interceptors: JWT injection, token refresh on 401, logging (dev), error mapping.
  - Certificate pinning (see Security).
- **Repositories** (interfaces in `domain`, impls in `data`): Auth, Product, Cart, Order, Admin.
- **Drift (SQLite)** in `core/infrastructure/database/`:
  - Tables mirror backend entities; indexes, foreign keys, constraints.
  - Stream queries for reactive UI.
  - Transactions for atomic writes.
  - Read: Drift first; if stale/missing → API → update DB.
  - Write: immediate to Drift (optimistic) → background API sync; rollback on failure.
  - Pre‑populated with initial data; migrations for updates.
- **WebSocket** (STOMP) in `core`:
  - Connect after auth; subscribe to order status events; auto‑reconnect with exponential backoff.
- **Error handling**: `Either<Failure, T>` (fpdart) or `AsyncValue`; failure types: Network, Api, Auth, Db, Validation.

---

## 4. Domain Layer

- Entities & value objects: pure Dart, `@immutable`, `copyWith`, `==`/`hashCode`.
- Repository interfaces: abstract, return `Future<Either<Failure, T>>`.

---

## 5. Presentation Layer

### Flutter (`app`)
- Screens: `ConsumerWidget`/`ConsumerStatefulWidget`.
- Navigation: `go_router` with guards (`AuthGuard`, `GuestGuard`), deep linking, shell routes.
- Use `context.watch`/`ref.watch`.

### Jaspr (`web`)
- Components: functional (preferred) or class.
- Styling: **Tailwind CSS** via `jaspr_tailwind` (utility classes only, responsive, dark mode).
- Routing: `jaspr_router` with guards.
- Use `ref.watch` from `jaspr_riverpod`.

### Shared UI patterns
- Loading: skeletons/progress indicators.
- Error: user‑friendly messages + retry.
- Empty states: informative actions.
- Success feedback: snackbars (Flutter) / toasts (Jaspr).

---

## 6. Routing

- **Flutter**: `go_router`; all routes in one config; shell routes for bottom nav; `PathUrlStrategy`.
- **Web**: `Router` + `Route`; nested routes for admin; guards redirect to `/login`.
- General: routes defined centrally; use `context.push()` for back‑stack.

---

## 7. Theming & Styling

- **Flutter**: `ThemeData` with custom color scheme; use `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography` from `core`; avoid `Colors.*` constants.
- **Web (Tailwind)**: utility classes only; responsive (`sm:`, etc.) and dark (`dark:`) prefixes; custom components via `@apply` if needed; typography plugin for rich text.
- Design tokens (`AppSpacing`, etc.) shared across platforms; Tailwind config mirrors them with CSS variables.

---

## 8. Dependency Injection

- **`get_it`** in `core` for singletons (API clients, DB, repos) and factories (notifiers, use cases).
- Riverpod providers wrap `get_it` or use `Provider` for pure deps.
- Registration: core deps in `core/application/injection.dart`; platform‑specific in respective `main.dart`.

---

## 9. Data Flow

- **Standard**: UI → ref.read(provider).method() → StateNotifier/FutureProvider → Repository (abstract) → implementation → Dio/Drift/WebSocket.
- **Offline‑first**: Check Drift → return if fresh; else API → store in Drift → return.
- **Optimistic update**: UI updates + Drift write → background API → success confirm / fail rollback.

---

## 10. WebSocket & Real‑Time

- Connect after auth → STOMP CONNECT with token.
- Subscribe: `/user/queue/orders` (customer), `/topic/orders` (admin).
- On events: update Riverpod providers **and persist** to Drift.
- Reconnect with exponential backoff; show offline indicator; queue updates for replay.

---

## 11. Security

### Authentication
- JWT stored: Flutter – `flutter_secure_storage` (encrypted); Web – `httpOnly` cookies (preferred) or encrypted localStorage.
- Token refresh interceptor; role‑based UI/API restrictions.

### Certificate Pinning
- **Critical endpoints** (login, payments) enforce pinning in release builds.
- Pin SHA‑256 of public key (allow renewal). Maintain backup pins.
- Example (Dio):
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
- Fallback: show error & force app update on pin failure.

### Obfuscation
- **Flutter**: `flutter build apk --obfuscate --split-debug-info=build/symbols`; upload symbols to Firebase Crashlytics.
- **Web**: `jaspr build --release` minifies/mangles JS; source maps not deployed.
- Remove debug logs in release; `assert` stripped.

### Web Security
- CSP headers; sanitise input; avoid `dangerouslySetInnerHTML`; enforce HTTPS.

---

## 12. Testing

- **Unit**: domain entities, repos (mocked Dio/Drift), Riverpod providers (with overrides), use cases.
- **Widget/Component**:
  - Flutter: `WidgetTester`, `ProviderContainer` overrides.
  - Jaspr: `jaspr_test`; verify Tailwind classes.
- **Integration**: Testcontainers Spring Boot; end‑to‑end flows; WebSocket updates; offline sync.
- **CI**: GitHub Actions – lint, format, unit tests (≥75% coverage for `core`), optional integration, build (APK/IPA, web), deploy; version bump via conventional commits.

---

## 13. Code Quality & Style

- **Naming**: files `snake_case`; classes `UpperCamel`; methods/vars `lowerCamel`; private `_`; constants `SCREAMING_SNAKE` only for true constants.
- **Clean Architecture**: inward dependencies; entities pure; use cases one method (`call()`); repositories abstract in domain.
- **Dart**: null‑safe; avoid `dynamic`; use `sealed` for finite states; `@immutable` for state classes.
- **Riverpod**: prefer `ref.watch` over `context.watch`; `ref.listen` for side effects; avoid `Provider` for mutable state.
- **Docs**: `///` for public APIs; inline comments for complex logic.

---

## 14. Localization

- Use `flutter_localizations` for Flutter; custom service for Jaspr.
- All user‑visible strings in `core/lib/constants/strings.dart`; no hardcoding.
- English only (structure for i18n).

---

## 15. Performance

- **Flutter**: `const` widgets; `Selector`/`ref.select`; `ListView.builder` or `Slivers`; lazy images; `AutomaticKeepAliveClientMixin`; index Drift queries.
- **Jaspr**: `Suspense`; code splitting; debounce/throttle; virtual scrolling.
- **General**: batch API requests; `Future.wait`; background services/Web Workers for large sync.

---

## 16. CI/CD

- **Workflow**: push/PR → lint+format → unit tests → integration (optional) → build (APK/IPA, web) → deploy (Firebase Hosting for web, Firebase App Distribution for mobile) → version bump.
- **Env**: `.env` with secrets; injected via GitHub Actions.
- **Rollback**: web – instant Firebase rollback; mobile – new build via distribution.

---

## 17. Development Workflow

- Setup: clone → `melos bootstrap` → `.env` → `flutter run` (app) / `jaspr serve` (web) → `build_runner` watch.
- Git: feature branches → PR → merge to `main`; conventional commits; pre‑commit hooks for lint/format.
- Code generation: `melos run build`; watch mode.

---

## 18. Dos & Don’ts (Condensed)

| **Do** ✅ | **Don’t** ❌ |
|-----------|--------------|
| Keep domain pure (no UI imports). | Import `data/` from `presentation/` or `domain/`. |
| Use Riverpod for app state (never `setState`). | Put business logic in UI components. |
| Use Drift for offline-first caching. | Hardcode strings/colors in UI. |
| Handle async with `AsyncValue`. | Call APIs directly from UI. |
| Write unit tests for use cases/repos. | Ignore error states (handle loading/error/data). |
| Use Tailwind classes in Jaspr (no custom CSS). | Use `setState` for app-wide state. |
| Follow monorepo with Melos. | Duplicate models between packages. |
| Use `go_router` (Flutter) / `jaspr_router` (web). | Hardcode API endpoints (use `.env`). |
| Implement optimistic updates. | Store sensitive data in plaintext. |
| Cache product catalog and order history. | Write implementation details in repo interfaces. |
| Use WebSockets for real-time. | Create UI components ad‑hoc; prefer reusability. |
| Handle token refresh automatically. | Use `Colors.*` without theme context. |
| Test error paths (network, DB, API). | Ignore WebSocket reconnection. |
| Use `ref.select()` to optimize rebuilds. | Forget to mock dependencies in tests. |
| Enable certificate pinning in release. | Push to `main` without passing CI. |
| Obfuscate release builds and save symbols. | Bypass certificate pinning in release. |
| Encrypt local DB and secure storage. | Forget to encrypt local DB if sensitive. |

---

## 19. Package‑Specific Guidelines

- **`core`**: pure Dart; export only `core.dart`; domain models `@immutable`; Dio config in `data/network`; Drift tables/DAOs in `infrastructure/database`; ≥80% coverage.
- **`app`**: Flutter; Android first (iOS later); `go_router` with `ShellRoute`; widgets reusable in `lib/widgets/`; feature‑first; assets in `assets/`; enable obfuscation.
- **`web`**: Jaspr; modern browsers; Tailwind only; functional components preferred; client‑side routing; static assets in `web/assets/`; minify/mangle.

---

## 20. Summary (Essentials)

- Clean Architecture, separation of concerns.
- Shared code in `core`, reused by both apps.
- Riverpod + Drift + WebSocket for state, data, and real‑time.
- Tailwind for web, custom theme for Flutter, both aligned.
- Security: pinning, obfuscation, encryption, secure storage.
- Testing, CI/CD, and developer experience tooling (Melos, conventional commits).
- This constitution is the single source of truth; deviations require team approval.

---