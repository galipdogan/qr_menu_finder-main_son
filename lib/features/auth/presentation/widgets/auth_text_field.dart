import 'package:flutter/material.dart';

/// Reusable text field widget for authentication forms
/// 
/// Provides consistent styling and validation across login/signup pages
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int? maxLength;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.suffixIcon,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? null : '',
      ),
      validator: validator,
    );
  }
}

/// Password field with visibility toggle
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final String? Function(String?)? validator;
  final IconData prefixIcon;

  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    this.enabled = true,
    this.validator,
    this.prefixIcon = Icons.lock,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      prefixIcon: widget.prefixIcon,
      obscureText: _obscureText,
      enabled: widget.enabled,
      validator: widget.validator,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}
