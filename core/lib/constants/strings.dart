/// Centralized user-visible strings (FR-015).
///
/// Grouped per feature. No inline string literals are allowed in widgets.
/// The structure is intentionally key-based so future `.arb` extraction is
/// mechanical when i18n arrives (English-only for now, per PRD).
library;

final class CommonStrings {
  const CommonStrings();

  String get appName => 'Inventory Manager';

  String get retry => 'Retry';

  String get cancel => 'Cancel';

  String get signOut => 'Sign out';

  String get loading => 'Loading…';

  String get staleData => 'Showing saved information — may be out of date.';
}

final class AuthStrings {
  const AuthStrings();

  String get loginTitle => 'Sign in';

  String get registerTitle => 'Create account';

  String get usernameLabel => 'Username';

  String get emailLabel => 'Email';

  String get passwordLabel => 'Password';

  String get signInAction => 'Sign in';

  String get registerAction => 'Register';
}

final class HomeStrings {
  const HomeStrings();

  String get title => 'Home';

  String get placeholderBody =>
      'Foundation ready. Feature screens arrive with the next epics.';
}

abstract final class AppStrings {
  static const CommonStrings common = CommonStrings();
  static const AuthStrings auth = AuthStrings();
  static const HomeStrings home = HomeStrings();
}
