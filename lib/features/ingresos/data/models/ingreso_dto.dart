class IngresoDto {
  const IngresoDto({
    required this.id,
    required this.parqueoId,
    required this.espacioId,
    required this.vehiculoId,
    required this.operadorId,
    required this.fechaIngreso,
    required this.estado,
    required this.parqueo,
    required this.espacio,
    required this.vehiculo,
  });

  final int id;
  final int parqueoId;
  final int espacioId;
  final int vehiculoId;
  final int operadorId;
  final DateTime fechaIngreso;
  final String estado;
  final IngresoParqueoDto parqueo;
  final IngresoEspacioDto espacio;
  final IngresoVehiculoDto vehiculo;

  bool get estaActivo => estado == 'ACTIVO';

  factory IngresoDto.fromJson(Map<String, dynamic> json) {
    return IngresoDto(
      id: json['id'] as int,
      parqueoId: json['parqueoId'] as int,
      espacioId: json['espacioId'] as int,
      vehiculoId: json['vehiculoId'] as int,
      operadorId: json['operadorId'] as int,
      fechaIngreso: DateTime.parse(json['fechaIngreso'] as String),
      estado: json['estado'] as String,
      parqueo: IngresoParqueoDto.fromJson(
        json['parqueo'] as Map<String, dynamic>,
      ),
      espacio: IngresoEspacioDto.fromJson(
        json['espacio'] as Map<String, dynamic>,
      ),
      vehiculo: IngresoVehiculoDto.fromJson(
        json['vehiculo'] as Map<String, dynamic>,
      ),
    );
  }
}

class IngresoParqueoDto {
  const IngresoParqueoDto({
    required this.id,
    required this.nombre,
    required this.direccion,
  });

  final int id;
  final String nombre;
  final String direccion;

  factory IngresoParqueoDto.fromJson(Map<String, dynamic> json) {
    return IngresoParqueoDto(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
    );
  }
}

class IngresoEspacioDto {
  const IngresoEspacioDto({
    required this.id,
    required this.codigo,
    required this.tipo,
    required this.estado,
  });

  final int id;
  final String codigo;
  final String tipo;
  final String estado;

  factory IngresoEspacioDto.fromJson(Map<String, dynamic> json) {
    return IngresoEspacioDto(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      tipo: json['tipo'] as String,
      estado: json['estado'] as String,
    );
  }
}

class IngresoVehiculoDto {
  const IngresoVehiculoDto({
    required this.id,
    required this.placa,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.color,
  });

  final int id;
  final String placa;
  final String tipo;
  final String? marca;
  final String? modelo;
  final String? color;

  factory IngresoVehiculoDto.fromJson(Map<String, dynamic> json) {
    return IngresoVehiculoDto(
      id: json['id'] as int,
      placa: json['placa'] as String,
      tipo: json['tipo'] as String,
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      color: json['color'] as String?,
    );
  }
}
