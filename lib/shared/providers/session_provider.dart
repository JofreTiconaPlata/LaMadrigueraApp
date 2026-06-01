import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;

import 'package:la_madriguera/core/storage/local_storage_service.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/models/usuario_model.dart';

final sessionProvider = legacy.StateProvider<UsuarioModel?>((ref) => null);

final sessionInitializerProvider = FutureProvider<UsuarioModel?>((ref) async {
  final token = await LocalStorageService.getToken();

  if (token == null || token.isEmpty) {
    ref.read(sessionProvider.notifier).state = null;
    return null;
  }

  final usuario = await LocalStorageService.getUser();

  if (usuario == null) {
    ref.read(sessionProvider.notifier).state = null;
    return null;
  }

  ref.read(sessionProvider.notifier).state = usuario;
  return usuario;
});

class SessionActions {
  static UsuarioModel buildUserByRole(RolEnum rol) {
    switch (rol) {
      case RolEnum.cliente:
        return const UsuarioModel(
          id: '1',
          nombre: 'Cliente Demo',
          correo: 'cliente@demo.com',
          rol: RolEnum.cliente,
        );
      case RolEnum.operador:
        return const UsuarioModel(
          id: '2',
          nombre: 'Operador Demo',
          correo: 'operador@demo.com',
          rol: RolEnum.operador,
        );
      case RolEnum.administrador:
        return const UsuarioModel(
          id: '3',
          nombre: 'Administrador Demo',
          correo: 'admin@demo.com',
          rol: RolEnum.administrador,
        );
    }
  }
}
