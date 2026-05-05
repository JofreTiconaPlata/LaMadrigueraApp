import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  void _login(BuildContext context, WidgetRef ref, RolEnum rol) {
    ref.read(sessionProvider.notifier).state = SessionActions.buildUserByRole(
      rol,
    );

    Navigator.pushReplacementNamed(context, RouteNames.redirect);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('La Madriguera')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.local_parking, size: 90),
            const SizedBox(height: 16),
            const Text(
              'Bienvenido a La Madriguera',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _login(context, ref, RolEnum.cliente),
              child: const Text('Entrar como Cliente'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _login(context, ref, RolEnum.operador),
              child: const Text('Entrar como Operador'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _login(context, ref, RolEnum.administrador),
              child: const Text('Entrar como Administrador'),
            ),
          ],
        ),
      ),
    );
  }
}
