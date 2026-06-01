class ParqueoDto {
  const ParqueoDto({
    required this.id,
    required this.operadorId,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.espaciosAutos,
    required this.espaciosMotos,
    required this.capacidadTotal,
    required this.estado,
  });

  final int id;
  final int operadorId;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final int espaciosAutos;
  final int espaciosMotos;
  final int capacidadTotal;
  final String estado;

  factory ParqueoDto.fromJson(Map<String, dynamic> json) {
    return ParqueoDto(
      id: json['id'] as int,
      operadorId: (json['operadorId'] as num).toInt(),
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      espaciosAutos: json['espaciosAutos'] as int,
      espaciosMotos: json['espaciosMotos'] as int,
      capacidadTotal: json['capacidadTotal'] as int,
      estado: json['estado'] as String,
    );
  }
}
