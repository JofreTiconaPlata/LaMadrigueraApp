import 'dart:async';

import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/reservas/domain/entities/reserva_activa_entity.dart';
import 'package:la_madriguera/features/reservas/presentation/providers/reserva_activa_provider.dart';

class ReservaActivaCard extends StatefulWidget {
  const ReservaActivaCard({super.key});

  @override
  State<ReservaActivaCard> createState() => _ReservaActivaCardState();
}

class _ReservaActivaCardState extends State<ReservaActivaCard> {
  Timer? _timer;
  DateTime _ahora = DateTime.now();

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _ahora = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _dosDigitos(int numero) {
    return numero.toString().padLeft(2, '0');
  }

  String _formatearHora(DateTime fecha) {
    return '${_dosDigitos(fecha.hour)}:${_dosDigitos(fecha.minute)}:${_dosDigitos(fecha.second)}';
  }

  String _formatearDuracion(Duration duracion) {
    final segundosTotales = duracion.inSeconds < 0 ? 0 : duracion.inSeconds;
    final horas = segundosTotales ~/ 3600;
    final minutos = (segundosTotales % 3600) ~/ 60;
    final segundos = segundosTotales % 60;

    return '${_dosDigitos(horas)}:${_dosDigitos(minutos)}:${_dosDigitos(segundos)}';
  }

  String _formatearDuracionResumen(Duration duracion) {
    final segundosTotales = duracion.inSeconds < 0 ? 0 : duracion.inSeconds;
    final horas = segundosTotales ~/ 3600;
    final minutos = (segundosTotales % 3600) ~/ 60;
    final segundos = segundosTotales % 60;

    if (horas > 0) {
      return '$horas h $minutos min $segundos s';
    }

    if (minutos > 0) {
      return '$minutos min $segundos s';
    }

    return '$segundos s';
  }

  Future<void> _finalizarParqueo() async {
    final resumen = ReservaActivaProvider.finalizarReserva();

    if (resumen == null || !mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Resumen del parqueo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _filaResumen('Parqueo', resumen.reserva.parqueo.nombre),
              _filaResumen('Vehículo', resumen.reserva.tipoVehiculo),
              _filaResumen('Placa', resumen.reserva.placa),
              _filaResumen(
                'Entrada',
                _formatearHora(resumen.reserva.horaEntrada),
              ),
              _filaResumen('Salida', _formatearHora(resumen.horaSalida)),
              _filaResumen(
                'Tiempo total',
                _formatearDuracionResumen(resumen.tiempoTotal),
              ),
              _filaResumen('Horas cobradas', '${resumen.horasCobradas}'),
              _filaResumen(
                'Total a pagar',
                '${resumen.montoTotal.toStringAsFixed(2)} Bs',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Widget _filaResumen(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          children: [
            TextSpan(
              text: '$titulo: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: valor),
          ],
        ),
      ),
    );
  }

  Widget _contenidoReserva(ReservaActivaEntity reserva) {
    final tiempo = reserva.tiempoTranscurrido(_ahora);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB7D6B9)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parqueo activo',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            reserva.parqueo.nombre,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${reserva.tipoVehiculo} • Placa ${reserva.placa}',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Entrada: ${_formatearHora(reserva.horaEntrada)}',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _formatearDuracion(tiempo),
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _finalizarParqueo,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Finalizar parqueo'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ReservaActivaEntity?>(
      valueListenable: ReservaActivaProvider.reservaActivaNotifier,
      builder: (context, reserva, _) {
        if (reserva == null) {
          return const SizedBox.shrink();
        }

        return _contenidoReserva(reserva);
      },
    );
  }
}
