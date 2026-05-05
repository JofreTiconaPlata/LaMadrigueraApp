import 'package:la_madriguera/shared/enums/rol_enum.dart';

class UsuarioModel {
  final String id;
  final String nombre;
  final String correo;
  final RolEnum rol;

  const UsuarioModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  UsuarioModel copyWith({
    String? id,
    String? nombre,
    String? correo,
    RolEnum? rol,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
    );
  }
}
