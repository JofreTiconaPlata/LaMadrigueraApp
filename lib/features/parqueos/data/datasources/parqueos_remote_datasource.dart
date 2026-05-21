import 'package:dio/dio.dart';
import 'package:la_madriguera/core/network/api_endpoints.dart';
import 'package:la_madriguera/core/network/dio_client.dart';
import 'package:la_madriguera/features/parqueos/data/models/parqueo_dto.dart';

class ParqueosRemoteDataSource {
  ParqueosRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<List<ParqueoDto>> getParqueos() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.parqueos,
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];

    return data
        .map((item) => ParqueoDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ParqueoDto> getParqueoById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.parqueos}/$id',
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return ParqueoDto.fromJson(data);
  }
}
