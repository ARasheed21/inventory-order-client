import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';

import 'package:inventory_app/features/auth/presentation/screens/registration_screen.dart';

/// Fake repository that simulates 409 already-registered for specific inputs.
class FakeAuthRepository409 implements AuthRepository {
  @override
  Future<Either<Failure, Session>> register(String username, String email, String password) async {
    if (username == 'takenuser' || email == 'taken@example.com') {
      return const Left(
        ValidationFailure(fields: {
          'username': 'Username or email already registered.',
          'email': 'Username or email already registered.',
        }),
      );
    }
    return Right(
      Session(
        userId: 'u1',
        username: username,
        role: Role.customer,
        accessToken: 'access',
        refreshToken: 'refresh',
        accessExpiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<Either<Failure, Session>> login(String username, String password) async =>
      const Left(AuthenticationFailure());

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, Session>> refresh() async => const Left(AuthenticationFailure());

  @override
  Session? get current => null;

  @override
  Stream<Session?> watchSession() => const Stream.empty();
}

void main() {
  group('RegistrationScreen', () {
    testWidgets('shows username, email, password fields and register button', (WidgetTester tester) async {
      final notifier = AuthNotifier(FakeAuthRepository409());
      await tester.pumpWidget(
        MaterialApp(home: RegistrationScreen(authNotifier: notifier)),
      );
      expect(find.text(AppStrings.auth.usernameLabel), findsOneWidget);
      expect(find.text(AppStrings.auth.emailLabel), findsOneWidget);
      expect(find.text(AppStrings.auth.passwordLabel), findsOneWidget);
      expect(find.byKey(const Key('registerButton')), findsOneWidget);
      expect(find.text(AppStrings.auth.registerAction), findsOneWidget);
    });

    testWidgets('shows inline validation errors on empty submit', (WidgetTester tester) async {
      final notifier = AuthNotifier(FakeAuthRepository409());
      await tester.pumpWidget(
        MaterialApp(home: RegistrationScreen(authNotifier: notifier)),
      );
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pump();
      // Username validation: required / 3-30
      expect(find.text('Username is required'), findsWidgets);
      // Password field also shows required
      expect(find.text('Password is required'), findsWidgets);
    });

    testWidgets('shows username charset error for too short', (WidgetTester tester) async {
      final notifier = AuthNotifier(FakeAuthRepository409());
      await tester.pumpWidget(
        MaterialApp(home: RegistrationScreen(authNotifier: notifier)),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'ab');
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pump();
      expect(
        find.text(
          'Username must be 3–30 characters, letters, digits, dot, underscore or hyphen only',
        ),
        findsOneWidget,
      );
    });

    testWidgets('disables button and shows spinner while authenticating', (WidgetTester tester) async {
      // Use a repository that delays to keep authenticating state visible
      final delayedRepo = _DelayedAuthRepository();
      final notifier = AuthNotifier(delayedRepo);
      await tester.pumpWidget(
        MaterialApp(home: RegistrationScreen(authNotifier: notifier)),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'validuser');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'Secr3tPwd1');
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pump(); // start authenticating
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final ElevatedButton button = tester.widget<ElevatedButton>(find.byKey(const Key('registerButton')));
      expect(button.onPressed, isNull);
      // Complete
      await tester.pumpAndSettle();
    });

    testWidgets('shows 409 banner when username already registered', (WidgetTester tester) async {
      final notifier = AuthNotifier(FakeAuthRepository409());
      await tester.pumpWidget(
        MaterialApp(home: RegistrationScreen(authNotifier: notifier)),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'takenuser');
      await tester.enterText(find.byType(TextFormField).at(1), 'taken@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'Secr3tPwd1');
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('banner')), findsOneWidget);
      expect(find.textContaining('already registered'), findsOneWidget);
    });
  });
}

class _DelayedAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, Session>> register(String username, String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return Right(
      Session(
        userId: 'u1',
        username: username,
        role: Role.customer,
        accessToken: 'a',
        refreshToken: 'r',
        accessExpiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<Either<Failure, Session>> login(String username, String password) async =>
      const Left(AuthenticationFailure());

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, Session>> refresh() async => const Left(AuthenticationFailure());

  @override
  Session? get current => null;

  @override
  Stream<Session?> watchSession() => const Stream.empty();
}
