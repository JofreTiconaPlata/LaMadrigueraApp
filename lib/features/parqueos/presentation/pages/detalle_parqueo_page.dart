import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/features/parqueos/data/datasources/parqueos_remote_datasource.dart';
import 'package:la_madriguera/features/parqueos/data/models/parqueo_dto.dart';

const int parqueoDemoId = 1;

final detalleParqueoProvider = FutureProvider<ParqueoDto>((ref) async {
  final dataSource = ParqueosRemoteDataSource();

  return dataSource.getParqueoById(parqueoDemoId);
});

class DetalleParqueoPage extends ConsumerWidget {
  const DetalleParqueoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parqueoAsync = ref.watch(detalleParqueoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del parqueo'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(detalleParqueoProvider),
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
                  onPressed: () => ref.invalidate(detalleParqueoProvider),
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
              Row(
                children: [
                  const Icon(Icons.directions_car),
                  const SizedBox(width: 8),
                  Text('Espacios para autos: ${parqueo.espaciosAutos}'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.two_wheeler),
                  const SizedBox(width: 8),
                  Text('Espacios para motos: ${parqueo.espaciosMotos}'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.local_parking),
                  const SizedBox(width: 8),
                  Text('Capacidad total: ${parqueo.capacidadTotal}'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 8),
                  Text('Estado: ${parqueo.estado}'),
                ],
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
