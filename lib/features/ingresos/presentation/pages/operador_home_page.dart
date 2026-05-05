import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class OperadorHomePage extends ConsumerWidget {
  const OperadorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Operador'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(sessionProvider.notifier).state = null;
              Navigator.pushReplacementNamed(context, RouteNames.login);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bienvenido ${usuario?.nombre ?? 'Operador'}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
