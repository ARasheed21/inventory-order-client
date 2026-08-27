import 'package:fpdart/fpdart.dart';

import '../entities/session.dart';
import '../failures.dart';

/// Domain contract for authentication flows.
///
/// Interface lives in Domain; implementations belong in Data (Constitution V).
abstract interface class AuthRepository {
  Future<Either<Failure, Session>> login(String username, String password);

  Future<Either<Failure, Session>> register(
    String username,
    String email,
    String password,
  );

  Future<Either<Failure, void>> logout();

  /// Silent renewal of an expired/expiring access token (FR-010).
  Future<Either<Failure, Session>> refresh();

  /// Reactive session stream; emits `null` when logged out (FR-005 guards).
  Stream<Session?> watchSession();

  /// Currently known session or `null`.
  Session? get current;
}
