import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart' as fp;

enum AuthMode { login, register }

/// Auth page proving the credential plumbing end to end (US3 web side).
class AuthPage extends StatefulComponent {
  const AuthPage({required this.mode, super.key});

  final AuthMode mode;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String _username = '';
  String _email = '';
  String _password = '';
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final AuthRepository repo = getIt<AuthRepository>();
    final fp.Either<Failure, Session> result = component.mode == AuthMode.login
        ? await repo.login(_username.trim(), _password)
        : await repo.register(_username.trim(), _email.trim(), _password);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (Failure failure) => setState(() => _error = failure.userMessage),
      (_) {},
    );
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'auth', [
      h1([
        .text(
          component.mode == AuthMode.login
              ? AppStrings.auth.loginTitle
              : AppStrings.auth.registerTitle,
        ),
      ]),
      if (_error != null) p(classes: 'error', [.text(_error!)]),
      input<String>(
        type: InputType.text,
        attributes: {'placeholder': AppStrings.auth.usernameLabel},
        onInput: (String value) => _username = value,
      ),
      if (component.mode == AuthMode.register)
        input<String>(
          type: InputType.email,
          attributes: {'placeholder': AppStrings.auth.emailLabel},
          onInput: (String value) => _email = value,
        ),
      input<String>(
        type: InputType.password,
        attributes: {'placeholder': AppStrings.auth.passwordLabel},
        onInput: (String value) => _password = value,
      ),
      button(onClick: _submitting ? null : () => unawaited(_submit()), [
        .text(_label),
      ]),
      p(classes: 'muted', [.text('Use the app header links to switch mode.')]),
    ]);
  }

  String get _label => component.mode == AuthMode.login
      ? AppStrings.auth.signInAction
      : AppStrings.auth.registerAction;
}
