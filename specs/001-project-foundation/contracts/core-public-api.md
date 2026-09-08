# Core Package Public API Contract

**Branch**: `001-project-foundation` | **Date**: 2026-08-25

This defines the interface `core/` exposes to the `app/` and `web/` clients. Per Constitution
Principle II, this contract is exposed through a single entry point (`package:core/core.dart`);
clients MUST NOT import any other path from the core package. The export-integrity quality gate
enforces this.

## Exported Surfaces

### 1. Design tokens
```dart
// Theme binding for platform apps.
AppColors   // semantic color roles with light/dark variants
AppSpacing  // spacing scale
AppRadius   // corner radii scale
AppTypography // type scale
```
Rule: platforms bind these into their theming system at startup; they never define their own
visual constants.

### 2. Strings registry
```dart
/// All user-visible strings, grouped per feature. i18n-ready keyed constants.
class AppStrings { ... }
```

### 3. Session & auth application API
```dart
/// Observable session state; drives route guards and role visibility.
final sessionProvider // Stream/AuthState of AsyncState<Session?>

abstract class AuthRepository {
  Future<Either<Failure, Session>> login(String username, String password);
  Future<Either<Failure, Session>> register(String username, String email, String password);
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, Session>> refresh();      // silent renewal (FR-010)
  Stream<Session?> watchSession();                 // reactive session (restart restore)
}
```

### 4. Failure hierarchy
```dart
sealed class Failure {}
final class NetworkFailure extends Failure {}
final class AuthenticationFailure extends Failure {}
final class AuthorizationFailure extends Failure {}
final class ServerFailure extends Failure {}
final class ValidationFailure extends Failure { final Map<String, String> fields; }
final class UnknownFailure extends Failure {}
```

### 5. AsyncState union
```dart
sealed class AsyncState<T> {
  const factory AsyncState.loading() = Loading<T>;
  const factory AsyncState.data(T value) = Data<T>;
  const factory AsyncState.error(Failure failure) = Error<T>;
}
```

### 6. Cache port (in-memory)
```dart
abstract class ReadCache {
  T? get<T>(ResourceKey key);
  void put<T>(ResourceKey key, T payload);
  void invalidate(ResourceKey key);
  void clear();                                   // on logout
}
```

### 7. Realtime hint bus
```dart
/// Emits decoded contract pushes as hints; consumers re-fetch over REST.
final realtimeHintsProvider // Stream<RealtimeHint>
sealed class RealtimeHint { final String orderId; }
final class OrderStatusHint extends RealtimeHint { final OrderStatus status; final String? reason; }
```

### 8. Observability facade
```dart
abstract class Reporter {
  void log(AppLogLevel level, String event, {Map<String, Object?> context});
  void recordError(Object error, {StackTrace? stack, Map<String, Object?> context});
}
```
Platforms initialize the concrete crash-reporting binding in `main()` before running the app.

## Non-Exported (internal) Surfaces

The following live under internal folders and are NEVER exported: generated API client wiring,
Dio interceptors, token storage implementations, STOMP transport adapters, cache
implementations, get_it registration internals.

## Versioning

Core follows the repository's Conventional Commits versioning. Any breaking change to an
exported surface requires a MAJOR bump and simultaneous migration of both clients in the same
PR.
