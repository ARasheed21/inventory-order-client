import 'package:flutter/material.dart';
import 'package:core/core.dart';

/// Reusable auth text field with design-token styling (Constitution VII).
///
/// Uses [AppColors], [AppSpacing], [AppRadius] — no raw color literals
/// (FR-004). All labels come from [AppStrings.auth] so future `.arb`
/// extraction is mechanical.
class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    // Resolve token colors (light mode for now; dark mode via Theme extension in plan)
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          // Error colors from tokens
          errorStyle: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
