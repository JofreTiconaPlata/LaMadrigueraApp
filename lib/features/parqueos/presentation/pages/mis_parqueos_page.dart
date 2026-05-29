import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/parqueos/data/datasources/parqueos_remote_datasource.dart';
import 'package:la_madriguera/features/parqueos/data/models/parqueo_dto.dart';

final misParqueosProvider = FutureProvider<List<ParqueoDto>>((ref) async {
  final dataSource = ParqueosRemoteDataSource();
  return dataSource.getMisParqueos();
});

class MisParqueosPage extends ConsumerWidget {
  const MisParqueosPage({super.key});

  Future<void> _abrirCrearParqueo(BuildContext context, WidgetRef ref) async {
    final resultado = await Navigator.pushNamed(
      context,
      RouteNames.crearParqueo,
    );

    if (resultado == true) {
      ref.invalidate(misParqueosProvider);
    }
  }

  void _abrirEspacios(BuildContext context, ParqueoDto parqueo) {
    Navigator.pushNamed(context, RouteNames.espacios, arguments: parqueo.id);
  }

  Future<void> _recargar(WidgetRef ref) async {
    ref.invalidate(misParqueosProvider);
  }

  Widget _emptyState(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => _recargar(ref),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.local_parking, size: 78, color: AppTheme.primary),
          const SizedBox(height: 18),
          const Text(
            'Aún no tienes parqueos registrados',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando crees un parqueo como operador, aparecerá aquí con sus espacios reales.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _abrirCrearParqueo(context, ref),
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Crear parqueo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _parqueoCard(BuildContext context, ParqueoDto parqueo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _abrirEspacios(context, parqueo),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_parking,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      parqueo.nombre,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                parqueo.direccion,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _chipInfo(
                    icon: Icons.directions_car,
                    text: '${parqueo.espaciosAutos} autos',
                  ),
                  _chipInfo(
                    icon: Icons.two_wheeler,
                    text: '${parqueo.espaciosMotos} motos',
                  ),
                  _chipInfo(
                    icon: Icons.local_parking,
                    text: '${parqueo.capacidadTotal} total',
                  ),
                  _chipInfo(icon: Icons.circle, text: parqueo.estado),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => _abrirEspacios(context, parqueo),
                  icon: const Icon(Icons.grid_view),
                  label: const Text('Ver espacios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipInfo({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parqueosAsync = ref.watch(misParqueosProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mis parqueos'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(misParqueosProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirCrearParqueo(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: parqueosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 58, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text(
                  'No se pudieron cargar tus parqueos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(misParqueosProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (parqueos) {
          if (parqueos.isEmpty) {
            return _emptyState(context, ref);
          }

          return RefreshIndicator(
            onRefresh: () => _recargar(ref),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
              children: [
                const Text(
                  'Tus parqueos registrados',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total: ${parqueos.length} parqueo(s)',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 18),
                ...parqueos.map((parqueo) => _parqueoCard(context, parqueo)),
              ],
            ),
          );
        },
      ),
    );
  }
}
