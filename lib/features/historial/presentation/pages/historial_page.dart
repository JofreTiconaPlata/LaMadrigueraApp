import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  String _formatearFechaHora(DateTime fecha) {
    final local = fecha.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final anio = local.year.toString();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio $hora:$minuto';
  }

  Future<void> _recargar(WidgetRef ref) async {
    ref.invalidate(historialOperacionesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialOperacionesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
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
                  'No se pudo cargar el historial.',
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
        data: (registros) {
          if (registros.isEmpty) {
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
                    'Cuando se registren salidas y cobros aparecerán aquí.',
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
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Historial de operaciones',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${registros.length} operación(es) registradas en backend',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ...registros.map((registro) {
                  final ingreso = registro.ingreso;
                  final vehiculo = ingreso.vehiculo;
                  final espacio = ingreso.espacio;
                  final pago = registro.pago;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehiculo.placa,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Tipo: ${vehiculo.tipo}'),
                          Text('Espacio: ${espacio.codigo}'),
                          Text(
                            'Entrada: ${_formatearFechaHora(ingreso.fechaIngreso)}',
                          ),
                          Text(
                            'Salida: ${_formatearFechaHora(registro.fechaSalida)}',
                          ),
                          Text(
                            'Tiempo total: ${registro.tiempoTotalMinutos} min',
                          ),
                          Text(
                            'Monto: Bs ${registro.montoTotal.toStringAsFixed(2)}',
                          ),
                          Text('Estado pago: ${registro.estadoPago}'),
                          if (pago != null) ...[
                            Text('Método: ${pago.metodoPago}'),
                            if (pago.referencia != null)
                              Text('Referencia: ${pago.referencia}'),
                          ],
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
