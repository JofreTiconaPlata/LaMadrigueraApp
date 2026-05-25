import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/features/espacios/data/datasources/espacios_remote_datasource.dart';
import 'package:la_madriguera/features/espacios/data/models/espacio_dto.dart';
import 'package:la_madriguera/features/ingresos/data/datasources/ingresos_remote_datasource.dart';
import 'package:la_madriguera/features/vehiculos/data/datasources/vehiculos_remote_datasource.dart';
import 'package:la_madriguera/features/vehiculos/data/models/vehiculo_dto.dart';

const int parqueoDemoId = 1;

final vehiculosIngresoProvider = FutureProvider<List<VehiculoDto>>((ref) async {
  final dataSource = VehiculosRemoteDataSource();

  return dataSource.getVehiculos();
});

final espaciosIngresoProvider = FutureProvider<List<EspacioDto>>((ref) async {
  final dataSource = EspaciosRemoteDataSource();

  return dataSource.getEspacios(parqueoId: parqueoDemoId);
});

class RegistrarIngresoPage extends ConsumerStatefulWidget {
  const RegistrarIngresoPage({super.key});

  @override
  ConsumerState<RegistrarIngresoPage> createState() =>
      _RegistrarIngresoPageState();
}

class _RegistrarIngresoPageState extends ConsumerState<RegistrarIngresoPage> {
  int? vehiculoId;
  int? espacioId;
  bool registrando = false;

  Future<void> registrarIngreso() async {
    if (vehiculoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un vehículo registrado')),
      );
      return;
    }

    if (espacioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un espacio disponible')),
      );
      return;
    }

    setState(() {
      registrando = true;
    });

    try {
      final dataSource = IngresosRemoteDataSource();

      await dataSource.registrarIngreso(
        parqueoId: parqueoDemoId,
        espacioId: espacioId!,
        vehiculoId: vehiculoId!,
      );

      ref.invalidate(espaciosIngresoProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingreso registrado correctamente')),
      );

      Navigator.pushNamed(context, '/vehiculos-estacionados');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar el ingreso: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          registrando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiculosAsync = ref.watch(vehiculosIngresoProvider);
    final espaciosAsync = ref.watch(espaciosIngresoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar ingreso'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(vehiculosIngresoProvider);
              ref.invalidate(espaciosIngresoProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: vehiculosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: 'No se pudieron cargar los vehículos.',
          error: error,
          onRetry: () => ref.invalidate(vehiculosIngresoProvider),
        ),
        data: (vehiculos) {
          return espaciosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorView(
              message: 'No se pudieron cargar los espacios.',
              error: error,
              onRetry: () => ref.invalidate(espaciosIngresoProvider),
            ),
            data: (espacios) {
              final espaciosDisponibles = espacios
                  .where((espacio) => espacio.estaDisponible)
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Ingreso de vehículo',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona un vehículo registrado y asígnale un espacio disponible.',
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<int>(
                    initialValue: vehiculoId,
                    decoration: InputDecoration(
                      labelText: 'Vehículo',
                      prefixIcon: const Icon(Icons.directions_car),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: vehiculos.map((vehiculo) {
                      return DropdownMenuItem<int>(
                        value: vehiculo.id,
                        child: Text(
                          '${vehiculo.placa} - ${vehiculo.tipo}'
                          '${vehiculo.marca == null ? '' : ' � ${vehiculo.marca}'}',
                        ),
                      );
                    }).toList(),
                    onChanged: registrando
                        ? null
                        : (value) {
                            setState(() {
                              vehiculoId = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: espacioId,
                    decoration: InputDecoration(
                      labelText: 'Espacio disponible',
                      prefixIcon: const Icon(Icons.local_parking),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: espaciosDisponibles.map((espacio) {
                      return DropdownMenuItem<int>(
                        value: espacio.id,
                        child: Text('${espacio.codigo} - ${espacio.tipo}'),
                      );
                    }).toList(),
                    onChanged: registrando
                        ? null
                        : (value) {
                            setState(() {
                              espacioId = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: false,
                    controller: TextEditingController(text: 'Ahora'),
                    decoration: InputDecoration(
                      labelText: 'Hora de ingreso',
                      prefixIcon: const Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: registrando ? null : registrarIngreso,
                      icon: registrando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        registrando ? 'Registrando...' : 'Registrar ingreso',
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.error,
    required this.onRetry,
  });

  final String message;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
