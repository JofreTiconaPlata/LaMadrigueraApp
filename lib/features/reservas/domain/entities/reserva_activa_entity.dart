import 'package:la_madriguera/features/parqueos/domain/entities/parqueo_entity.dart';

class ReservaActivaEntity {
  const ReservaActivaEntity({
    required this.id,
    required this.parqueo,
    required this.tipoVehiculo,
    required this.placa,
    required this.nombreConductor,
    required this.horaEntrada,
  });

  final String id;
  final ParqueoEntity parqueo;
  final String tipoVehiculo;
  final String placa;
  final String nombreConductor;
  final DateTime horaEntrada;

  Duration tiempoTranscurrido(DateTime ahora) {
    final diferencia = ahora.difference(horaEntrada);
    return diferencia.isNegative ? Duration.zero : diferencia;
  }

  int horasCobradas(DateTime horaSalida) {
    final segundos = horaSalida.difference(horaEntrada).inSeconds;

    if (segundos <= 0) {
      return 1;
    }

    return (segundos / 3600).ceil();
  }

  double montoTotal(DateTime horaSalida) {
    final tarifaHora = parqueo.precioHora;

    if (tarifaHora <= 0) {
      return 0;
    }

    return horasCobradas(horaSalida) * tarifaHora;
  }
}

class ResumenParqueoEntity {
  const ResumenParqueoEntity({
    required this.reserva,
    required this.horaSalida,
    required this.tiempoTotal,
    required this.horasCobradas,
    required this.montoTotal,
  });

  final ReservaActivaEntity reserva;
  final DateTime horaSalida;
  final Duration tiempoTotal;
  final int horasCobradas;
  final double montoTotal;
}
