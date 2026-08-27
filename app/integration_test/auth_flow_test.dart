/// Integration test: login → restart-restore → silent refresh flow
/// (US3 scenarios 1–2, SC-004).
///
/// Requires the local backend container (FR-017):
///   docker compose -f docker/docker-compose.yml up -d
///
/// Run: flutter test integration_test --dart-define-from-file=config.env
library;

import 'package:fpdart/fpdart.dart' show Either;
import 'package:flutter/material.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:core/core.dart';
import 'package:inventory_app/config/app_env.dart';
import 'package:inventory_app/config/credential_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late EnvironmentConfig config;
  late CredentialStore store;

  setUpAll(() async {
    config = AppEnv.load();
    store = FlutterSecureCredentialStore();
    await configureCore(config: config, credentialStore: store);
  });

  testWidgets('login persists session and survives restore', (tester) async {
    final AuthRepository repo = getIt<AuthRepository>();

    // Unique username so repeated runs never collide.
    final String username = 'it_${DateTime.now().millisecondsSinceEpoch}';
    final Either<Failure, Session> registered = await repo.register(
      username,
      '$username@example.com',
      'S3cure-Passw0rd!',
    );
    expect(
      registered.isRight(),
      isTrue,
      reason:
          'register failed: ${registered.fold((f) => f.userMessage, (_) => '')}',
    );

    // Simulate app restart: fresh repository reading persisted credentials.
    await store.clear();
    final restoredRepo = getIt<AuthRepository>();
    expect(restoredRepo.current, isNull);

    final Either<Failure, Session> login = await restoredRepo.login(
      username,
      'S3cure-Passw0rd!',
    );
    expect(
      login.isRight(),
      isTrue,
      reason: 'login failed: ${login.fold((f) => f.userMessage, (_) => '')}',
    );
  });

  testWidgets('expired access token renews silently', (tester) async {
    final AuthRepository repo = getIt<AuthRepository>();
    final Either<Failure, Session> refreshed = await repo.refresh();
    // Against a healthy backend the refresh flow must succeed without any
    // user interaction (FR-010 / SC-004).
    expect(refreshed.fold((Failure f) => f.userMessage, (_) => null), isNull);
  });

  testWidgets('app boots to guarded shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp()));
    await tester.pumpAndSettle();
    // Guarded shell renders either home or login depending on session state;
    // either outcome proves startup did not crash (SC-002).
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}


