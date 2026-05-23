import 'package:dio/dio.dart';
import 'package:la_madriguera/core/network/api_endpoints.dart';
import 'package:la_madriguera/core/network/dio_client.dart';
import 'package:la_madriguera/features/espacios/data/models/espacio_dto.dart';

class EspaciosRemoteDataSource {
  EspaciosRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<List<EspacioDto>> getEspacios({int? parqueoId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.espacios,
      queryParameters: {'parqueoId': ?parqueoId},
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];

    return data
        .map((item) => EspacioDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<EspacioDto> getEspacioById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.espacios}/$id',
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return EspacioDto.fromJson(data);
  }

  Future<EspacioDto> updateEstado({
    required int id,
    required String estado,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.espacios}/$id/estado',
      data: {'estado': estado},
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return EspacioDto.fromJson(data);
  }
}
