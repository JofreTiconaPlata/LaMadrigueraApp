import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/salidas_cobros/data/datasources/salidas_cobros_remote_datasource.dart';
import 'package:la_madriguera/features/salidas_cobros/data/models/salida_cobro_dto.dart';

final historialOperacionesProvider = FutureProvider<List<SalidaCobroDto>>((
  ref,
) async {
  final dataSource = SalidasCobrosRemoteDataSource();
  return dataSource.getSalidasCobros();
});

class HistorialPage extends ConsumerWidget {
  const HistorialPage({super.key});

  String _two(int value) => value.toString().padLeft(2, '0');

  String _formatearFechaHora(DateTime fecha) {
    final fechaLocal = fecha.toLocal();

    return '${_two(fechaLocal.day)}/${_two(fechaLocal.month)}/${fechaLocal.year} '
        '${_two(fechaLocal.hour)}:${_two(fechaLocal.minute)}';
  }

  String _formatearTiempo(int minutosTotales) {
    final minutosSeguros = max(0, minutosTotales);
    final horas = minutosSeguros ~/ 60;
    final minutos = minutosSeguros % 60;

    if (horas <= 0) {
      return '$minutos min';
    }

    if (minutos == 0) {
      return '$horas h';
    }

    return '$horas h $minutos min';
  }

  int _horasCobradas(int minutosTotales) {
    return max(1, (minutosTotales / 60).ceil());
  }

  double _tarifaAplicada(SalidaCobroDto registro) {
    final horas = _horasCobradas(registro.tiempoTotalMinutos);

    if (registro.montoTotal <= 0) {
      return 0;
    }

    return registro.montoTotal / horas;
  }

  String _metodoPago(SalidaCobroDto registro) {
    final metodo = registro.pago?.metodoPago.trim();

    if (metodo == null || metodo.isEmpty) {
      return registro.estadoPago == 'PAGADO' ? 'Registrado' : 'Pendiente';
    }

    return metodo;
  }

  String _referenciaPago(SalidaCobroDto registro) {
    final referencia = registro.pago?.referencia?.trim();

    if (referencia == null || referencia.isEmpty) {
      return 'Sin referencia';
    }

    return referencia;
  }

  Future<void> _recargar(WidgetRef ref) async {
    ref.invalidate(historialOperacionesProvider);
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    bool destacado = false,
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
                style: TextStyle(
                  color: destacado ? AppTheme.primary : AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
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

  Widget _resumenCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8E4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => _recargar(ref),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.history, size: 72, color: AppTheme.primary),
          SizedBox(height: 16),
          Text(
            'No hay operaciones registradas',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Cuando se registre una salida o cobro, aparecerá aquí el historial completo del operador.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _errorState(Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'No se pudo cargar el historial de operaciones.',
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
    );
  }

  Widget _operacionCard(SalidaCobroDto registro) {
    final ingreso = registro.ingreso;
    final vehiculo = ingreso.vehiculo;
    final parqueo = ingreso.parqueo;
    final espacio = ingreso.espacio;

    final tipoVehiculo = vehiculo.tipo;
    final placa = vehiculo.placa;
    final tarifaAplicada = _tarifaAplicada(registro);

    final detalleVehiculo = [
      if ((vehiculo.marca ?? '').trim().isNotEmpty) vehiculo.marca,
      if ((vehiculo.modelo ?? '').trim().isNotEmpty) vehiculo.modelo,
      if ((vehiculo.color ?? '').trim().isNotEmpty) vehiculo.color,
    ].whereType<String>().join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                Text(
                  'Bs ${registro.montoTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _infoRow(
              icon: Icons.confirmation_number_outlined,
              label: 'Operación',
              value: '#${registro.id} · Ingreso #${ingreso.id}',
            ),
            _infoRow(
              icon: Icons.directions_car,
              label: 'Vehículo',
              value: detalleVehiculo.isEmpty ? tipoVehiculo : detalleVehiculo,
            ),
            _infoRow(icon: Icons.pin, label: 'Placa', value: placa),
            _infoRow(
              icon: Icons.local_parking,
              label: 'Parqueo',
              value: parqueo.nombre,
            ),
            _infoRow(
              icon: Icons.crop_square,
              label: 'Espacio',
              value: '${espacio.codigo} · ${espacio.tipo}',
            ),
            _infoRow(
              icon: Icons.place,
              label: 'Dirección',
              value: parqueo.direccion,
            ),
            const Divider(height: 22),
            _infoRow(
              icon: Icons.login,
              label: 'Entrada',
              value: _formatearFechaHora(ingreso.fechaIngreso),
            ),
            _infoRow(
              icon: Icons.logout,
              label: 'Salida',
              value: _formatearFechaHora(registro.fechaSalida),
            ),
            _infoRow(
              icon: Icons.timer,
              label: 'Tiempo de estancia',
              value: _formatearTiempo(registro.tiempoTotalMinutos),
            ),
            _infoRow(
              icon: Icons.attach_money,
              label: 'Tarifa aplicada',
              value: 'Bs ${tarifaAplicada.toStringAsFixed(2)} por hora',
            ),
            _infoRow(
              icon: Icons.receipt_long,
              label: 'Cobro total',
              value: 'Bs ${registro.montoTotal.toStringAsFixed(2)}',
              destacado: true,
            ),
            const Divider(height: 22),
            _infoRow(
              icon: Icons.payments,
              label: 'Estado de pago',
              value: registro.estadoPago,
            ),
            _infoRow(
              icon: Icons.payment,
              label: 'Método de pago',
              value: _metodoPago(registro),
            ),
            _infoRow(
              icon: Icons.notes,
              label: 'Referencia',
              value: _referenciaPago(registro),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialOperacionesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Historial de operaciones'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(historialOperacionesProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: historialAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _errorState(error, ref),
        data: (operaciones) {
          if (operaciones.isEmpty) {
            return _emptyState(ref);
          }

          final totalCobrado = operaciones.fold<double>(
            0,
            (total, item) => total + item.montoTotal,
          );

          final pagadas = operaciones
              .where((item) => item.estadoPago == 'PAGADO')
              .length;

          return RefreshIndicator(
            onRefresh: () => _recargar(ref),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _resumenCard(
                      icon: Icons.history,
                      label: 'Operaciones',
                      value: '${operaciones.length}',
                    ),
                    const SizedBox(width: 10),
                    _resumenCard(
                      icon: Icons.payments,
                      label: 'Pagadas',
                      value: '$pagadas',
                    ),
                    const SizedBox(width: 10),
                    _resumenCard(
                      icon: Icons.receipt_long,
                      label: 'Total',
                      value: 'Bs ${totalCobrado.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: ${operaciones.length} operación(es)',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                ...operaciones.map(_operacionCard),
              ],
            ),
          );
        },
      ),
    );
  }
}
