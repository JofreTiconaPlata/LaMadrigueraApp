class ReservaDto {
  const ReservaDto({
    required this.id,
    required this.clienteId,
    required this.parqueoId,
    required this.espacioId,
    required this.vehiculoId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
  });

  final int id;
  final int clienteId;
  final int parqueoId;
  final int? espacioId;
  final int vehiculoId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;

  factory ReservaDto.fromJson(Map<String, dynamic> json) {
    return ReservaDto(
      id: json['id'] as int,
      clienteId: json['clienteId'] as int,
      parqueoId: json['parqueoId'] as int,
      espacioId: json['espacioId'] as int?,
      vehiculoId: json['vehiculoId'] as int,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      estado: json['estado'] as String,
    );
  }
}
