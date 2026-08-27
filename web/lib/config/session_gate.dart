// AuthGate is the shared guard contract; core exports domain types only.

/// Decides whether a route may be accessed in the current session state.
abstract interface class AuthGate {
  /// Returns the redirect location for [location], or `null` to allow.
  String? redirect(String location);
}

/// Route guard backed by the live session state (FR-005, web client).
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
