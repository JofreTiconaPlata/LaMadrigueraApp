import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/core/storage/local_storage_service.dart';
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
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  List<Widget> _optionsByRole(
    BuildContext context,
    WidgetRef ref,
    RolEnum? rol,
  ) {
    final commonOptions = <Widget>[
      _option(icon: Icons.badge_outlined, title: 'Mis datos', onTap: () {}),
      _option(icon: Icons.settings, title: 'Configuración', onTap: () {}),
    ];

    if (rol == RolEnum.operador) {
      return [
        ...commonOptions,
        _option(
          icon: Icons.local_parking,
          title: 'Parqueo asignado',
          onTap: () {},
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
      ...commonOptions,
      _option(
        icon: Icons.directions_car_outlined,
        title: 'Mis vehículos',
        onTap: () {},
      ),
      _option(
        icon: Icons.history,
        title: 'Historial de reservas',
        onTap: () {
          Navigator.pushNamed(context, RouteNames.historial);
        },
      ),
    ];
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    ref.read(sessionProvider.notifier).state = null;
    await LocalStorageService.clearToken();

    if (!context.mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (_) => false);
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
              backgroundColor: Color(0xFF2E7D32),
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
              usuario?.rol == RolEnum.operador ? 'Operador' : 'Cliente',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ..._optionsByRole(context, ref, usuario?.rol),
            const SizedBox(height: 8),
            _option(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              onTap: () => _logout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
