import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/models/usuario_model.dart';

class AuthResponseDto {
  final String token;
  final UsuarioModel usuario;

  const AuthResponseDto({required this.token, required this.usuario});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final usuarioJson = data['usuario'] as Map<String, dynamic>;

    return AuthResponseDto(
      token: data['token'] as String,
      usuario: UsuarioModel(
        id: usuarioJson['id'].toString(),
        nombre: usuarioJson['nombre'] as String,
        correo: usuarioJson['email'] as String,
        rol: _rolFromBackend(usuarioJson['rol'] as String),
      ),
    );
  }

  static RolEnum _rolFromBackend(String rol) {
    switch (rol) {
      case 'CLIENTE':
        return RolEnum.cliente;
      case 'OPERADOR':
        return RolEnum.operador;
      case 'ADMIN':
        throw const FormatException(
          'El rol ADMIN no está habilitado en la app móvil pública.',
        );
      default:
        throw FormatException('Rol no soportado por la app móvil: $rol');
    }
  }
}
