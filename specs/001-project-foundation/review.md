# Findings Against Tasks, Implementation Plan, Spec, and Constitution

## Resolution Status

### 1. Duplicate `RealtimeChannel` Registration Crashes Startup
- **Status:** Resolved.
- **Verification:** `configureCore()` registers `RealtimeChannel` once in `core/lib/application/injection.dart`.

### 2. Web Client Cannot Build - `dart:io` Transitively Imported
- **Status:** Resolved.
- **Verification:** Certificate pinning is app-only in `app/lib/config/certificate_pinning.dart`. Core exposes the platform-neutral `onDioBuilt` hook. `dart analyze` passes for `core`, `app`, and `web`.

### 3. Integration Tests Silently Swallowed in CI
- **Status:** Resolved.
- **Verification:** The integration command in `.github/workflows/ci.yml` no longer has an `|| echo` fallback, so test failures fail the job.

## Security Follow-up

### 4. Web Credential Store Uses JavaScript-Readable `sessionStorage`
- **Status:** Foundation limitation remains; production follow-up required.
- **Current behavior:** `web/lib/config/credential_store.dart` stores both access and refresh tokens in tab-scoped `sessionStorage`. This is JavaScript-readable and must not be treated as the final production credential strategy.
- **Simple tasks before production:**
  1. Add a backend/browser session flow that sets the refresh token in an `HttpOnly`, `Secure`, `SameSite` cookie.
  2. Change web login, refresh, restore, and logout calls to use the cookie flow; do not serialize refresh tokens in browser storage.
  3. Keep only short-lived access-token state in memory, or use the backend cookie session directly where possible.
  4. Replace deprecated `dart:html` with `package:web` and `dart:js_interop`.
  5. Add an integration/security test proving refresh credentials are absent from `sessionStorage` and `localStorage`.
- **Decision:** Acceptable for this foundation only while the web client is explicitly non-production and this limitation is documented. Complete it before production deployment.

## Quality Issues

### 5. Web Home Page Hint Subscription Not Retained
- **Status:** Resolved.
- **Verification:** `web/lib/pages/home_page.dart` assigns the stream subscription to `_hintSub`.

### 6. Redundant `kGenerateMode` Check in Web Client
- **Status:** Resolved.
- **Verification:** The obsolete condition is no longer present in the web client.

### 7. `SessionAuthGate` Duplicated Across Clients
- **Status:** Not required for the foundation; optional refactoring.
- **Reason:** This is duplicated client routing code, not a runtime defect. Keeping route guards in the platform packages avoids adding routing concerns to the shared domain/core API.
- **Optional refactor:** If shared guard behavior expands, move only the small `AuthGate` contract to a core application contract and keep each platform's `SessionAuthGate` implementation local.

## Task and Spec Alignment

- T001-T053 are marked complete. The monorepo structure, core primitives, auth flow, realtime, CI/CD, and release workflow are implemented.
- T054 remains unchecked because pipeline scratch verification requires a live CI environment.
- FR-003 is satisfied: the export-integrity test and CI check exist, and the previous `dart:io` boundary issue is resolved.
- FR-013 is satisfied for certificate pinning without importing `dart:io` into the shared/web boundary.
- The web credential storage limitation is documented in the implementation notes and remains the only required production security follow-up.

## Summary

Issues 1, 2, 3, 5, and 6 are resolved. Issue 7 is optional refactoring. Issue 4 is the only remaining security follow-up: replace browser token storage with an HttpOnly cookie-based session before production deployment.
---