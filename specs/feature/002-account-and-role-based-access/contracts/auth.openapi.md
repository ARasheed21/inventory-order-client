# Auth API Contracts (subset of `contracts/api/openapi.yaml` v0.1.0)

**Branch**: `feature/002-account-and-role-based-access` | **Spec**: [../spec.md](../spec.md)
All four endpoints are generated via `openapi-generator` `dart-dio` and wrapped in `AuthRemoteDataSource`. No ad-hoc paths are allowed (constitution Contract & Platform Constraints).

---

## 1. POST /auth/register — Create customer account

- **Description**: Creates an account with `ROLE_CUSTOMER` and returns tokens immediately (FR-001/FR-004).
- **Request** (`RegisterRequest`):
  ```json
  { "username": "alice", "email": "alice@example.com", "password": "s3cret-pass1" }
  ```
  Rules: `username` non-empty, 3-30 `[a-zA-Z0-9._-]` per clarification Q1 (server also enforces uniqueness); `email` valid; `password` ≥8 with letter+digit.
- **Responses**:
  - `201` → `RegisterResponse { username, accessToken, refreshToken, expiresIn }` → repository persists session, emits `authenticated`.
  - `400` → `ApiError { timestamp, status, error, message, path }` → `ValidationFailure(fieldMessages)` mapped per-field.
  - `409` → empty body "Username or email already registered" → `ValidationFailure` with friendly 409 banner (SC-002).
- **Frontend contract**: Validate locally first (value objects); only on 2xx store tokens via `CredentialStorage`; no separate login after success.

## 2. POST /auth/login — Authenticate with username+password

- **Description**: Returns JWT pair; rate-limited per username after `security.login.max-attempts` (FR-005/FR-006).
- **Request** (`LoginRequest`):
  ```json
  { "username": "alice", "password": "s3cret-pass1" }
  ```
  Note: username only (clarification Q2) — email is not accepted here; entering an email yields 401.
- **Responses**:
  - `200` → `AuthResponse { username, accessToken, refreshToken, expiresIn }` (schema type `object` in yaml; same fields as RegisterResponse) → persist + `authenticated`; landing via resolver (FR-012).
  - `401` → `AuthenticationFailure` → inline "Invalid username or password." (does not leak whether username exists).
  - `429` → `RateLimitedFailure(retryAfter)` → banner + countdown + disabled submit; `Retry-After` header (seconds or HTTP-date) respected per clarification Q4; when absent default 60 s window.
- **Side effects**: Establishes STOMP CONNECT with new `accessToken`.

## 3. POST /auth/refresh — Renew session

- **Description**: Validates refresh JWT and issues a new `accessToken/refreshToken` pair (FR-008/FR-009).
- **Request** (`RefreshRequest`):
  ```json
  { "refreshToken": "<opaque>" }
  ```
- **Responses**:
  - `200` → new token pair → update storage, rewrite `Authorization` header, retry original request(s), re-auth WebSocket (FR-018).
  - `401` → refresh invalid/expired → clear storage, `loggedOut(reason: sessionExpired)`, redirect to `/login` with "Session expired."
- **Discipline**: Single-flight queued retry — concurrent 401s share one refresh call (clarification Q5). `expiresIn` is the only lifetime hint; clients never compute expiry on local clock.

## 4. GET /auth/me — Current-user profile

- **Description**: Resolves the authenticated principal; returns `id, username, email, ROLE_` roles (FR-010).
- **Security**: `bearerAuth` required; 401 if no valid token.
- **Responses**:
  - `200` → object `{ id, username, email, roles: ["ROLE_CUSTOMER", ...] }` → decoded into `Profile` + `Account.roles` (strip `ROLE_` prefix, map to `Role` enum); cached as `AsyncState<Profile>`.
  - `401` → `AuthenticationFailure` → triggers refresh-or-logout path same as above.
- **Usage**: Called on cold-start restore (post-storage hydration) and on profile screen load; powers `RoleGuard` decisions.

---

## Client-Side Generation & Error Mapping

- Generation command (via Melos): `melos run build` after `contracts/api/openapi.yaml` change; commit generated client so CI stays hermetic (research R2).
- `error_mapper.dart` table:
  | HTTP | Domain `Failure` |
  |---|---|
  | network/timeout | `NetworkFailure` |
  | 400 | `ValidationFailure` (field map from `ApiError.message` split by field) |
  | 401 login/refresh/me | `AuthenticationFailure` |
  | 401 on other endpoints | triggers single-flight refresh then retries; only if refresh fails → `AuthenticationFailure` |
  | 403 | `AuthorizationFailure` |
  | 409 register | `ValidationFailure` with "already registered" on both username & email fields |
  | 429 | `RateLimitedFailure(retryAfter: parseRetryAfter(header))` |
  | 5xx | `ServerFailure` |
  | else | `UnknownFailure` |

No raw `DioException` escapes past `error_mapper`. Tokens are never included in error messages (SC-007).

## Non-Contract Behavior (explicitly out-of-scope, deferred)

- Password reset / email verification / profile edit: no endpoint; returns 404 is surfaced as `ServerFailure` friendly denial (Out of Scope §).
- ADMIN/WAREHOUSE creation: out-of-band; login still uses same `/auth/login` (Assumption § spec).
