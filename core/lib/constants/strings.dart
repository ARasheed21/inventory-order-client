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

  String get usernameHint => '3–30 characters, letters, digits, dot, underscore or hyphen';

  String get usernameValidation =>
      'Username must be 3–30 characters, letters, digits, dot, underscore or hyphen only';

  String get emailLabel => 'Email';

  String get emailInvalid => 'Please enter a valid email address';

  String get passwordLabel => 'Password';

  String get passwordHint => 'At least 8 characters with a letter and a digit';

  String get passwordValidation =>
      'Password must be 8–128 characters and contain a letter and a digit';

  String get signInAction => 'Sign in';

  String get registerAction => 'Register';

  String get alreadyRegistered => 'Username or email already registered.';

  String get invalidCredentials => 'Invalid username or password.';

  String get rateLimited => 'Too many attempts. Try again in %s seconds.';

  String get sessionExpired => 'Your session has expired. Please sign in again.';

  String get permissionDenied => "You don't have permission to do that.";

  String get requiredField => 'This field is required';

  String get registerSuccess => 'Account created — welcome!';

  String get emailHint => 'alice@example.com';
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
