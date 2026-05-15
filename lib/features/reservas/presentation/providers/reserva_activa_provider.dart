import 'package:flutter/foundation.dart';
import 'package:la_madriguera/features/reservas/domain/entities/reserva_activa_entity.dart';

class ReservaActivaProvider {
  ReservaActivaProvider._();

  static final ValueNotifier<ReservaActivaEntity?> reservaActivaNotifier =
      ValueNotifier<ReservaActivaEntity?>(null);

  static final ValueNotifier<List<ResumenParqueoEntity>> historialNotifier =
      ValueNotifier<List<ResumenParqueoEntity>>([]);

  static void iniciarReserva(ReservaActivaEntity reserva) {
    reservaActivaNotifier.value = reserva;
  }

  static ResumenParqueoEntity? finalizarReserva() {
    final reserva = reservaActivaNotifier.value;

    if (reserva == null) {
      return null;
    }

    final horaSalida = DateTime.now();
    final tiempoTotal = reserva.tiempoTranscurrido(horaSalida);

    final resumen = ResumenParqueoEntity(
      reserva: reserva,
      horaSalida: horaSalida,
      tiempoTotal: tiempoTotal,
      horasCobradas: reserva.horasCobradas(horaSalida),
      montoTotal: reserva.montoTotal(horaSalida),
    );

    historialNotifier.value = List.unmodifiable([
      resumen,
      ...historialNotifier.value,
    ]);

    reservaActivaNotifier.value = null;

    return resumen;
  }
}
