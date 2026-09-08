import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/home/home_screen.dart';

/// Declarative navigation shell with authentication guards (FR-005).
///
/// The [AuthGate] implementation is supplied by the session state
/// ([SessionAuthGate]); unauthenticated users are routed to /login.

/// Decides whether a route may be accessed in the current session state.
abstract interface class AuthGate {
  /// Returns the redirect location for [location], or `null` to allow.
  String? redirect(String location);
}

GoRouter buildAppRouter(AuthGate gate, {Listenable? refreshListenable}) =>
    GoRouter(
      initialLocation: '/',
      refreshListenable: refreshListenable,
      redirect: (BuildContext context, GoRouterState state) =>
          gate.redirect(state.matchedLocation),
      routes: <RouteBase>[
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) =>
              HomeShell(child: child),
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              name: 'home',
              builder: (BuildContext context, GoRouterState state) =>
                  const HomeScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (BuildContext context, GoRouterState state) =>
              const AuthScreen(mode: AuthMode.login),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (BuildContext context, GoRouterState state) =>
              const AuthScreen(mode: AuthMode.register),
        ),
      ],
    );

class HomeShell extends StatelessWidget {
  const HomeShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Bottom navigation bar arrives with feature epics; the shell is ready.
    return Scaffold(body: child);
  }
}
