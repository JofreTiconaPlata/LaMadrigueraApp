import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/entities/parqueo_model.dart';

class ParqueoService {
  static const String baseUrl = 'http://192.168.1.100:3000';

  Future<List<ParqueoModel>> obtenerParqueosCercanos() async {
    final response = await http.get(Uri.parse('$baseUrl/parqueos'));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener parqueos');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) => ParqueoModel.fromJson(item)).toList();
  }
}
