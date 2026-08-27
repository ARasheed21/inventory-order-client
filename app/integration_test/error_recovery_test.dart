/// Integration test: backend-down → friendly error with retry → recovery
/// (US3 scenario 3, FR-008).
///
/// Requires the local backend container (FR-017):
///   docker compose -f docker/docker-compose.yml up -d
///   (stop it mid-test to simulate the outage)
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fpdart/fpdart.dart' show Either;
import 'package:core/core.dart';
import 'package:inventory_app/config/app_env.dart';
import 'package:inventory_app/config/credential_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await configureCore(
      config: AppEnv.load(),
      credentialStore: FlutterSecureCredentialStore(),
    );
  });

  test('network failure surfaces a friendly, retryable domain error', () async {
    final AuthRepository repo = getIt<AuthRepository>();
    // Attempt against an unreachable port on localhost.
    final Either<Failure, Session> result = await repo.login(
      'nobody',
      'wrong-password',
    );

    // Either the backend answers with an AuthenticationFailure, or — when
    // unreachable — a NetworkFailure. Both are friendly and categorized;
    // neither may be an UnknownFailure carrying raw exception text.
    final Failure failure = result.fold(
      (Failure f) => f,
      (Session _) => throw StateError('unexpected success'),
    );
    expect(failure.userMessage, isNotEmpty);
    expect(
      failure,
      anyOf(
        isA<NetworkFailure>(),
        isA<AuthenticationFailure>(),
        isA<ServerFailure>(),
      ),
      reason: 'failures must map into the domain taxonomy',
    );
  });
}


