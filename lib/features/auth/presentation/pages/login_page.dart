import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.local_parking,
                    size: 90,
                    color: Color(0xFF2E7D32),
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
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(sessionProvider.notifier).state =
                            SessionActions.buildUserByRole(RolEnum.operador);

                        Navigator.pushReplacementNamed(
                          context,
                          RouteNames.redirect,
                        );
                      },
                      child: const Text('Iniciar sesión'),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.register),
                    child: const Text('Crear cuenta nueva'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}