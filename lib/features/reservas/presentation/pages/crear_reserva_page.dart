import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/espacios/presentation/pages/espacios_page.dart'
    show espaciosPageProvider;
import 'package:la_madriguera/features/parqueos/domain/entities/parqueo_entity.dart';
import 'package:la_madriguera/features/reservas/data/datasources/reservas_remote_datasource.dart';
import 'package:la_madriguera/features/vehiculos/data/models/vehiculo_dto.dart';
import 'package:la_madriguera/features/vehiculos/presentation/providers/vehiculos_provider.dart';

class CrearReservaPage extends ConsumerStatefulWidget {
  const CrearReservaPage({super.key, required this.parqueo});

  final ParqueoEntity parqueo;

  @override
  ConsumerState<CrearReservaPage> createState() => _CrearReservaPageState();
}

class _CrearReservaPageState extends ConsumerState<CrearReservaPage> {
  int? _vehiculoId;
  int _horasReserva = 1;
  bool _guardando = false;

  int get _parqueoId => int.parse(widget.parqueo.id);

  Future<void> _confirmarReserva() async {
    if (_vehiculoId == null || _guardando) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un vehículo registrado.')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final dataSource = ReservasRemoteDataSource();
      final fechaInicio = DateTime.now();
      final fechaFin = fechaInicio.add(Duration(hours: _horasReserva));

      await dataSource.crearReserva(
        parqueoId: _parqueoId,
        vehiculoId: _vehiculoId!,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      
      ref.invalidate(espaciosPageProvider(_parqueoId));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva creada correctamente.')),
      );

      Navigator.pushReplacementNamed(context, RouteNames.misReservas);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear la reserva: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Widget _infoParqueo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB7D6B9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.parqueo.nombre,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.parqueo.direccion,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            'Espacios: ${widget.parqueo.espaciosAutos} autos, ${widget.parqueo.espaciosMotos} motos',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<int> _vehiculoItem(VehiculoDto vehiculo) {
    final detalles = [
      vehiculo.tipo,
      if (vehiculo.marca != null && vehiculo.marca!.isNotEmpty) vehiculo.marca,
      if (vehiculo.modelo != null && vehiculo.modelo!.isNotEmpty)
        vehiculo.modelo,
    ].join(' · ');

    return DropdownMenuItem<int>(
      value: vehiculo.id,
      child: Text('${vehiculo.placa} - $detalles'),
    );
  }

  Widget _selectorHoras() {
    return DropdownButtonFormField<int>(
      initialValue: _horasReserva,
      decoration: InputDecoration(
        labelText: 'Duración estimada',
        prefixIcon: const Icon(Icons.schedule),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: const [
        DropdownMenuItem(value: 1, child: Text('1 hora')),
        DropdownMenuItem(value: 2, child: Text('2 horas')),
        DropdownMenuItem(value: 3, child: Text('3 horas')),
        DropdownMenuItem(value: 4, child: Text('4 horas')),
      ],
      onChanged: _guardando
          ? null
          : (value) {
              if (value == null) return;
              setState(() {
                _horasReserva = value;
              });
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehiculosAsync = ref.watch(vehiculosClienteProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Reservar espacio')),
      body: vehiculosAsync.when(
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
                  'No se pudieron cargar tus vehículos.',
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
                  onPressed: () => ref.invalidate(vehiculosClienteProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (vehiculos) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _infoParqueo(),
              const SizedBox(height: 18),
              DropdownButtonFormField<int>(
                initialValue: _vehiculoId,
                decoration: InputDecoration(
                  labelText: 'Vehículo registrado',
                  prefixIcon: const Icon(Icons.directions_car),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: vehiculos.map(_vehiculoItem).toList(),
                onChanged: _guardando
                    ? null
                    : (value) {
                        setState(() {
                          _vehiculoId = value;
                        });
                      },
              ),
              if (vehiculos.isEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Primero registra un vehículo para poder reservar un espacio.',
                  style: TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, RouteNames.vehiculos);
                    ref.invalidate(vehiculosClienteProvider);
                  },
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Registrar vehículo'),
                ),
              ],
              const SizedBox(height: 16),
              _selectorHoras(),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _guardando || vehiculos.isEmpty
                      ? null
                      : _confirmarReserva,
                  icon: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.timer),
                  label: Text(_guardando ? 'Reservando...' : 'Crear reserva'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}