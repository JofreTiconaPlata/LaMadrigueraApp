import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/features/ingresos/data/datasources/ingresos_remote_datasource.dart';
import 'package:la_madriguera/features/ingresos/data/models/ingreso_dto.dart';

final ingresoActivoQrProvider = FutureProvider<List<IngresoDto>>((ref) async {
  final dataSource = IngresosRemoteDataSource();

  return dataSource.getIngresosActivos();
});

class QrTiempoPage extends ConsumerWidget {
  const QrTiempoPage({super.key});

  String _formatearDuracion(DateTime fechaIngreso) {
    final diferencia = DateTime.now().difference(fechaIngreso.toLocal());
    final horas = diferencia.inHours.toString().padLeft(2, '0');
    final minutos = diferencia.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final segundos = diferencia.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$horas:$minutos:$segundos';
  }

  String _formatearHora(DateTime fecha) {
    final local = fecha.toLocal();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingresosAsync = ref.watch(ingresoActivoQrProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiempo y QR'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(ingresoActivoQrProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ingresosAsync.when(
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
                  'No se pudo cargar el ingreso activo.',
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
                  onPressed: () => ref.invalidate(ingresoActivoQrProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (ingresos) {
          if (ingresos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      size: 80,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay ingreso activo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Registra un ingreso para generar el control de tiempo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        RouteNames.registrarIngreso,
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text('Registrar ingreso'),
                    ),
                  ],
                ),
              ),
            );
          }

          final ingreso = ingresos.first;
          final vehiculo = ingreso.vehiculo;
          final espacio = ingreso.espacio;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Ingreso activo',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Placa: ${vehiculo.placa}'),
                Text('Tipo: ${vehiculo.tipo}'),
                Text('Espacio seleccionado: ${espacio.codigo}'),
                Text('Hora ingreso: ${_formatearHora(ingreso.fechaIngreso)}'),
                const SizedBox(height: 24),
                Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_2, size: 150),
                      Text(
                        'ING-${ingreso.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tiempo transcurrido',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatearDuracion(ingreso.fechaIngreso),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.salidasCobros,
                      arguments: ingreso.id,
                    ),
                    child: const Text('Finalizar y cobrar'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
