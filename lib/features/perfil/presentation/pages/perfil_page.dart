import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class PerfilPage extends ConsumerWidget {
  const PerfilPage({super.key});

  Widget _option({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  List<Widget> _optionsByRole(BuildContext context, RolEnum? rol) {
    if (rol == RolEnum.operador) {
      return [
        _option(
          icon: Icons.local_parking,
          title: 'Mi parqueo',
          onTap: () {
            Navigator.pushNamed(context, RouteNames.espacios);
          },
        ),
        _option(
          icon: Icons.history,
          title: 'Historial de operaciones',
          onTap: () {
            Navigator.pushNamed(context, RouteNames.historial);
          },
        ),
      ];
    }

    return [
      _option(
        icon: Icons.history,
        title: 'Historial de reservas',
        onTap: () {
          Navigator.pushNamed(context, RouteNames.historial);
        },
      ),
    ];
  }

  String _rolLabel(RolEnum? rol) {
    switch (rol) {
      case RolEnum.operador:
        return 'Operador';
      case RolEnum.administrador:
        return 'Administrador';
      case RolEnum.cliente:
      case null:
        return 'Cliente';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 12),
            Text(
              usuario?.nombre ?? 'Usuario La Madriguera',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              usuario?.correo ?? 'usuario@gmail.com',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              _rolLabel(usuario?.rol),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ..._optionsByRole(context, usuario?.rol),
          ],
        ),
      ),
    );
  }
}
