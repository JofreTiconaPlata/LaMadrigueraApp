import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/features/auth/presentation/providers/login_provider.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final usuario = await ref
        .read(loginProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted || usuario == null) {
      return;
    }

    ref.read(sessionProvider.notifier).state = usuario;

    Navigator.pushReplacementNamed(context, RouteNames.redirect);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_parking,
                      size: 90,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'La Madriguera',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Encuentra y administra parqueos fácilmente'),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Ingresa tu correo electrónico';
                        }

                        if (!email.contains('@')) {
                          return 'Ingresa un correo válido';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu contraseña';
                        }

                        return null;
                      },
                    ),
                    if (loginState.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        loginState.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loginState.isLoading ? null : _submitLogin,
                        child: loginState.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Iniciar sesión'),
                      ),
                    ),
                    TextButton(
                      onPressed: loginState.isLoading
                          ? null
                          : () => Navigator.pushNamed(
                              context,
                              RouteNames.register,
                            ),
                      child: const Text('Crear cuenta nueva'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
