import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/models/usuario_model.dart';

class LocalStorageService {
  LocalStorageService._();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUser(UsuarioModel usuario) async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = jsonEncode({
      'id': usuario.id,
      'nombre': usuario.nombre,
      'correo': usuario.correo,
      'rol': usuario.rol.name,
    });

    await prefs.setString(_userKey, userJson);
  }

  static Future<UsuarioModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString == null || userString.isEmpty) {
      return null;
    }

    final data = jsonDecode(userString) as Map<String, dynamic>;
    final rolName = data['rol'] as String? ?? 'cliente';

    final rol = RolEnum.values.firstWhere(
      (item) => item.name == rolName,
      orElse: () => RolEnum.cliente,
    );

    return UsuarioModel(
      id: data['id'].toString(),
      nombre: data['nombre'] as String? ?? '',
      correo: data['correo'] as String? ?? '',
      rol: rol,
    );
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
