class ParqueoModel {
  final int id;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final int espaciosDisponibles;
  final String horario;
  final double tarifaReferencia;

  ParqueoModel({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.espaciosDisponibles,
    required this.horario,
    required this.tarifaReferencia,
  });

  factory ParqueoModel.fromJson(Map<String, dynamic> json) {
    return ParqueoModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Parqueo sin nombre',
      direccion: json['direccion'] ?? 'Sin dirección',
      latitud: double.tryParse(json['latitud'].toString()) ?? 0.0,
      longitud: double.tryParse(json['longitud'].toString()) ?? 0.0,
      espaciosDisponibles: json['espaciosDisponibles'] ?? 0,
      horario: json['horario'] ?? 'Sin horario',
      tarifaReferencia:
          double.tryParse(json['tarifaReferencia'].toString()) ?? 0.0,
    );
  }
}