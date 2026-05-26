import 'package:dio/dio.dart';
import 'package:la_madriguera/core/network/api_endpoints.dart';
import 'package:la_madriguera/core/network/dio_client.dart';
import 'package:la_madriguera/features/vehiculos/data/models/vehiculo_dto.dart';

class VehiculosRemoteDataSource {
  VehiculosRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  String? _textoOpcional(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  Future<List<VehiculoDto>> getVehiculos({int? clienteId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.vehiculos,
      queryParameters: {'clienteId': ?clienteId},
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];

    return data
        .map((item) => VehiculoDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<VehiculoDto> getVehiculoById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.vehiculos}/$id',
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return VehiculoDto.fromJson(data);
  }

  Future<VehiculoDto> createVehiculo({
    required String placa,
    required String tipo,
    String? marca,
    String? modelo,
    String? color,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.vehiculos,
      data: {
        'placa': placa.trim().toUpperCase(),
        'tipo': tipo,
        'marca': ?_textoOpcional(marca),
        'modelo': ?_textoOpcional(modelo),
        'color': ?_textoOpcional(color),
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return VehiculoDto.fromJson(data);
  }

  Future<VehiculoDto> deleteVehiculo(int id) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '${ApiEndpoints.vehiculos}/$id',
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return VehiculoDto.fromJson(data);
  }
}
