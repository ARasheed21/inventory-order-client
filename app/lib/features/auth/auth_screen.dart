import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';

import 'package:core/core.dart';

enum AuthMode { login, register }

/// Auth screen proving the credential plumbing end to end (US3).
/// Failures surface as friendly, categorized messages — never raw errors.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({required this.mode, super.key});

  final AuthMode mode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final AuthRepository repo = getIt<AuthRepository>();
    final Either<Failure, Session> result = widget.mode == AuthMode.login
        ? await repo.login(_username.text.trim(), _password.text)
        : await repo.register(
            _username.text.trim(),
            _email.text.trim(),
            _password.text,
          );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (Failure failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.userMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (_) {
        // Successful auth triggers the route guard to redirect home.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == AuthMode.login
              ? AppStrings.auth.loginTitle
              : AppStrings.auth.registerTitle,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _username,
                  decoration: InputDecoration(
                    labelText: AppStrings.auth.usernameLabel,
                  ),
                ),
                if (widget.mode == AuthMode.register) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppStrings.auth.emailLabel,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: AppStrings.auth.passwordLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.mode == AuthMode.login
                              ? AppStrings.auth.signInAction
                              : AppStrings.auth.registerAction,
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.go(
                    widget.mode == AuthMode.login ? '/register' : '/login',
                  ),
                  child: Text(
                    widget.mode == AuthMode.login
                        ? AppStrings.auth.registerTitle
                        : AppStrings.auth.loginTitle,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
