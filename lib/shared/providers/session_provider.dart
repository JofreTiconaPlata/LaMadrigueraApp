import 'package:flutter_riverpod/legacy.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/models/usuario_model.dart';

final sessionProvider = StateProvider<UsuarioModel?>((ref) => null);

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