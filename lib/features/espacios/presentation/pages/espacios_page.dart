import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/features/espacios/data/datasources/espacios_remote_datasource.dart';
import 'package:la_madriguera/features/espacios/data/models/espacio_dto.dart';

final espaciosPageProvider = FutureProvider.family<List<EspacioDto>, int>((
  ref,
  parqueoId,
) async {
  final dataSource = EspaciosRemoteDataSource();

  return dataSource.getEspacios(parqueoId: parqueoId);
});

class EspaciosPage extends ConsumerWidget {
  final int parqueoId;

  const EspaciosPage({super.key, required this.parqueoId});

  Color _backgroundColor(EspacioDto espacio) {
    return switch (espacio.estado) {
      'DISPONIBLE' => AppTheme.primary.withValues(alpha: 0.12),
      'OCUPADO' => Colors.red.shade100,
      'RESERVADO' => Colors.orange.shade100,
      'MANTENIMIENTO' => Colors.grey.shade300,
      _ => Colors.grey.shade200,
    };
  }

  Color _borderColor(EspacioDto espacio) {
    return switch (espacio.estado) {
      'DISPONIBLE' => AppTheme.primary,
      'OCUPADO' => Colors.red,
      'RESERVADO' => Colors.orange,
      'MANTENIMIENTO' => Colors.grey,
      _ => Colors.grey,
    };
  }

  Color _textColor(EspacioDto espacio) {
    return switch (espacio.estado) {
      'DISPONIBLE' => AppTheme.primary,
      'OCUPADO' => Colors.red,
      'RESERVADO' => Colors.orange.shade800,
      'MANTENIMIENTO' => Colors.grey.shade800,
      _ => Colors.black54,
    };
  }

  IconData _iconoTipo(EspacioDto espacio) {
    return espacio.tipo == 'MOTO' ? Icons.two_wheeler : Icons.directions_car;
  }

  Future<void> _recargar(WidgetRef ref, int parqueoId) async {
    ref.invalidate(espaciosPageProvider(parqueoId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final espaciosAsync = ref.watch(espaciosPageProvider(parqueoId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar espacio'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(espaciosPageProvider(parqueoId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: espaciosAsync.when(
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
                  'No se pudieron cargar los espacios.',
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
                  onPressed: () =>
                      ref.invalidate(espaciosPageProvider(parqueoId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (espacios) {
          if (espacios.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _recargar(ref, parqueoId),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.local_parking, size: 72, color: AppTheme.primary),
                  SizedBox(height: 16),
                  Text(
                    'No hay espacios registrados',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          final disponibles = espacios
              .where((espacio) => espacio.estado == 'DISPONIBLE')
              .length;

          final ocupados = espacios
              .where((espacio) => espacio.estado == 'OCUPADO')
              .length;
          
          final reservados = espacios
              .where((espacio) => espacio.estado == 'RESERVADO')
              .length;

          return RefreshIndicator(
            onRefresh: () => _recargar(ref, parqueoId),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Espacios del parqueo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Disponibles: $disponibles • Reservados: $reservados • Ocupados: $ocupados • Total: ${espacios.length}',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: espacios.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    final espacio = espacios[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: _backgroundColor(espacio),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _borderColor(espacio)),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_iconoTipo(espacio), color: _textColor(espacio)),
                          const SizedBox(height: 6),
                          Text(
                            espacio.codigo,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textColor(espacio),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            espacio.estado,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: _textColor(espacio),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
