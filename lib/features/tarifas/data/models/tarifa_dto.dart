class TarifaDto {
  const TarifaDto({
    required this.id,
    required this.parqueoId,
    required this.tipoVehiculo,
    required this.montoHora,
    required this.montoFraccion,
    required this.estado,
  });

  final int id;
  final int parqueoId;
  final String tipoVehiculo;
  final double montoHora;
  final double? montoFraccion;
  final String estado;

  bool get estaActiva => estado == 'ACTIVO';

  factory TarifaDto.fromJson(Map<String, dynamic> json) {
    return TarifaDto(
      id: json['id'] as int,
      parqueoId: json['parqueoId'] as int,
      tipoVehiculo: json['tipoVehiculo'] as String,
      montoHora: (json['montoHora'] as num).toDouble(),
      montoFraccion: json['montoFraccion'] == null
          ? null
          : (json['montoFraccion'] as num).toDouble(),
      estado: json['estado'] as String,
    );
  }
}
