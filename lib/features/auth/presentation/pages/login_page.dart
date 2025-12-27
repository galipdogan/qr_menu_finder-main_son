import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../routing/route_names.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/auth_event.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_state_listener.dart';
import '../widgets/auth_validators.dart';

/// Modern login page using clean architecture
/// 
/// Refactored to use reusable auth widgets for better maintainability
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ErrorMessages.login),
        backgroundColor: ThemeProvider.primary(context),
        foregroundColor: ThemeProvider.onPrimary(context),
      ),
      body: AuthStateListener(
        successMessage: 'Giriş başarılı!',
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Icon(
                        Icons.restaurant_menu,
                        size: 80,
                        color: ThemeProvider.primary(context),
                      ),
                      const SizedBox(height: 32),

                      // Email field
                      AuthTextField(
                        controller: _emailController,
                        labelText: 'E-posta',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                        validator: AuthValidators.email,
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      AuthPasswordField(
                        controller: _passwordController,
                        labelText: 'Şifre',
                        enabled: !isLoading,
                        validator: AuthValidators.password,
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      CustomButton(
                        text: ErrorMessages.login,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _handleLogin,
                      ),
                      const SizedBox(height: 16),

                      // Sign up link
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.go(RouteNames.signup),
                        child: const Text('Hesabınız yok mu? Kayıt olun'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }
}
