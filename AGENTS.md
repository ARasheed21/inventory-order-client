# inventory-order-client Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-09-09

## Active Technologies
- None persisted in this foundation — in-memory session-scoped cache only; (001-project-foundation)
- Dart 3 (null-safe); Flutter stable channel (`app/`), Jaspr current stable (`web/`) — per constitution 1.0.0 + implementation-guide §1-2 + Melos (workspace), Riverpod + riverpod_generator (reactive state), get_it (DI), Dio + dio interceptors (HTTP, JWT injection, single-flight refresh), fpdart `Either<Failure,T>` (error abstraction), go_router (mobile guards), jaspr_router (web guards), openapi-generator `dart-dio` (contract-driven client), flutter_secure_storage (mobile tokens), Sentry SDK (crash reporting per constitution IX), build_runner (codegen) (feature/002-account-and-role-based-access)
- Platform-secure token storage only — `flutter_secure_storage` (Android Keystore), web prefers server-set httpOnly Secure cookies for refresh token with access token in memory; fallback encrypted localStorage if httpOnly infeasible. No Drift/SQLite persisted in this feature; in-memory session-scoped cache (`core/data/cache/`) continues from foundation for read-heavy screens. Tokens never logged. (feature/002-account-and-role-based-access)

- Dart 3 (null-safe); Flutter stable channel (`app/`), Jaspr current stable (`web/`) + Melos (workspace), Riverpod + riverpod_generator (state), (001-project-foundation)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Dart 3 (null-safe); Flutter stable channel (`app/`), Jaspr current stable (`web/`)

## Code Style

Dart 3 (null-safe); Flutter stable channel (`app/`), Jaspr current stable (`web/`): Follow standard conventions

## Recent Changes
- feature/002-account-and-role-based-access: Added Dart 3 (null-safe); Flutter stable channel (`app/`), Jaspr current stable (`web/`) — per constitution 1.0.0 + implementation-guide §1-2 + Melos (workspace), Riverpod + riverpod_generator (reactive state), get_it (DI), Dio + dio interceptors (HTTP, JWT injection, single-flight refresh), fpdart `Either<Failure,T>` (error abstraction), go_router (mobile guards), jaspr_router (web guards), openapi-generator `dart-dio` (contract-driven client), flutter_secure_storage (mobile tokens), Sentry SDK (crash reporting per constitution IX), build_runner (codegen)
- 001-project-foundation: Added Dart 3 (null-safe); Flutter stable channel (`app/`), Jaspr current stable (`web/`) + Melos (workspace), Riverpod + riverpod_generator (state),

- 001-project-foundation: Added Dart 3 (null-safe); Flutter stable channel (`app/`), Jaspr current stable (`web/`) + Melos (workspace), Riverpod + riverpod_generator (state),

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
