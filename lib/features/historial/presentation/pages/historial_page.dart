import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/reservas/data/datasources/reservas_remote_datasource.dart';
import 'package:la_madriguera/features/reservas/data/models/reserva_dto.dart';

final historialOperacionesProvider = FutureProvider<List<ReservaDto>>((
  ref,
) async {
  final dataSource = ReservasRemoteDataSource();
  return dataSource.getReservasOperador();
});

class HistorialPage extends ConsumerWidget {
  const HistorialPage({super.key});

  String _formatearFechaHora(DateTime fecha) {
    final fechaLocal = fecha.toLocal();

    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(fechaLocal.day)}/${two(fechaLocal.month)}/${fechaLocal.year} '
        '${two(fechaLocal.hour)}:${two(fechaLocal.minute)}';
  }

  String _formatearTiempo(DateTime inicio, DateTime fin) {
    final minutosTotales = fin.difference(inicio).inMinutes.abs();
    final horas = minutosTotales ~/ 60;
    final minutos = minutosTotales % 60;

    if (horas <= 0) {
      return '$minutos min';
    }

    if (minutos == 0) {
      return '$horas h';
    }

    return '$horas h $minutos min';
  }

  double _calcularMonto(DateTime inicio, DateTime fin) {
    const tarifaHora = 5.0;
    final minutos = fin.difference(inicio).inMinutes.abs();

    if (minutos <= 0) {
      return tarifaHora;
    }

    final horasCobradas = (minutos / 60).ceil();
    return horasCobradas * tarifaHora;
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppTheme.primary),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _recargar(WidgetRef ref) async {
    ref.invalidate(historialOperacionesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialOperacionesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Informe de cobros'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(historialOperacionesProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: historialAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text(
                  'No se pudo cargar el informe de cobros.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(historialOperacionesProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (reservas) {
          final registros = reservas.where((reserva) {
            return reserva.estado != 'CANCELADA';
          }).toList();

          if (registros.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _recargar(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.receipt_long, size: 72, color: AppTheme.primary),
                  SizedBox(height: 16),
                  Text(
                    'No hay cobros registrados',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cuando un cliente reserve un espacio, aparecerá aquí el informe de cobro.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _recargar(ref),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Total: ${registros.length} registro(s)',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                ...registros.map((reserva) {
                  final vehiculo = reserva.vehiculo;
                  final parqueo = reserva.parqueo;

                  final tipoVehiculo = vehiculo?.tipo ?? 'Sin tipo';
                  final placa = vehiculo?.placa ?? 'Sin placa';
                  final parqueoNombre =
                      parqueo?.nombre ?? 'Parqueo #${reserva.parqueoId}';
                  final parqueoDireccion =
                      parqueo?.direccion ?? 'Sin dirección registrada';

                  final tiempo = _formatearTiempo(
                    reserva.fechaInicio,
                    reserva.fechaFin,
                  );

                  final monto = _calcularMonto(
                    reserva.fechaInicio,
                    reserva.fechaFin,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(17),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFE8F5E9),
                                child: Icon(
                                  tipoVehiculo == 'MOTO'
                                      ? Icons.two_wheeler
                                      : Icons.directions_car,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '$tipoVehiculo - $placa',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              Chip(label: Text(reserva.estado)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _infoRow(
                            icon: Icons.person,
                            label: 'Registrado',
                            value: 'Reserva #${reserva.id}',
                          ),
                          _infoRow(
                            icon: Icons.local_parking,
                            label: 'Parqueo',
                            value: parqueoNombre,
                          ),
                          _infoRow(
                            icon: Icons.place,
                            label: 'Dirección',
                            value: parqueoDireccion,
                          ),
                          _infoRow(
                            icon: Icons.login,
                            label: 'Entrada',
                            value: _formatearFechaHora(reserva.fechaInicio),
                          ),
                          _infoRow(
                            icon: Icons.logout,
                            label: 'Salida',
                            value: _formatearFechaHora(reserva.fechaFin),
                          ),
                          _infoRow(
                            icon: Icons.timer,
                            label: 'Tiempo de estancia',
                            value: tiempo,
                          ),
                          _infoRow(
                            icon: Icons.attach_money,
                            label: 'Tarifa',
                            value: 'Bs 5.00 por hora',
                          ),
                          _infoRow(
                            icon: Icons.receipt_long,
                            label: 'Cobro total',
                            value: 'Bs ${monto.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
