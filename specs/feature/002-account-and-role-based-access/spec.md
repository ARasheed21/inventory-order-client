# Feature Specification: Account and Role-Based Access

**Feature Branch**: `feature/002-account-and-role-based-access`  
**Created**: 2026-09-08  
**Status**: Draft  
**Input**: User description: "read @docs/constitution.md , @contracts/prd/frontend-prd.md , @contracts/api/openapi.yaml to start making 2nd spec for 002-account-and-role-based-access, but please use the github flow branching strategy when you create branching like using feature, bugfix or any descriptive naming"

## Clarifications

### Session 2026-09-08

- Q: Username format - what length and allowed characters should be enforced client-side? → A: 3-30 chars, letters/digits/._- (alphanumeric plus dot, underscore, hyphen)
- Q: Should login accept username only or also email? → A: Username only (contract-strict) - LoginRequest username field only; email cannot be used to log in
- Q: Where should multi-role users land after login? → A: Highest-privilege default - ADMIN → admin dashboard, else WAREHOUSE → fulfillment queue, else CUSTOMER → catalog
- Q: How should 429 rate-limit blocking be presented? → A: Respect Retry-After header with countdown - show countdown if header present, otherwise generic message with ~60s retry; submit disabled during block
- Q: How to handle concurrent 401s on expired token? → A: Single-flight refresh with queued retry - one refresh in flight, other requests wait and retry; if refresh fails all transition to logout

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Customer Registration (Priority: P1)

As a new customer, I want to create an account with a username, email, and password so that I can shop and my orders are tied to me, with clear feedback when my inputs are invalid or already taken.

**Why this priority**: No customer journey can start without an account. Registration is the entry point for the customer app and is the first dependency for cart, checkout, and order history. It is independently valuable - a user can register and immediately be authenticated.

**Independent Test**: Can be fully tested by opening the customer app while unauthenticated, submitting the registration form with valid and invalid inputs, and verifying account creation, error messages, and immediate authenticated state without needing any catalog or order functionality.

**Acceptance Scenarios**:

1. **Given** an unauthenticated visitor on the registration screen, **When** they submit a unique username, valid email, and a password of at least 8 characters containing a letter and a digit, **Then** the account is created, the user is considered logged in, and they are taken to the authenticated home/catalog area.
2. **Given** a visitor entering a username or email that already exists, **When** they submit registration, **Then** they see a specific message that the username or email is already registered and are not logged in.
3. **Given** a visitor entering an invalid email (blank, missing @, or malformed), **When** they submit or leave the field, **Then** they see a validation message explaining the email is invalid and submission is blocked.
4. **Given** a visitor entering a weak password (fewer than 8 characters, or missing a letter or digit), **When** they submit, **Then** they see a message explaining the password requirements and submission is blocked.
5. **Given** a visitor submits with any required field blank, **When** submission is attempted, **Then** each blank field shows a required-field message.

---

### User Story 2 - Customer and Staff Login with Persisted Session (Priority: P1)

As a returning user (customer, administrator, or warehouse staff), I want to log in with my credentials and remain logged in across app restarts, with the session renewing automatically when it expires, so that I am not interrupted mid-task.

**Why this priority**: Login is the daily entry point for every role. Persisted sessions and silent renewal directly support the PRD promise that customers "remain logged in across restarts" and "session renews automatically" and that dashboard users can access protected areas. Without it, every restart or expiry forces friction.

**Independent Test**: Can be fully tested by registering or using seeded accounts for each role, closing and reopening the app, forcing token expiry, and observing that the user stays authenticated or is silently re-authenticated without re-entering credentials.

**Acceptance Scenarios**:

1. **Given** a registered customer on the login screen, **When** they enter a correct username and password and submit, **Then** they are authenticated, taken to their authorized home area, and subsequent protected requests succeed.
2. **Given** a dashboard user with administrator credentials, **When** they log in on the web dashboard, **Then** they land in the admin-authorized area; similarly a warehouse account lands in the warehouse-authorized area.
3. **Given** invalid credentials (wrong password or unknown username), **When** login is submitted, **Then** the user sees "invalid username or password" and remains on the login screen, not authenticated.
4. **Given** a user who has exceeded failed login attempts and is rate-limited, **When** they attempt another login, **Then** they see a message that too many attempts were made and to try again later, and login is blocked until the window expires.
5. **Given** a logged-in user who closes and reopens the app/browser, **When** the app starts, **Then** they are still logged in without re-entering credentials and their profile is available immediately.
6. **Given** a logged-in user whose short-lived session has expired mid-shopping, **When** they perform any protected action, **Then** the session is renewed automatically in the background and the original action succeeds without showing a login prompt.
7. **Given** a logged-in user whose refresh token is also expired or invalid, **When** a protected action or auto-renewal is attempted, **Then** they are signed out and returned to the login screen with a message that the session expired and they need to sign in again.

---

### User Story 3 - Role-Based Access and Route Protection (Priority: P1)

As a user with a specific role (CUSTOMER, WAREHOUSE, ADMIN), I want the application to show only the screens and actions my role is allowed to use and to block or hide anything else with a friendly denial, so that I cannot accidentally access or corrupt data beyond my permissions.

**Why this priority**: Roles map 1:1 to screens per PRD Implementation Decisions. Correct gating is a security and usability requirement - customers must never see admin inventory tools, warehouse staff must not see admin-only catalog creation, and customers must be restricted to their own orders. This is co-equal with authentication.

**Independent Test**: Can be fully tested by logging in as each role and navigating to every route and action, verifying visibility and access: CUSTOMER sees only customer app; WAREHOUSE sees fulfillment queue but not catalog creation; ADMIN sees everything; unauthorized deep-links redirect or show a permission-denied message, not a crash.

**Acceptance Scenarios**:

1. **Given** an unauthenticated visitor, **When** they attempt to navigate directly to any protected route (cart, orders, dashboard inventory, fulfillment queue), **Then** they are redirected to login and, after successful login, returned to their originally requested authorized destination if their role permits it.
2. **Given** a logged-in CUSTOMER, **When** they view navigation, **Then** they see only customer sections (catalog, cart, orders, profile) and do not see admin inventory management, audit history, or warehouse fulfillment controls.
3. **Given** a logged-in WAREHOUSE user on the dashboard, **When** they view navigation, **Then** they see the fulfillment queue (PAID orders ready to ship, SHIPPED → deliver) but do not see admin-only product creation/editing or audit-history views, which are hidden or disabled.
4. **Given** a logged-in ADMIN on the dashboard, **When** they view navigation, **Then** they see all sections including product/inventory management, full order monitoring with filters, and audit trails.
5. **Given** a user who manually navigates to a route their role does not permit, **When** the route loads, **Then** they see a friendly "you do not have permission" message (not a crash or raw error) and are offered navigation back to an authorized area.
6. **Given** a logged-in CUSTOMER, **When** they request orders, **Then** they see only their own orders; they cannot view or filter another customer's orders, and any attempt is denied.

---

### User Story 4 - View Profile and Log Out (Priority: P2)

As a logged-in user, I want to see who I am logged in as (profile basics and roles) and to log out cleanly so that I can confirm the correct account is active and secure a shared device.

**Why this priority**: Completes the account lifecycle started in stories 1-2. Profile confirmation builds trust ("am I on the right account?") and logout is required for shared-device security. Lower priority than auth and gating but needed for a complete MVP.

**Independent Test**: Can be fully tested by logging in as each role, opening the profile/account area, verifying displayed identity, logging out, and confirming the session is cleared and protected routes are no longer accessible.

**Acceptance Scenarios**:

1. **Given** a logged-in user, **When** they open the profile/account area, **Then** they see their identifier, username, email, and assigned role(s) as returned by the current-user endpoint.
2. **Given** a logged-in user viewing their profile, **When** the profile data is fetched, **Then** a loading indicator is shown until data arrives, and an error state with retry is shown if the fetch fails.
3. **Given** a logged-in user, **When** they choose log out, **Then** local credentials are cleared, the real-time connection is closed, they are returned to the login screen, and navigating back does not restore the previous session without re-authenticating.
4. **Given** a user who has logged out, **When** they attempt to access a protected screen via navigation or deep link, **Then** they are treated as unauthenticated and redirected to login.

---

### User Story 5 - Authentication Feedback and Recovery (Priority: P2)

As a user performing any auth action, I want every outcome to give immediate, specific visual feedback (loading, success, or friendly error with next step) so that the app feels responsive and I know how to recover.

**Why this priority**: Directly supports the constitution's "User Feedback" principle and PRD's requirement that authorization failures surface as friendly denials, not crashes. While not a new journey, consistent feedback determines perceived quality and is testable across all auth screens.

**Independent Test**: Can be fully tested by triggering each auth success and failure path (register, login, refresh, profile fetch, logout, expired token, network failure, rate limit) and verifying the UI shows the correct loading state, success confirmation, or categorized error with a retry or guidance action.

**Acceptance Scenarios**:

1. **Given** a user submitting any auth form, **When** the request is in flight, **Then** the submit control shows a loading state and is disabled to prevent duplicate submissions.
2. **Given** a successful registration or login, **When** it completes, **Then** the user sees a success confirmation and is navigated to the authorized area without needing manual refresh.
3. **Given** any auth request that fails due to network unavailability, **When** the failure occurs, **Then** the user sees a friendly network error with a retry action, not a raw technical exception.
4. **Given** any auth request that fails due to server error, **When** the failure occurs, **Then** the user sees a friendly server error with guidance to try again later.
5. **Given** a validation failure (e.g., blank field, bad email, weak password), **When** detected, **Then** the offending field shows an inline message and the form does not submit.

### Edge Cases

- What happens when the same username/email is registered concurrently from two devices? Only one succeeds; the other receives the 409 conflict with a clear "already registered" message.
- What happens when a user's access token expires while a real-time connection is active? The connection must attempt silent renewal and reconnect with the new token; if renewal fails, the connection closes and the user is shown an offline/signed-out indicator.
- What happens when login is rate-limited (429) after repeated failures? The UI shows a "too many attempts, try again later" message, disables the submit control for a cooldown period, and does not reveal whether the username exists.
- What happens when stored credentials are corrupted or cleared externally (e.g., device secure storage wiped)? The app treats the user as unauthenticated on next launch and shows login, without crashing.
- What happens when a user with multiple roles (e.g., ADMIN+WAREHOUSE) exists? The union of permissions applies; navigation shows all sections permitted by any assigned role.
- What happens when network drops mid-registration or mid-login? The operation shows a retryable network error; no partial authenticated state is persisted, and credentials are not stored until success.
- What happens when a customer tries to access `/api/admin/audit/...` or another admin-only endpoint by crafting a request? The backend denies it and the UI surfaces a friendly permission-denied message; no admin data is rendered.
- What happens when password contains only letters or only digits, or is exactly 7 vs 8 characters? Validation rejects it with the specific requirement message before any network call.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow an unauthenticated visitor to register a new customer account by providing username, email, and password.
- **FR-002**: The system MUST validate registration inputs before submission: username is required, 3-30 characters, allowed characters are letters, digits, dot (.), underscore (_), and hyphen (-), with no spaces; email is required and must be syntactically valid; password must be 8-128 characters and contain at least one letter and one digit (128 max is a client-enforced DoS guard). Client-side validation MUST reject usernames outside 3-30 chars or containing disallowed characters and passwords outside 8-128 / missing letter/digit before any network call, and map backend 400 for those formats to the same field-level messages.
- **FR-003**: The system MUST surface registration failure reasons distinctly: validation failure (400) with field-level messages and conflict when username or email already exists (409) with a specific "already registered" message.
- **FR-004**: The system MUST, on successful registration, immediately authenticate the user (issue and persist tokens) so no separate login step is required.
- **FR-005**: The system MUST allow a user to log in with username (not email) and password and, on success, persist the session for future launches. The login form MUST label the identifier as "Username" and MUST NOT accept email as an alternative; entering an email in that field will be treated as a username lookup and fail with 401 invalid credentials.
- **FR-006**: The system MUST surface login failure reasons distinctly: invalid credentials (401) with "invalid username or password" and rate-limited after repeated failures (429) with "too many attempts, try again later" and a temporary block. When a Retry-After header is present, the UI MUST show a countdown until retry is allowed and keep submit disabled; when absent, it MUST show a generic message and allow retry after a 60s default window (matching `RateLimitedFailure.retryAfter = 60s` per clarification 2026-09-08 Q4).
- **FR-007**: The system MUST persist authentication credentials in platform-appropriate secure storage so the user remains logged in across app restarts and browser reloads until explicit logout or token invalidation. (Covers storage; secrecy covered by FR-017.)
- **FR-008**: The system MUST automatically renew an expired short-lived session using the stored refresh token without user interaction, retry the original failed request, and succeed transparently when renewal is valid. When multiple concurrent requests receive 401 due to expiry, the system MUST perform only a single-flight refresh and queue the other requests to retry with the new token; if the single refresh fails, all queued requests MUST fail over to the session-expired logout flow.
- **FR-009**: The system MUST, when refresh fails (expired or invalid refresh token), clear the local session and redirect the user to login with a session-expired message, preventing use of stale credentials.
- **FR-010**: The system MUST provide a "current user" view that displays the authenticated user's id, username, email, and assigned roles, with loading and error states.
- **FR-011**: The system MUST allow a logged-in user to log out, which clears stored credentials, closes any real-time connection, and returns the user to the unauthenticated state.
- **FR-012**: The system MUST enforce role-based navigation guards declaratively: every protected route declares required role(s), unauthenticated access redirects to login, and authorized access after login returns to the originally requested route when permitted. When no deep link was requested, post-login landing MUST follow highest-privilege default: ADMIN → admin dashboard, else WAREHOUSE → fulfillment queue, else CUSTOMER → catalog.
- **FR-013**: The system MUST hide or disable UI sections and actions the current role is not authorized for (CUSTOMER sees only customer app; WAREHOUSE sees fulfillment queue but not admin product create/edit or audit; ADMIN sees all), and MUST show a friendly permission-denied message (not a crash) if an unauthorized route is accessed directly.
- **FR-014**: The system MUST scope customer order visibility: a CUSTOMER can list and open only their own orders; any attempt to view another customer's order is denied; ADMIN and WAREHOUSE views follow backend scoping rules.
- **FR-015**: The system MUST map every authentication failure to a categorized, user-friendly domain error (network, authentication, validation, rate-limited, server) with an appropriate recovery action (retry, correct input, wait, or re-login) and MUST never surface raw exceptions to the UI.
- **FR-016**: The system MUST show immediate visual feedback for every auth action: disabled submit with loading indicator while in flight, success confirmation on completion, and field-level or banner errors on failure.
- **FR-017**: The system MUST never log, render, or expose authentication tokens in UI, logs, error messages, or diagnostics. (Storage mechanism required by constitution is satisfied by FR-007; this FR covers secrecy only.)
- **FR-018**: The system MUST re-authenticate the real-time channel after a token renewal and MUST reconnect automatically after interruptions, falling back to signed-out state only when renewal is no longer possible.

### Key Entities

- **Account**: Represents a registered user. Attributes: id, username (unique), email (unique), password (never returned), roles (one or more of CUSTOMER, WAREHOUSE, ADMIN), creation timestamp.
- **Session**: Represents an authenticated state for an account. Attributes: access token (short-lived), refresh token (long-lived), access token lifetime, authenticated principal reference. Lifecycle: created on register/login, renewed via refresh, destroyed on logout or refresh failure.
- **Role**: A named permission set that maps 1:1 to visible screens and allowed actions. Values: CUSTOMER (customer app only), WAREHOUSE (fulfillment queue: view PAID, ship, deliver), ADMIN (all product, inventory, order, and audit capabilities). A user may hold one or multiple roles; permissions are the union.
- **Profile**: Read-only view of the current authenticated account as returned by the current-user endpoint. Attributes: id, username, email, roles. Used to confirm identity and drive route guards.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of new visitors complete registration (valid inputs) in under 2 minutes and are immediately authenticated without a second login step.
- **SC-002**: 90% of returning users log in successfully on first attempt with correct credentials; 100% of invalid-credential and rate-limited attempts show the correct specific error message (not a generic failure) within 1 second of response.
- **SC-003**: 100% of app restarts for a previously authenticated user restore the session without credential re-entry when tokens are still valid; silent token renewal succeeds in 100% of expired-access-token cases where the refresh token is still valid.
- **SC-004**: 100% of unauthorized navigation attempts (unauthenticated deep link, or authenticated user accessing a role-restricted route) are intercepted by guards and result in either a redirect to login or a friendly permission-denied message - zero crashes or raw errors.
- **SC-005**: Role-visibility is correct in 100% of inspected sessions: CUSTOMER never sees admin/warehouse controls, WAREHOUSE never sees admin-only product creation or audit, ADMIN sees all sections; verified across customer app and web dashboard.
- **SC-006**: Every auth action shows a loading state within 200ms of submission and disables duplicate submission; 100% of success and failure outcomes produce the specified user-visible feedback (success confirmation or categorized error with retry/guidance).
- **SC-007**: Zero authentication tokens are exposed in UI, logs, or error messages during any success or failure flow, and logout clears stored credentials in 100% of attempts so a subsequent launch requires re-authentication.

## Assumptions

- The backend described by `contracts/api/openapi.yaml` (endpoints `/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/me`) is available and is the source of truth for validation rules (password 8+ chars with letter+digit, unique username/email, JWT issuance, rate limiting). No backend changes are required for this spec.
- Registration via the public endpoint creates accounts with `ROLE_CUSTOMER` only; ADMIN and WAREHOUSE accounts are provisioned out-of-band (seeded or created by an existing admin) and are available for login but not self-registered through the customer app. The dashboards share the same auth endpoints with role-aware routing on success.
- Token lifetimes are server-controlled (e.g., access token short-lived such as 15 minutes, refresh token longer); the clients treat them as opaque and rely on server responses and the `expiresIn` hint, never computing expiry on the client clock.
- Secure storage per the constitution is available: encrypted/secure storage on mobile and httpOnly-equivalent or otherwise non-JavaScript-accessible storage on web where the platform allows; otherwise the most secure available storage is used and documented as a known limitation.
- English-only messages; every user-visible string lives in a centralized location in the shared core to allow future translation without code changes.
- This spec covers authentication and RBAC only. Password reset, email verification, profile editing, and fine-grained per-resource permissions beyond role + customer-own-orders scoping are out of scope and deferred to later specs.
- Real-time connection (STOMP over WebSocket) authenticates with the current access token and is established after login and re-established after token renewal; pushes are treated as hints and authoritative data is re-fetched over REST, per existing foundation decisions.
- Network reliability is assumed to be intermittent; offline-first persistent caching is not required for auth flows beyond the in-memory session cache already provided by the foundation - auth actions that fail due to network show retryable errors and do not leave partial state.

## Out of Scope

- Self-registration for ADMIN or WAREHOUSE roles through the UI.
- Password reset / forgot-password, email verification, and profile editing.
- Multi-factor authentication or social login (OAuth/SSO).
- Fine-grained permissions beyond role + customer-own-orders scoping (e.g., per-product or per-order ACLs).
- Production payment gateway, push notifications, and advanced analytics (per PRD).

## Dependencies

- Requires the foundation spec `001-project-foundation` to be implemented (shared core, secure storage, declarative routing, generated API client, error mapping, real-time plumbing, design tokens).
- Depends on the published contracts `contracts/api/openapi.yaml` and `contracts/ws/asyncapi-ws.md` as the sole API surface; any contract gap is a backend task, not a frontend workaround.

## Constitution Alignment

- **Clean Architecture**: Auth logic lives in domain/application layers with pure domain entities; UI depends inward on application, never on data internals.
- **State Management**: Auth state is reactive and immutable with standardized loading/error/data handling.
- **Security Tenets**: Tokens stored securely, transport secured, inputs sanitized, release builds obfuscated.
- **Presentation Principles**: Navigation is declarative with route guards enforcing auth and roles; every auth action has immediate feedback.
- **Testing Mandates**: Unit tests for validation and role-visibility rules, component tests for loading/error/empty states, flow tests for register→login→persist→refresh→logout and for role-gated navigation, mirroring backend integration scenarios.

