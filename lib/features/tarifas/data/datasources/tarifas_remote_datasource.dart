import 'package:dio/dio.dart';
import 'package:la_madriguera/core/network/api_endpoints.dart';
import 'package:la_madriguera/core/network/dio_client.dart';
import 'package:la_madriguera/features/tarifas/data/models/tarifa_dto.dart';

class TarifasRemoteDataSource {
  TarifasRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<List<TarifaDto>> getTarifas({
    int? parqueoId,
    String? tipoVehiculo,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.tarifas,
      queryParameters: {'parqueoId': ?parqueoId, 'tipoVehiculo': ?tipoVehiculo},
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];

    return data
        .map((item) => TarifaDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TarifaDto> getTarifaById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.tarifas}/$id',
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return TarifaDto.fromJson(data);
  }

  Future<TarifaDto> createTarifa({
    required int parqueoId,
    required String tipoVehiculo,
    required double montoHora,
    double? montoFraccion,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.tarifas,
      data: {
        'parqueoId': parqueoId,
        'tipoVehiculo': tipoVehiculo,
        'montoHora': montoHora,
        'montoFraccion': ?montoFraccion,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return TarifaDto.fromJson(data);
  }

  Future<TarifaDto> updateTarifa({
    required int id,
    double? montoHora,
    double? montoFraccion,
    String? estado,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.tarifas}/$id',
      data: {
        'montoHora': ?montoHora,
        'montoFraccion': ?montoFraccion,
        'estado': ?estado,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return TarifaDto.fromJson(data);
  }
}
