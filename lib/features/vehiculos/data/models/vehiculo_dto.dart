class VehiculoDto {
  const VehiculoDto({
    required this.id,
    required this.clienteId,
    required this.placa,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.color,
  });

  final int id;
  final int clienteId;
  final String placa;
  final String tipo;
  final String? marca;
  final String? modelo;
  final String? color;

  factory VehiculoDto.fromJson(Map<String, dynamic> json) {
    return VehiculoDto(
      id: json['id'] as int,
      clienteId: json['clienteId'] as int,
      placa: json['placa'] as String,
      tipo: json['tipo'] as String,
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      color: json['color'] as String?,
    );
  }
}
