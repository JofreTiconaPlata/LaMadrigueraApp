import 'package:dio/dio.dart';

import 'package:la_madriguera/core/network/api_endpoints.dart';
import 'package:la_madriguera/core/network/dio_client.dart';
import 'package:la_madriguera/features/ingresos/data/models/ingreso_dto.dart';

class IngresosRemoteDataSource {
  IngresosRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<List<IngresoDto>> getIngresos({int? parqueoId, String? estado}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.ingresos,
      queryParameters: {
        'parqueoId': ?parqueoId,
        if (estado != null && estado.isNotEmpty) 'estado': estado,
      },
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];

    return data
        .map((item) => IngresoDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<IngresoDto>> getIngresosActivos({int? parqueoId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.ingresosActivos,
      queryParameters: {'parqueoId': ?parqueoId},
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];

    return data
        .map((item) => IngresoDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<IngresoDto> getIngresoById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.ingresos}/$id',
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return IngresoDto.fromJson(data);
  }

  Future<IngresoDto> registrarIngreso({
    int? reservaId,
    required int parqueoId,
    required int espacioId,
    required int vehiculoId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.ingresos,
      data: {
        'reservaId': ?reservaId,
        'parqueoId': parqueoId,
        'espacioId': espacioId,
        'vehiculoId': vehiculoId,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return IngresoDto.fromJson(data);
  }

  Future<IngresoDto> cancelarIngreso(int id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.ingresos}/$id/cancelar',
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return IngresoDto.fromJson(data);
  }
}
