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

  static String _favoriteParqueosKey(String userId) {
    return 'favorite_parqueos_$userId';
  }

  static Future<List<int>> getFavoriteParqueoIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_favoriteParqueosKey(userId)) ?? [];

    return values.map((value) => int.tryParse(value)).whereType<int>().toList();
  }

  static Future<void> saveFavoriteParqueoIds(
    String userId,
    List<int> parqueoIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final values = parqueoIds.toSet().map((id) => id.toString()).toList();

    await prefs.setStringList(_favoriteParqueosKey(userId), values);
  }

  static Future<void> toggleFavoriteParqueo({
    required String userId,
    required int parqueoId,
  }) async {
    final currentIds = await getFavoriteParqueoIds(userId);
    final updatedIds = currentIds.toSet();

    if (updatedIds.contains(parqueoId)) {
      updatedIds.remove(parqueoId);
    } else {
      updatedIds.add(parqueoId);
    }

    await saveFavoriteParqueoIds(userId, updatedIds.toList());
  }
}
