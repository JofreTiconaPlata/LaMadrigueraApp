import 'package:dio/dio.dart';
import 'package:la_madriguera/core/network/api_endpoints.dart';
import 'package:la_madriguera/core/network/dio_client.dart';
import 'package:la_madriguera/features/auth/data/models/auth_response_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );

    return AuthResponseDto.fromJson(response.data!);
  }

  Future<AuthResponseDto> register({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
    String rol = 'CLIENTE',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.authRegister,
      data: {
        'nombre': nombre,
        'email': email,
        'password': password,
        if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
        'rol': rol,
      },
    );

    return AuthResponseDto.fromJson(response.data!);
  }
}
