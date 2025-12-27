import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../routing/route_names.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/auth_event.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_form_layout.dart';
import '../widgets/auth_state_listener.dart';
import '../widgets/auth_validators.dart';

/// Signup page - Clean Architecture implementation
/// 
/// Refactored to use reusable auth widgets for better maintainability
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Oluştur'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: AuthStateListener(
        successMessage: 'Hesap başarıyla oluşturuldu!',
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return AuthFormLayout(
              title: 'Yeni Hesap Oluştur',
              logoColor: AppColors.primary,
              formContent: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    AuthTextField(
                      controller: _nameController,
                      labelText: 'Ad Soyad',
                      prefixIcon: Icons.person,
                      enabled: !isLoading,
                      validator: AuthValidators.displayName,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    AuthTextField(
                      controller: _emailController,
                      labelText: 'E-posta',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    AuthPasswordField(
                      controller: _passwordController,
                      labelText: 'Şifre',
                      enabled: !isLoading,
                      validator: AuthValidators.password,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    AuthPasswordField(
                      controller: _confirmPasswordController,
                      labelText: 'Şifre Tekrar',
                      prefixIcon: Icons.lock_outline,
                      enabled: !isLoading,
                      validator: AuthValidators.confirmPassword(
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Signup Button
                    CustomButton(
                      text: 'Hesap Oluştur',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _handleSignup,
                    ),
                  ],
                ),
              ),
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Zaten hesabınız var mı? '),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.go(RouteNames.login),
                    child: const Text(ErrorMessages.login),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        ),
      );
    }
  }
}
