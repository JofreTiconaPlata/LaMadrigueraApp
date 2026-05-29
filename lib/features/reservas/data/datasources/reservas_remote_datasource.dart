import 'package:dio/dio.dart';
import 'package:la_madriguera/core/network/api_endpoints.dart';
import 'package:la_madriguera/core/network/dio_client.dart';
import 'package:la_madriguera/features/reservas/data/models/reserva_dto.dart';

class ReservasRemoteDataSource {
  ReservasRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<ReservaDto> crearReserva({
    required int parqueoId,
    required int vehiculoId,
    int? espacioId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final body = <String, dynamic>{
      'parqueoId': parqueoId,
      'vehiculoId': vehiculoId,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
    };

    if (espacioId != null) {
      body['espacioId'] = espacioId;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.reservas,
      data: body,
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return ReservaDto.fromJson(data);
  }

  Future<List<ReservaDto>> getMisReservas() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.misReservas,
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];

    return data
        .map((item) => ReservaDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ReservaDto> cancelarReserva(int id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.reservas}/$id/cancelar',
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return ReservaDto.fromJson(data);
  }
}