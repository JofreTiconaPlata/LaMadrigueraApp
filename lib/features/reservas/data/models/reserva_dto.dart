class ReservaParqueoDto {
  const ReservaParqueoDto({
    required this.id,
    required this.nombre,
    required this.direccion,
  });

  final int id;
  final String nombre;
  final String direccion;

  factory ReservaParqueoDto.fromJson(Map<String, dynamic> json) {
    return ReservaParqueoDto(
      id: json['id'] as int,
      nombre: json['nombre'] as String? ?? 'Parqueo',
      direccion: json['direccion'] as String? ?? 'Sin dirección',
    );
  }
}

class ReservaVehiculoDto {
  const ReservaVehiculoDto({
    required this.id,
    required this.placa,
    required this.tipo,
  });

  final int id;
  final String placa;
  final String tipo;

  factory ReservaVehiculoDto.fromJson(Map<String, dynamic> json) {
    return ReservaVehiculoDto(
      id: json['id'] as int,
      placa: json['placa'] as String? ?? 'Sin placa',
      tipo: json['tipo'] as String? ?? 'Vehículo',
    );
  }
}

class ReservaEspacioDto {
  const ReservaEspacioDto({
    required this.id,
    required this.codigo,
    required this.tipo,
  });

  final int id;
  final String codigo;
  final String tipo;

  factory ReservaEspacioDto.fromJson(Map<String, dynamic> json) {
    return ReservaEspacioDto(
      id: json['id'] as int,
      codigo: json['codigo'] as String? ?? 'Sin código',
      tipo: json['tipo'] as String? ?? 'Espacio',
    );
  }
}

class ReservaSalidaCobroDto {
  const ReservaSalidaCobroDto({
    required this.id,
    required this.fechaSalida,
    required this.tiempoTotalMinutos,
    required this.montoTotal,
    required this.estadoPago,
  });

  final int id;
  final DateTime fechaSalida;
  final int tiempoTotalMinutos;
  final double montoTotal;
  final String estadoPago;

  bool get estaPendiente => estadoPago == 'PENDIENTE';
  bool get estaPagada => estadoPago == 'PAGADO';

  factory ReservaSalidaCobroDto.fromJson(Map<String, dynamic> json) {
    return ReservaSalidaCobroDto(
      id: json['id'] as int,
      fechaSalida: DateTime.parse(json['fechaSalida'] as String).toLocal(),
      tiempoTotalMinutos: json['tiempoTotalMinutos'] as int,
      montoTotal: (json['montoTotal'] as num).toDouble(),
      estadoPago: json['estadoPago'] as String,
    );
  }
}

class ReservaIngresoDto {
  const ReservaIngresoDto({
    required this.id,
    required this.fechaIngreso,
    required this.estado,
    required this.salidaCobro,
  });

  final int id;
  final DateTime fechaIngreso;
  final String estado;
  final ReservaSalidaCobroDto? salidaCobro;

  bool get estaActivo => estado == 'ACTIVO';

  factory ReservaIngresoDto.fromJson(Map<String, dynamic> json) {
    final salidaCobroJson = json['salidaCobro'];

    return ReservaIngresoDto(
      id: json['id'] as int,
      fechaIngreso: DateTime.parse(json['fechaIngreso'] as String).toLocal(),
      estado: json['estado'] as String,
      salidaCobro: salidaCobroJson is Map<String, dynamic>
          ? ReservaSalidaCobroDto.fromJson(salidaCobroJson)
          : null,
    );
  }
}

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
    this.parqueo,
    this.vehiculo,
    this.espacio,
    this.ingreso,
  });

  final int id;
  final int clienteId;
  final int parqueoId;
  final int? espacioId;
  final int vehiculoId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
  final ReservaParqueoDto? parqueo;
  final ReservaVehiculoDto? vehiculo;
  final ReservaEspacioDto? espacio;
  final ReservaIngresoDto? ingreso;

  bool get esperandoIngreso {
    return estado == 'ACTIVA' && ingreso == null;
  }

  bool get vehiculoEstacionado {
    return estado == 'ACTIVA' && ingreso?.estado == 'ACTIVO';
  }

  bool get salidaPendiente {
    return vehiculoEstacionado &&
        ingreso?.salidaCobro?.estadoPago == 'PENDIENTE';
  }

  bool get salidaPagada {
    return ingreso?.salidaCobro?.estadoPago == 'PAGADO';
  }

  bool get puedeCancelar {
    return esperandoIngreso;
  }

  bool get puedeSolicitarSalida {
    return vehiculoEstacionado && ingreso?.salidaCobro == null;
  }

  bool get estaEnProgreso {
    return esperandoIngreso || vehiculoEstacionado;
  }

  bool get estaTerminada {
    return estado == 'COMPLETADA' ||
        estado == 'FINALIZADA' ||
        estado == 'CANCELADA';
  }

  factory ReservaDto.fromJson(Map<String, dynamic> json) {
    final parqueoJson = json['parqueo'];
    final vehiculoJson = json['vehiculo'];
    final espacioJson = json['espacio'];
    final ingresoJson = json['ingreso'];

    return ReservaDto(
      id: json['id'] as int,
      clienteId: json['clienteId'] as int,
      parqueoId: json['parqueoId'] as int,
      espacioId: json['espacioId'] as int?,
      vehiculoId: json['vehiculoId'] as int,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String).toLocal(),
      fechaFin: DateTime.parse(json['fechaFin'] as String).toLocal(),
      estado: json['estado'] as String,
      parqueo: parqueoJson is Map<String, dynamic>
          ? ReservaParqueoDto.fromJson(parqueoJson)
          : null,
      vehiculo: vehiculoJson is Map<String, dynamic>
          ? ReservaVehiculoDto.fromJson(vehiculoJson)
          : null,
      espacio: espacioJson is Map<String, dynamic>
          ? ReservaEspacioDto.fromJson(espacioJson)
          : null,
      ingreso: ingresoJson is Map<String, dynamic>
          ? ReservaIngresoDto.fromJson(ingresoJson)
          : null,
    );
  }
}
