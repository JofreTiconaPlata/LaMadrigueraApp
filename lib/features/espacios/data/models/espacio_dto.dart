class EspacioDto {
  const EspacioDto({
    required this.id,
    required this.parqueoId,
    required this.codigo,
    required this.tipo,
    required this.estado,
  });

  final int id;
  final int parqueoId;
  final String codigo;
  final String tipo;
  final String estado;

  bool get estaDisponible => estado == 'DISPONIBLE';
  bool get estaOcupado => estado == 'OCUPADO';

  factory EspacioDto.fromJson(Map<String, dynamic> json) {
    return EspacioDto(
      id: json['id'] as int,
      parqueoId: json['parqueoId'] as int,
      codigo: json['codigo'] as String,
      tipo: json['tipo'] as String,
      estado: json['estado'] as String,
    );
  }
}
