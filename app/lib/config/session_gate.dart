import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:core/core.dart';

import 'router.dart';

/// Reactive session state sourced from the auth repository (FR-005).
final StreamProvider<AsyncValue<Session?>> sessionStreamProvider =
    StreamProvider<AsyncValue<Session?>>((Ref ref) async* {
      await for (final Session? s in getIt<AuthRepository>().watchSession()) {
        yield AsyncValue<Session?>.data(s);
      }
    });

/// Convenience provider exposing the authenticated session or `null`.
final Provider<Session?> currentSessionProvider = Provider<Session?>((Ref ref) {
  return ref.watch(sessionStreamProvider).valueOrNull?.valueOrNull;
});

/// Route guard backed by the live session state (Constitution VI).
final class SessionAuthGate implements AuthGate {
  const SessionAuthGate(this.isAuthenticated);

  final bool Function() isAuthenticated;

  @override
  String? redirect(String location) {
    final bool authed = isAuthenticated();
    final bool onAuthRoute =
        location.startsWith('/login') || location.startsWith('/register');
    if (!authed && !onAuthRoute) return '/login';
    if (authed && onAuthRoute) return '/';
    return null;
  }
}

/// Bridges a broadcast stream into go_router's [refreshListenable].
final class RouterRefresh extends ChangeNotifier {
  RouterRefresh(Stream<dynamic> stream) {
    stream.listen(
      (dynamic _) => notifyListeners(),
      onError: (Object _) => notifyListeners(),
    );
  }
}
