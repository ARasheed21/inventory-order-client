import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_form_field.dart';

/// Registration screen (FR-001..FR-004, SC-001).
///
/// - Validates locally via [Username], [Email], [Password] (T021-T023) before
///   any network call; maps `ValidationFailure` fields to inline errors.
/// - Shows distinct 400 (field) vs 409 (already registered) banners.
/// - Disables submit + shows spinner while `AuthAuthenticating` (SC-006).
/// - On 201 success, shows snackbar and navigates to catalog (auto-login).
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    super.key,
    this.authNotifier,
  });

  /// Injected for testability; defaults to `AuthNotifier(getIt<AuthRepository>())`.
  final AuthNotifier? authNotifier;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final AuthNotifier _notifier;

  String? _bannerMessage;
  bool _isBannerError = true;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _notifier = widget.authNotifier ??
        AuthNotifier(getIt<AuthRepository>());
    _notifier.addListener(_onAuthState);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onAuthState);
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onAuthState(AuthState state) {
    if (!mounted) return;
    if (state is AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.auth.registerSuccess)),
      );
      setState(() {
        _bannerMessage = null;
      });
      // Auto-login: navigate to catalog/home. Guard will also redirect,
      // but explicit go ensures immediate transition in manual. Guarded for tests without GoRouter.
      Future<void>.microtask(() {
        if (!mounted) return;
        final GoRouter? router = GoRouter.maybeOf(context);
        if (router != null) {
          context.go('/');
        }
      });
    } else if (state is AuthFailure) {
      final Failure f = state.failure;
      if (f is ValidationFailure) {
        if (f.fields.containsKey('username') ||
            f.fields.containsKey('email')) {
          // 409 already-registered is surfaced as ValidationFailure with both fields
          final String? msg =
              f.fields['username'] ?? f.fields['email'] ?? f.fields['_'];
          setState(() {
            _bannerMessage = msg ?? AppStrings.auth.alreadyRegistered;
            _isBannerError = true;
          });
        } else if (f.fields.isEmpty) {
          setState(() {
            _bannerMessage = f.userMessage;
            _isBannerError = true;
          });
        }
        // Otherwise field errors are shown inline via validator; no banner needed
      } else {
        setState(() {
          _bannerMessage = f.userMessage;
          _isBannerError = true;
        });
      }
    }
  }

  bool get _isLoading => _notifier.state is AuthAuthenticating;

  String? _validateUsername(String? v) {
    final result = Username.validate(v ?? '');
    return result.fold((ValidationFailure f) => f.fields['username'], (_) => null);
  }

  String? _validateEmail(String? v) {
    final result = Email.validate(v ?? '');
    return result.fold((ValidationFailure f) => f.fields['email'], (_) => null);
  }

  String? _validatePassword(String? v) {
    final result = Password.validate(v ?? '');
    return result.fold((ValidationFailure f) => f.fields['password'], (_) => null);
  }

  Future<void> _submit() async {
    setState(() {
      _bannerMessage = null;
    });
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    // Clear previous banner
    await _notifier.register(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    // State listener handles banner/snackbar.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.auth.registerTitle)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_bannerMessage != null)
                Builder(
                  builder: (BuildContext context) {
                    final ColorScheme scheme = Theme.of(context).colorScheme;
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: _isBannerError
                            ? scheme.errorContainer
                            : scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        _bannerMessage!,
                        key: const Key('banner'),
                        style: TextStyle(
                          color: _isBannerError
                              ? scheme.onErrorContainer
                              : scheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  },
                ),
              AuthFormField(
                controller: _usernameCtrl,
                label: AppStrings.auth.usernameLabel,
                hint: AppStrings.auth.usernameHint,
                validator: _validateUsername,
                keyboardType: TextInputType.text,
                autofillHints: const ['username'],
                textInputAction: TextInputAction.next,
              ),
              AuthFormField(
                controller: _emailCtrl,
                label: AppStrings.auth.emailLabel,
                hint: AppStrings.auth.emailHint,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const ['email'],
                textInputAction: TextInputAction.next,
              ),
              AuthFormField(
                controller: _passwordCtrl,
                label: AppStrings.auth.passwordLabel,
                hint: AppStrings.auth.passwordHint,
                obscureText: true,
                validator: _validatePassword,
                keyboardType: TextInputType.visiblePassword,
                autofillHints: const ['new-password'],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('registerButton'),
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppStrings.auth.registerAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
