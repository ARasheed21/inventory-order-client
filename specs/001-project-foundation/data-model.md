# Data Model: Project Foundation

**Branch**: `001-project-foundation` | **Date**: 2026-08-25

Entities required by the foundation. All domain entities are pure Dart value types living in
`core/lib/domain/entities/`; no persistence exists in this phase (in-memory only). Backend
mirroring (Product, Order, Cart, etc.) arrives with feature epics — the foundation models only
what the plumbing needs.

---

## 1. Session

Authenticated identity + credentials held for the current user.

| Field | Type | Rules |
|---|---|---|
| userId | String | Non-empty; opaque backend identifier |
| username | String | Non-empty |
| role | Role enum | One of CUSTOMER / WAREHOUSE / ADMIN |
| accessToken | SecretString | Opaque; memory-only on web, secure storage on mobile |
| refreshToken | SecretString | Opaque; secure storage (mobile) or httpOnly cookie (web) |
| accessExpiresAt | DateTime (UTC) | Drives proactive renewal window |

**Lifecycle**: `Absent → Authenticating → Authenticated → (Renewing ↔ Authenticated) → LoggedOut`
- Renewal triggered by 401 interception or expiry proximity; silent (FR-010).
- `LoggedOut` clears secrets from storage.
- Persistence across restart: mobile yes (secure storage), web via session cookie.

## 2. Role

Finite authorization classification carried by Session.

Values: `CUSTOMER`, `WAREHOUSE`, `ADMIN` (sealed enum). Foundation stores it and exposes it to
guards; screens differentiate in later epics.

## 3. Failure (sealed hierarchy)

Domain-level error presentation type. Location: `core/lib/domain/failures.dart`.

Variants:
- `NetworkFailure` — unreachable/timeout; message suggests retry
- `AuthenticationFailure` — invalid credentials, expired refresh; routes to re-login
- `AuthorizationFailure` — role lacks permission; friendly denial
- `ServerFailure` — 5xx; generic apology + retry
- `ValidationFailure` — field-level messages from 400 responses
- `UnknownFailure` — catch-all; never leaks raw exception text

**Rule**: every repository method returns `Either<Failure, T>`; no variant may carry raw
exception objects into the presentation layer.

## 4. AsyncState<T> (sealed union)

Standardized async presentation state (Constitution III): `Loading` | `Data(T)` | `Error(Failure)`.
Every screen state holder uses it; no ad-hoc booleans like `isLoading`.

## 5. CachedEntry

Session-scoped in-memory read-model wrapper.

| Field | Type | Rules |
|---|---|---|
| key | ResourceKey | Namespaced resource identifier (e.g., `catalog:list`, `product:{id}`) |
| payload | Object | Deserialized read model |
| fetchedAt | DateTime (UTC) | Set on fill; used to mark staleness |
| isStale | bool | True after failed refresh or received push hint until refetch completes |

**Rules**: lifetime = process/session only; cleared on logout; stale entries render with a
stale indication; a successful refetch replaces the entry atomically.

## 6. DesignToken groups

Named visual constants (not runtime entities): `AppColors` (semantic roles: primary, surface,
error…, light+dark variants), `AppSpacing` (4pt scale), `AppRadius`, `AppTypography`.
Single definition site: `core/lib/design/`. Client-local overrides forbidden.

## 7. RealtimeMessage

Decoded STOMP push payload per AsyncAPI contract.

| Field | Type | Rules |
|---|---|---|
| orderId | String (UUID) | Required by contract |
| status | OrderStatus enum | PAID / SHIPPED / DELIVERED / RESERVATION_EXPIRED / PAYMENT_FAILED / USER_UPDATE |
| reason | String? | Present only when status = PAYMENT_FAILED |

**Handling**: converted to an in-memory hint event → triggers targeted cache invalidation +
REST re-fetch of the affected resource. Never rendered directly as authoritative data.

## 8. EnvironmentConfig

Startup configuration loaded from environment files (never hard-coded).

| Field | Type | Rules |
|---|---|---|
| apiBaseUrl | Uri | Required; points at local container or staging |
| wsUrl | Uri | Required; derived host `/api/ws` |
| sentryDsn | String? | Optional in dev, required in release builds |
| environmentName | enum | dev / staging |

## Entity Relationships

```text
Session ──1:1──> Role
Session ──1:N──> CachedEntry   (logout clears all)
CachedEntry <──invalidated by── RealtimeMessage (hint)
AsyncState<T> wraps payloads produced through repositories that return Either<Failure, T>
```

## State Transitions Summary

- **Session**: Absent → Authenticating → Authenticated ⇄ Renewing → LoggedOut → Absent
- **CachedEntry**: Empty → Fresh → Stale → Fresh (refetch) | cleared on logout
- **Realtime channel**: Disconnected → Connecting(authenticated CONNECT) → Subscribed →
  (Reconnecting with backoff ⇄) → Disconnected(on logout)
