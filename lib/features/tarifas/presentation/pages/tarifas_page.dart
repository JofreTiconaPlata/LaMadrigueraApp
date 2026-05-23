import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/features/tarifas/data/datasources/tarifas_remote_datasource.dart';
import 'package:la_madriguera/features/tarifas/data/models/tarifa_dto.dart';

const int parqueoDemoId = 1;

final tarifasPageProvider = FutureProvider<List<TarifaDto>>((ref) async {
  final dataSource = TarifasRemoteDataSource();

  return dataSource.getTarifas(parqueoId: parqueoDemoId);
});

class TarifasPage extends ConsumerWidget {
  const TarifasPage({super.key});

  String _tipoLegible(String tipo) {
    return switch (tipo) {
      'AUTO' => 'Auto',
      'MOTO' => 'Moto',
      'CAMIONETA' => 'Camioneta',
      _ => tipo,
    };
  }

  Color _estadoColor(String estado) {
    return estado == 'ACTIVO' ? const Color(0xFF2E7D32) : Colors.grey;
  }

  Future<void> _recargar(WidgetRef ref) async {
    ref.invalidate(tarifasPageProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarifasAsync = ref.watch(tarifasPageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarifas'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(tarifasPageProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alta de tarifas desde app pendiente.'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: tarifasAsync.when(
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
                  'No se pudieron cargar las tarifas.',
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
                  onPressed: () => ref.invalidate(tarifasPageProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (tarifas) {
          if (tarifas.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _recargar(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.payments, size: 72, color: Color(0xFF2E7D32)),
                  SizedBox(height: 16),
                  Text(
                    'No hay tarifas registradas',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  'Gestión de tarifas',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${tarifas.length} tarifa(s) registradas en backend',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ...tarifas.map((tarifa) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: Icon(
                          tarifa.tipoVehiculo == 'MOTO'
                              ? Icons.two_wheeler
                              : Icons.directions_car,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      title: Text(
                        '${_tipoLegible(tarifa.tipoVehiculo)} - Bs ${tarifa.montoHora.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Fracción: ${tarifa.montoFraccion == null ? 'No definida' : 'Bs ${tarifa.montoFraccion!.toStringAsFixed(2)}'}',
                      ),
                      trailing: Chip(
                        label: Text(tarifa.estado),
                        labelStyle: TextStyle(
                          color: _estadoColor(tarifa.estado),
                          fontWeight: FontWeight.bold,
                        ),
                        side: BorderSide(color: _estadoColor(tarifa.estado)),
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
