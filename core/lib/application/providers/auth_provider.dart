import 'package:meta/meta.dart';

import '../../domain/entities/session.dart';
import '../../domain/failures.dart';
import '../../domain/repositories/auth_repository.dart';

/// UI-agnostic auth state (Constitution III, data-model.md §6).
///
/// Sealed union: initial → authenticating → authenticated / failure.
/// `unauthenticated` is an alias for `initial` after a logout.
@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthAuthenticating extends AuthState {
  const AuthAuthenticating();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);
  final Session session;
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.failure);
  final Failure failure;
}

/// Thin orchestration over [AuthRepository] for the presentation layer.
///
/// Keeps business rules in core while remaining framework-agnostic
/// (no Flutter/Riverpod import in domain/application). The `app` and `web`
/// packages may wrap this with a `StateNotifier`/`Riverpod` provider.
final class AuthNotifier {
  AuthNotifier(this._repository) : _state = const AuthInitial();

  final AuthRepository _repository;

  AuthState _state;
  AuthState get state => _state;

  final List<void Function(AuthState)> _listeners = [];

  void addListener(void Function(AuthState) listener) =>
      _listeners.add(listener);

  void removeListener(void Function(AuthState) listener) =>
      _listeners.remove(listener);

  void _emit(AuthState next) {
    _state = next;
    for (final l in List.of(_listeners)) {
      l(next);
    }
  }

  /// Registers a new customer and immediately authenticates on success (FR-004).
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _emit(const AuthAuthenticating());
    final result = await _repository.register(username, email, password);
    result.fold(
      (Failure f) => _emit(AuthFailure(f)),
      (Session s) => _emit(AuthAuthenticated(s)),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    _emit(const AuthInitial());
  }

  void reset() => _emit(const AuthInitial());
}
