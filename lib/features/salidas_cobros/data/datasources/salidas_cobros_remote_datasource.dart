import 'package:dio/dio.dart';
import 'package:la_madriguera/core/network/api_endpoints.dart';
import 'package:la_madriguera/core/network/dio_client.dart';
import 'package:la_madriguera/features/salidas_cobros/data/models/salida_cobro_dto.dart';

class SalidasCobrosRemoteDataSource {
  SalidasCobrosRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  String? _textoOpcional(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  Future<List<SalidaCobroDto>> getSalidasCobros({
    int? ingresoId,
    String? estadoPago,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.salidasCobros,
      queryParameters: {'ingresoId': ?ingresoId, 'estadoPago': ?estadoPago},
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];

    return data
        .map((item) => SalidaCobroDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SalidaCobroDto> getSalidaCobroById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.salidasCobros}/$id',
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return SalidaCobroDto.fromJson(data);
  }

  Future<SalidaCobroDto> solicitarSalida({required int ingresoId}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.salidasCobros}/solicitar',
      data: {'ingresoId': ingresoId},
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return SalidaCobroDto.fromJson(data);
  }

  Future<SalidaCobroDto> validarPago({
    required int salidaCobroId,
    required String metodoPago,
    String? referencia,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.salidasCobros}/$salidaCobroId/validar-pago',
      data: {
        'metodoPago': metodoPago,
        'referencia': ?_textoOpcional(referencia),
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>;

    return SalidaCobroDto.fromJson(data);
  }
}
