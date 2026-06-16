import 'package:dio/dio.dart';

import 'package:la_madriguera/core/network/api_endpoints.dart';
import 'package:la_madriguera/core/network/dio_client.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/models/usuario_model.dart';

class PerfilRemoteDataSource {
  PerfilRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<UsuarioModel> actualizarPerfil({
    required String nombre,
    String? passwordActual,
    String? passwordNueva,
  }) async {
    try {
      final body = <String, dynamic>{
        'nombre': nombre.trim(),
        if (passwordNueva != null && passwordNueva.isNotEmpty)
          'passwordActual': passwordActual,
        if (passwordNueva != null && passwordNueva.isNotEmpty)
          'passwordNueva': passwordNueva,
      };

      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.authUpdateMe,
        data: body,
      );

      final data = response.data?['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('La respuesta del servidor no es válida.');
      }

      return UsuarioModel(
        id: data['id'].toString(),
        nombre: data['nombre'] as String? ?? '',
        correo: data['email'] as String? ?? '',
        rol: _rolFromApi(data['rol'] as String?),
      );
    } on DioException catch (error) {
      throw Exception(_mensajeDio(error));
    }
  }

  RolEnum _rolFromApi(String? value) {
    switch (value?.toUpperCase()) {
      case 'OPERADOR':
        return RolEnum.operador;
      case 'CLIENTE':
      default:
        return RolEnum.cliente;
    }
  }

  String _mensajeDio(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'La conexión con el servidor tardó demasiado.';
      case DioExceptionType.connectionError:
        return 'No se pudo conectar con el servidor.';
      default:
        return 'No se pudo actualizar el perfil.';
    }
  }
}
