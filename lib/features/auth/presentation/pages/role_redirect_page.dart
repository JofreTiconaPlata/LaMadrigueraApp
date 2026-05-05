import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class RoleRedirectPage extends ConsumerWidget {
  const RoleRedirectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sessionProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (usuario == null) {
        Navigator.pushReplacementNamed(context, RouteNames.login);
        return;
      }

      switch (usuario.rol) {
        case RolEnum.cliente:
          Navigator.pushReplacementNamed(context, RouteNames.clienteHome);
          break;
        case RolEnum.operador:
          Navigator.pushReplacementNamed(context, RouteNames.operadorHome);
          break;
        case RolEnum.administrador:
          Navigator.pushReplacementNamed(context, RouteNames.adminHome);
          break;
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
