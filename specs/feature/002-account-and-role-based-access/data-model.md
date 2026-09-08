# Data Model: Account and Role-Based Access

**Branch**: `feature/002-account-and-role-based-access` | **Date**: 2026-09-08
**Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

All entities are pure-Dart value types living in `core/lib/domain/`. No Drift/database persistence is introduced in this feature; session/profile live in platform-secure storage (mobile) or httpOnly fallback + in-memory cache (web) per foundation FR-011 and plan §Technical Context. Backend DTOs are generated from `contracts/api/openapi.yaml`; domain entities never import generated code directly.

---

## 1. Value Objects (Domain Input Sanitization — Constitution VIII)

### Username

| Field | Type | Rules |
|---|---|---|
| value | String | Trimmed on construction; length 3-30 after trim (clarification 2026-09-08 Q1); allowed chars `[a-zA-Z0-9._-]` only; must contain at least one alphanumeric; no spaces, no control chars; sanitized to prevent injection |
| — | — | `Username.validate(raw)` → `Either<ValidationFailure,Username>`; failure carries field `username` with message "3-30 characters, letters, digits, dot, underscore or hyphen only" |

**Validation precedence**: length check → charset regex `^[a-zA-Z0-9][a-zA-Z0-9._-]{2,29}$` (ensures first char alphanumeric and total 3-30). Backend 400 for username mapped to same message.

### Email

| Field | Type | Rules |
|---|---|---|
| value | String | Trimmed, lowercased; RFC-5322 simplified pattern `^[^\s@]+@[^\s@]+\.[^\s@]+$` + no consecutive dots; sanitized |

`Email.validate(raw)` → `Either<ValidationFailure,Email>`. Backend 400 mapped identically.

### Password

| Field | Type | Rules |
|---|---|---|
| value | SecretString | Never logged/`toString` redacted; length ≥8, must contain at least one letter `[a-zA-Z]` and one digit `[0-9]` (contract rule); trimmed length checked; no max beyond 128 for DoS guard |

`Password.validate(raw)` → `Either<ValidationFailure,Password>`. Validation runs locally pre-submit; server 400 secondary.

---

## 2. Account

Domain representation of a registered user (backend `Account` mirrored).

| Field | Type | Rules |
|---|---|---|
| id | String | Opaque backend identifier; non-empty; from `/auth/me` or `RegisterResponse` |
| username | Username | Unique (backend enforces 409); equality by id |
| email | Email | Unique; stored as normalized lowercased value |
| roles | Set<Role> | Size ≥1; assigned server-side; `ROLE_CUSTOMER` default on register |
| createdAt | DateTime? | UTC from backend when available; optional on session entity |

**Invariants**: `roles` never empty; `username`/`email` validity guaranteed by value objects (account cannot exist with invalid constituents). **Lifecycle**: created on register (immediate authenticated return), otherwise referenced via `Session`.

## 3. Session

Authenticated principal + credential pair held for the current user. Mirrors foundation's Session but extended for RBAC and clarified refresh discipline.

| Field | Type | Rules |
|---|---|---|
| account | Account | Associated account (id+username+roles) |
| accessToken | SecretString | Opaque JWT; in-memory only on web; secure storage on mobile; never rendered |
| refreshToken | SecretString | Opaque JWT; httpOnly cookie on web (no JS read) or secure storage fallback; secure storage on mobile |
| expiresIn | Duration? | From `RegisterResponse.expiresIn` or token `exp` hint; drives proximity checks (never client-clock-computed expiry) |
| issuedAt | DateTime (UTC) | When tokens issued; for staleness heuristics |
| roles | Set<Role> | Derived as `account.roles` ∪ decoded `ROLE_` claims from `/auth/me` (canonical stripped) |

**Lifecycle (sealed states mirror `AuthState`)**: `absent → authenticating → authenticated → renewing (single-flight) → authenticated | loggedOut`. `renewing` holds the shared `Completer<Session>` for queued 401s (R4). `loggedOut(reason)` clears storage/cache and closes realtime. Persistence across restart: secure storage (mobile) / httpOnly cookie (web); restored on cold start via `tryRestoreSession()` before any guarded route resolves.

**Derived helpers**: `bool get isAuthenticated`, `bool get hasRole(Role)`, `bool get canView(RouteId)`.

## 4. Role

Finite authorization classification per Constitution Contract & Platform Constraints ("Roles map 1:1 to screens").

```
sealed enum Role { customer, warehouse, admin }
```

- Wire value: `ROLE_CUSTOMER`→`customer`, `ROLE_WAREHOUSE`→`warehouse`, `ROLE_ADMIN`→`admin` (case-insensitive strip `ROLE_`).
- Multi-role: `Set<Role>`; view permission is union `canView = route.requiredRoles.isEmpty || route.requiredRoles.any(roles.contains)`. Foundation `data-model.md §2` single-role `Session.role` superseded by set.
- Ordering for landing resolver (clarification Q3): priority `admin > warehouse > customer`.

## 5. Profile

Read-only view returned by `GET /auth/me` and shown on profile screen (FR-010).

| Field | Type | Rules |
|---|---|---|
| id | String | Non-empty (from `auth/me` response `id` or `sub`) |
| username | String | Display identifier (already validated value-object string) |
| email | String | Display email |
| roles | Set<Role> | Same decoding as Session |

`Profile` is cached in `SessionCache` with `fetchedAt` and `isStale` (foundation §5). `AsyncState<Profile>` wraps loading/error: `Loading | Data(Profile) | Error(Failure)`. No write path in this feature (profile editing out of scope).

## 6. AuthState (sealed union — Constitution III & X)

Presentation-layer reactive state held by `AuthNotifier` (Riverpod `StateNotifier<AuthState>`).

| Variant | Payload | Meaning |
|---|---|---|
| `initial` | — | App launch, before restore attempt |
| `unauthenticated` | — | No stored session |
| `authenticating` | — | In-flight register/login/refresh (SC-006 disables submit) |
| `authenticated` | Session | Valid session; route guards pass |
| `renewing` | Session (old) | Single-flight refresh in progress (queued requests await) |
| `rateLimited` | Duration retryAfter | 429 with countdown (R6) |
| `failure` | Failure | Last operation failed but still unauthenticated |
| `loggedOut` | LogoutReason | Explicit logout or refresh-401 session expiry |

All variants immutable, `copyWith` where payload; exhaustive `when` required in UI.

## 7. Failure (sealed hierarchy — Constitution IV)

Extends foundation §3 with auth-specific variant; all repository methods return `Either<Failure,T>`.

| Variant | Http mapping | UI message | Retry / action |
|---|---|---|---|
| `NetworkFailure` | Dio network/timeout | "No internet. Try again." | Retry button |
| `AuthenticationFailure` | 401 on login/refresh/me | "Invalid username or password." / "Session expired. Please sign in again." | Re-login; clear session on refresh-401 |
| `AuthorizationFailure` | 403 or role guard | "You don't have permission." | Back to authorized area |
| `ValidationFailure(fieldMessages: Map<String,String>)` | 400 (field) + 409 (unique) | Field-inline messages; 409 "Username or email already registered." | Correct input |
| `RateLimitedFailure(retryAfter: Duration?)` | 429 | "Too many attempts. Try again in Xs." live countdown | Countdown + disabled submit |
| `ServerFailure` | 5xx | "Something went wrong. Try again later." | Retry |
| `UnknownFailure` | else | "Unexpected error." | Retry / report |

`RateLimitedFailure.retryAfter` parsed from `Retry-After` seconds or HTTP-date per R6. No variant carries raw `Exception`; mapper consumes it.

## 8. AsyncState<T> (reuse from foundation)

`sealed union: Loading | Data(T) | Error(Failure)` — covers profile fetch (`AsyncState<Profile>`) and any future order/catalog screens; no ad-hoc `isLoading` booleans.

## 9. SessionCache entry (in-memory only)

| Field | Type | Rules |
|---|---|---|
| session | Session? | Single active; cleared on logout |
| profile | AsyncState<Profile> | Last fetch result; `isStale=true` after WS disconnect or failed refresh until next successful `/auth/me` |

Lifetime = process/session; cleared on `loggedOut`; stale rendering shows subtle indicator (design token `AppColors.textTertiary`).

## Entity Relationships

```text
Username, Email, Password ─(value objects)─> Account
Account ─1:1─> Set<Role>
Account ─1:1─> Session (session.account)
Session ─1:1─> SessionCache (singleton, process)
Session ──re-auth──> RealtimeChannel (CONNECT with accessToken)
Profile ←derived from─ Account + /auth/me (1:1 when authenticated)
AuthState wraps Session + Failure (reactive)
Failure taxonomy is return type for every AuthRepository method: Either<Failure, _>
```

## State Transition Summary

- **Account**: nonexistent → registering(validation local) → created(authenticated immediate) | validationFailed | conflict(409)
- **Session**: absent → authenticating → authenticated ⇄ renewing(single-flight, queued) → loggedOut(reason) → absent; persistent restore bypasses authenticating on cold start
- **AuthState**: initial → unauthenticated→ authenticating → authenticated ↔ renewing → rateLimited/countdown → failure/loggedOut
- **Profile**: empty → Loading → Data(Fresh) → Stale(updates after push/reconnect failure) → Data(Fresh refetch) | Error(Failure)
- **Realtime**: disconnected → connecting(authenticated CONNECT + token) → subscribed → reconnecting(backoff+refresh) → disconnected(logout)

## Validation & Business Rules (traceability)

- Username 3-30 `[a-zA-Z0-9._-]` — FR-002+Q1
- Email syntactic validity — FR-002
- Password ≥8 letter+digit — FR-002
- 409 already-registered surfaces distinctly — FR-003
- Username-only login (email not alternative) — FR-005+Q2
- 429 Retry-After countdown, disabled submit — FR-006+Q4
- Single-flight refresh with queued retry, 60 s generic window when header absent — FR-008+Q5+Q4
- Secure storage, never log tokens — FR-007/FR-017 + SC-007 (constitution VIII)
- Highest-privilege default landing + union permissions — FR-012+Q3
- Role-hiding + friendly permission-denied — FR-013 + constitution VI
- Order scoping CUSTOMER own-only — FR-014
- Immediate feedback loading/disabled/error/success — FR-016 + SC-006 + constitution VI
```

