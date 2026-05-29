import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _registrando = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrarUsuario() async {
    final formularioValido = _formKey.currentState?.validate() ?? false;

    if (!formularioValido || _registrando) {
      return;
    }

    setState(() {
      _registrando = true;
      _errorMessage = null;
    });

    try {
      final repository = AuthRepositoryImpl();

      final usuario = await repository.register(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      ref.read(sessionProvider.notifier).state = usuario;

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, RouteNames.redirect);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'No se pudo crear la cuenta. Verifica los datos.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _registrando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Ingresa tu nombre completo';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return 'Ingresa tu correo';
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
                  if (value == null || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }

                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _registrando ? null : _registrarUsuario,
                  child: _registrando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Registrarme'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
