class SalidaCobroDto {
  const SalidaCobroDto({
    required this.id,
    required this.ingresoId,
    required this.operadorId,
    required this.fechaSalida,
    required this.tiempoTotalMinutos,
    required this.montoTotal,
    required this.estadoPago,
    required this.ingreso,
    required this.pago,
  });

  final int id;
  final int ingresoId;
  final int operadorId;
  final DateTime fechaSalida;
  final int tiempoTotalMinutos;
  final double montoTotal;
  final String estadoPago;
  final SalidaCobroIngresoDto ingreso;
  final SalidaCobroPagoDto? pago;

  bool get estaPagado => estadoPago == 'PAGADO';

  factory SalidaCobroDto.fromJson(Map<String, dynamic> json) {
    return SalidaCobroDto(
      id: json['id'] as int,
      ingresoId: json['ingresoId'] as int,
      operadorId: json['operadorId'] as int,
      fechaSalida: DateTime.parse(json['fechaSalida'] as String),
      tiempoTotalMinutos: json['tiempoTotalMinutos'] as int,
      montoTotal: (json['montoTotal'] as num).toDouble(),
      estadoPago: json['estadoPago'] as String,
      ingreso: SalidaCobroIngresoDto.fromJson(
        json['ingreso'] as Map<String, dynamic>,
      ),
      pago: json['pago'] == null
          ? null
          : SalidaCobroPagoDto.fromJson(json['pago'] as Map<String, dynamic>),
    );
  }
}

class SalidaCobroIngresoDto {
  const SalidaCobroIngresoDto({
    required this.id,
    required this.fechaIngreso,
    required this.estado,
    required this.parqueo,
    required this.espacio,
    required this.vehiculo,
  });

  final int id;
  final DateTime fechaIngreso;
  final String estado;
  final SalidaCobroParqueoDto parqueo;
  final SalidaCobroEspacioDto espacio;
  final SalidaCobroVehiculoDto vehiculo;

  factory SalidaCobroIngresoDto.fromJson(Map<String, dynamic> json) {
    return SalidaCobroIngresoDto(
      id: json['id'] as int,
      fechaIngreso: DateTime.parse(json['fechaIngreso'] as String),
      estado: json['estado'] as String,
      parqueo: SalidaCobroParqueoDto.fromJson(
        json['parqueo'] as Map<String, dynamic>,
      ),
      espacio: SalidaCobroEspacioDto.fromJson(
        json['espacio'] as Map<String, dynamic>,
      ),
      vehiculo: SalidaCobroVehiculoDto.fromJson(
        json['vehiculo'] as Map<String, dynamic>,
      ),
    );
  }
}

class SalidaCobroParqueoDto {
  const SalidaCobroParqueoDto({
    required this.id,
    required this.nombre,
    required this.direccion,
  });

  final int id;
  final String nombre;
  final String direccion;

  factory SalidaCobroParqueoDto.fromJson(Map<String, dynamic> json) {
    return SalidaCobroParqueoDto(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
    );
  }
}

class SalidaCobroEspacioDto {
  const SalidaCobroEspacioDto({
    required this.id,
    required this.codigo,
    required this.tipo,
    required this.estado,
  });

  final int id;
  final String codigo;
  final String tipo;
  final String estado;

  factory SalidaCobroEspacioDto.fromJson(Map<String, dynamic> json) {
    return SalidaCobroEspacioDto(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      tipo: json['tipo'] as String,
      estado: json['estado'] as String,
    );
  }
}

class SalidaCobroVehiculoDto {
  const SalidaCobroVehiculoDto({
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

  factory SalidaCobroVehiculoDto.fromJson(Map<String, dynamic> json) {
    return SalidaCobroVehiculoDto(
      id: json['id'] as int,
      placa: json['placa'] as String,
      tipo: json['tipo'] as String,
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      color: json['color'] as String?,
    );
  }
}

class SalidaCobroPagoDto {
  const SalidaCobroPagoDto({
    required this.id,
    required this.metodoPago,
    required this.monto,
    required this.referencia,
    required this.estado,
    required this.fechaPago,
  });

  final int id;
  final String metodoPago;
  final double monto;
  final String? referencia;
  final String estado;
  final DateTime fechaPago;

  factory SalidaCobroPagoDto.fromJson(Map<String, dynamic> json) {
    return SalidaCobroPagoDto(
      id: json['id'] as int,
      metodoPago: json['metodoPago'] as String,
      monto: (json['monto'] as num).toDouble(),
      referencia: json['referencia'] as String?,
      estado: json['estado'] as String,
      fechaPago: DateTime.parse(json['fechaPago'] as String),
    );
  }
}
