import 'package:la_madriguera/shared/models/usuario_model.dart';

abstract class AuthRepository {
  Future<UsuarioModel> login({
    required String email,
    required String password,
  });

  Future<UsuarioModel> register({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  });

  Future<void> logout();
}
