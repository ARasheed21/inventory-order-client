
# Findings Against Tasks, Implementation Plan, Spec, and Constitution

## Critical Bug

### 1. Duplicate `RealtimeChannel` Registration Crashes Startup
- **File:** `core/lib/application/injection.dart:53-55`
- **Issue:**  
  `getIt.registerSingleton<RealtimeChannel>(RealtimeChannel(reporter: reporter));` appears twice.  
  GetIt throws `AssertionError` ("Object with type ... is already registered") when the same type is registered more than once.  
  As a result, `configureCore()` crashes at runtime on every platform — neither the app nor the web client can start.
- **Severity:** Critical — the application cannot boot.

## Significant Bugs

### 2. Web Client Cannot Build – `dart:io` Transitively Imported
- **File:** `core/lib/core.dart:18` exports `data/network/api_http_client.dart`, which imports `infrastructure/security/certificate_pinning.dart:1` (which imports `dart:io`).  
  The web client (`web/lib/main.client.dart:6`) imports `package:core/core.dart`.
- **Issue:**  
  - `dart:io` is native‑only; `dart2js` stubs it, but `CertificatePinner.install()` directly uses `IOHttpClientAdapter` and `HttpClient`.  
  - In staging mode (`APP_ENV=staging` — the production web target), `pinnerFromConfig()` returns a non‑null `CertificatePinner`, and `buildDio()` calls `pinnerFromConfig(config)?.install(dio)`, which throws `UnsupportedError` at runtime on web.  
  - Dev mode works only because `pinnerFromConfig` returns `null` when `isReleaseLike` is `false`.
- **Severity:** High — the web client crashes in any non‑dev environment when making HTTP requests.
- **Suggested fix (mentioned in original):** Use conditional imports (`dart:io` vs stub) for certificate pinning, or keep `certificate_pinning.dart` out of the core barrel export and let platform clients import it selectively.

### 3. Integration Tests Silently Swallowed in CI
- **File:** `.github/workflows/ci.yml:112`
- **Issue:**  
  ```yaml
  run: flutter test integration_test -d headless-web-server || echo "integration suite requires a device target; see quickstart.md"
  ```
  The `|| echo` means the step never fails. Integration test failures will not block PRs.
- **Severity:** High — CI cannot catch integration regressions, undermining quality gates described in the constitution (SC‑006, SC‑007) and tasks T050/T054.


## Security Concerns

### 4. Web Credential Store Stores JWTs in JavaScript‑Readable `sessionStorage`
- **File:** `web/lib/config/credential_store.dart:9-28`
- **Issue:**  
  Access tokens and refresh tokens are serialized to `sessionStorage`, which is accessible to any JavaScript running on the page.  
  The comment at lines 15‑16 acknowledges that `httpOnly` cookies are the production path, but this store **is** the implementation being shipped and demonstrated. Any XSS vulnerability (including from third‑party scripts or browser extensions) exposes all session credentials.  
  Additionally, `dart:html` (line 5) is deprecated in favor of `package:web`.
- **Severity:** Medium — acceptable for foundation scaffolding if documented as non‑production, but task notes mark T038 as complete without noting this security limitation.


## Quality Issues

### 5. Web Home Page Hint Subscription Not Retained
- **File:** `web/lib/pages/home_page.dart:20,28-30`
- **Issue:**  
  ```dart
  StreamSubscription<RealtimeHint>? _hintSub;  // declared but never assigned
  // ...
  getIt<RealtimeChannel>().hints.listen(_onHint);  // subscription discarded
  ```
  The `hints.listen()` return value is discarded (suppressed by `// ignore: discarded_futures`). If garbage collected, the listener silently stops receiving hints, defeating the real‑time hint → refetch demonstration (FR‑007).
- **Severity:** Medium — the hint‑to‑refetch feature (task T047) silently stops working.

### 6. Redundant `kGenerateMode` Check in Web Client
- **File:** `web/lib/pages/home_page.dart:27`
- **Issue:**  
  ```dart
  if (kGenerateMode || kIsWeb) {
  ```
  This is the web client entrypoint — `kIsWeb` is always `true` here. `kGenerateMode` (a Flutter concept) is not meaningful in a pure Jaspr/Dart context. This dead condition adds confusion without effect.
- **Severity:** Low.

### 7. `SessionAuthGate` Duplicated Across Clients
- **Files:** `app/lib/config/session_gate.dart` and `web/lib/config/session_gate.dart`
- **Issue:** Both define identical `AuthGate` interface and `SessionAuthGate` implementations. The `AuthGate` interface is domain‑level (route guard contract per Constitution VI) but lives in platform packages rather than core. Task T027/T028 mark this as complete, but the shared interface should arguably live in `core` per the constitution's DDD layering.
- **Severity:** Low — not a bug, but a layering inconsistency.


## Task / Spec Alignment

- T001‑T053: All marked `[x]` in the tasks diff. The monorepo structure, core primitives, auth flow, realtime, CI/CD, and release workflow are implemented.
- T054 (pipeline verification scratch run) is correctly left unchecked — it requires a live CI environment.
- **Constitution II (FR‑003):** Export integrity test exists and CI step is configured. However, the `dart:io` transitive import (#2 above) means the web client violates the spirit of the clean core boundary.
- **Constitution IV:** `failure_mapper.dart` correctly maps all `DioExceptionType` cases. No raw exceptions escape repositories.
- **Constitution VII (FR‑004):** Design tokens are centralized in `core/lib/design/tokens.dart`. Theme binding in `app/lib/config/theme.dart` is clean. The CI lint check for raw color/spacing literals is present.
- **Constitution VIII (FR‑013):** Certificate pinning is implemented but has the cross‑platform issue described in #2.

## Summary

The most urgent fix is the double `RealtimeChannel` registration (#1) — it prevents the app from starting at all. The `dart:io` transitive import (#2) is the second priority since it breaks web in staging/release mode. The silent CI test swallowing (#3) undermines quality gates that tasks T048‑T050 explicitly require.
---
