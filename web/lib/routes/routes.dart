import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'package:core/core.dart';

import '../pages/auth_page.dart';
import '../pages/home_page.dart';
import '../config/session_gate.dart';

/// Declarative routing with authentication guards (FR-005, web client).
Component buildAppRouter(AuthGate gate) => Router(
  redirect: (context, state) => gate.redirect(state.location),
  routes: <RouteBase>[
    Route(
      path: '/',
      title: AppStrings.home.title,
      builder: (context, state) => const HomePage(),
    ),
    Route(
      path: '/login',
      title: AppStrings.auth.loginTitle,
      builder: (context, state) => const AuthPage(mode: AuthMode.login),
    ),
    Route(
      path: '/register',
      title: AppStrings.auth.registerTitle,
      builder: (context, state) => const AuthPage(mode: AuthMode.register),
    ),
  ],
);
