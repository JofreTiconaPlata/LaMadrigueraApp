import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/features/parqueos/data/datasources/parqueos_remote_datasource.dart';
import 'package:la_madriguera/features/parqueos/data/models/parqueo_dto.dart';

import 'package:la_madriguera/features/espacios/presentation/pages/espacios_page.dart';

final detalleParqueoProvider = FutureProvider.family<ParqueoDto, int>((
  ref,
  parqueoId,
) async {
  final dataSource = ParqueosRemoteDataSource();

  return dataSource.getParqueoById(parqueoId);
});

class DetalleParqueoPage extends ConsumerWidget {
  final int parqueoId;

  const DetalleParqueoPage({super.key, required this.parqueoId});

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
        error: (error, _) => Center(child: Text('$error')),
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
                  color: AppTheme.primary,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EspaciosPage(parqueoId: parqueo.id),
                      ),
                    );
                  },
                  child: const Text('Ver espacios'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
