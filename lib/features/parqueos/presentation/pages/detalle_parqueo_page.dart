import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/features/parqueos/data/datasources/parqueos_remote_datasource.dart';
import 'package:la_madriguera/features/parqueos/data/models/parqueo_dto.dart';

final detalleParqueoProvider = FutureProvider.family<ParqueoDto, int>((
  ref,
  parqueoId,
) async {
  final dataSource = ParqueosRemoteDataSource();

  return dataSource.getParqueoById(parqueoId);
});

class DetalleParqueoPage extends ConsumerWidget {
  const DetalleParqueoPage({required this.parqueoId, super.key});

  final int parqueoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parqueoAsync = ref.watch(detalleParqueoProvider(parqueoId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del parqueo'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(detalleParqueoProvider(parqueoId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: parqueoAsync.when(
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
                  'No se pudo cargar el parqueo.',
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
                      ref.invalidate(detalleParqueoProvider(parqueoId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (parqueo) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                height: 190,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDEFE0),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.local_parking,
                  size: 100,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                parqueo.nombre,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(parqueo.direccion),
              const SizedBox(height: 18),
              _InfoRow(
                icon: Icons.directions_car,
                text: 'Espacios para autos: ${parqueo.espaciosAutos}',
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.two_wheeler,
                text: 'Espacios para motos: ${parqueo.espaciosMotos}',
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.local_parking,
                text: 'Capacidad total: ${parqueo.capacidadTotal}',
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.info_outline,
                text: 'Estado: ${parqueo.estado}',
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/espacios'),
                  child: const Text('Ver espacios'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/tarifas'),
                  child: const Text('Ver tarifas'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
