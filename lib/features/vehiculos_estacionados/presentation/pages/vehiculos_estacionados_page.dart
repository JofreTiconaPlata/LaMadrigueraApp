import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/features/ingresos/data/datasources/ingresos_remote_datasource.dart';
import 'package:la_madriguera/features/ingresos/data/models/ingreso_dto.dart';

final ingresosActivosProvider = FutureProvider<List<IngresoDto>>((ref) async {
  final dataSource = IngresosRemoteDataSource();

  return dataSource.getIngresosActivos();
});

class VehiculosEstacionadosPage extends ConsumerWidget {
  const VehiculosEstacionadosPage({super.key});

  String _formatearHora(DateTime fecha) {
    final local = fecha.toLocal();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  Future<void> _recargar(WidgetRef ref) async {
    ref.invalidate(ingresosActivosProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingresosAsync = ref.watch(ingresosActivosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos estacionados'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(ingresosActivosProvider),
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
                  'No se pudieron cargar los vehículos estacionados.',
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
                  onPressed: () => ref.invalidate(ingresosActivosProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (ingresos) {
          if (ingresos.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _recargar(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.local_parking, size: 72, color: AppTheme.primary),
                  SizedBox(height: 16),
                  Text(
                    'No hay vehículos estacionados',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cuando registres un ingreso activo aparecerá aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _recargar(ref),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ingresos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ingreso = ingresos[index];
                final vehiculo = ingreso.vehiculo;
                final espacio = ingreso.espacio;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/salidas-cobros',
                      arguments: ingreso.id,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE8F5E9),
                      child: Icon(
                        vehiculo.tipo == 'MOTO'
                            ? Icons.two_wheeler
                            : Icons.directions_car,
                        color: AppTheme.primary,
                      ),
                    ),
                    title: Text(
                      vehiculo.placa,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Tipo: ${vehiculo.tipo} � Espacio: ${espacio.codigo} � Ingreso: ${_formatearHora(ingreso.fechaIngreso)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
