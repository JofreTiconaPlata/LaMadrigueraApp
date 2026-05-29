import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/espacios/data/datasources/espacios_remote_datasource.dart';
import 'package:la_madriguera/features/espacios/data/models/espacio_dto.dart';
import 'package:la_madriguera/features/espacios/presentation/pages/espacios_page.dart'
    show espaciosPageProvider;
import 'package:la_madriguera/features/parqueos/domain/entities/parqueo_entity.dart';
import 'package:la_madriguera/features/reservas/data/datasources/reservas_remote_datasource.dart';
import 'package:la_madriguera/features/tarifas/data/datasources/tarifas_remote_datasource.dart';
import 'package:la_madriguera/features/tarifas/data/models/tarifa_dto.dart';
import 'package:la_madriguera/features/vehiculos/data/models/vehiculo_dto.dart';
import 'package:la_madriguera/features/vehiculos/presentation/providers/vehiculos_provider.dart';

final espaciosReservaProvider = FutureProvider.family<List<EspacioDto>, int>((
  ref,
  parqueoId,
) async {
  final dataSource = EspaciosRemoteDataSource();

  return dataSource.getEspacios(parqueoId: parqueoId);
});

final tarifasReservaProvider = FutureProvider.family<List<TarifaDto>, int>((
  ref,
  parqueoId,
) async {
  final dataSource = TarifasRemoteDataSource();

  return dataSource.getTarifas(parqueoId: parqueoId);
});

class CrearReservaPage extends ConsumerStatefulWidget {
  const CrearReservaPage({super.key, required this.parqueo});

  final ParqueoEntity parqueo;

  @override
  ConsumerState<CrearReservaPage> createState() => _CrearReservaPageState();
}

class _CrearReservaPageState extends ConsumerState<CrearReservaPage> {
  int? _vehiculoId;
  int? _espacioId;
  int _horasReserva = 1;
  bool _guardando = false;

  int get _parqueoId => int.parse(widget.parqueo.id);

  Future<void> _confirmarReserva(TarifaDto? tarifaActiva) async {
    if (_guardando) {
      return;
    }

    if (_vehiculoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un vehículo registrado.')),
      );
      return;
    }

    if (_espacioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un espacio disponible.')),
      );
      return;
    }

    if (tarifaActiva == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este parqueo no tiene una tarifa activa para este tipo de vehículo.',
          ),
        ),
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
        espacioId: _espacioId!,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      ref.invalidate(espaciosPageProvider(_parqueoId));
      ref.invalidate(espaciosReservaProvider(_parqueoId));
      ref.invalidate(tarifasReservaProvider(_parqueoId));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reserva creada correctamente. Tarifa: ${tarifaActiva.montoHora.toStringAsFixed(2)} Bs/hora.',
          ),
        ),
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

  String? _tipoVehiculoSeleccionado(List<VehiculoDto> vehiculos) {
    for (final vehiculo in vehiculos) {
      if (vehiculo.id == _vehiculoId) {
        return vehiculo.tipo.toUpperCase();
      }
    }

    return null;
  }

  TarifaDto? _tarifaActivaPorVehiculo({
    required List<TarifaDto> tarifas,
    required List<VehiculoDto> vehiculos,
  }) {
    final tipoVehiculo = _tipoVehiculoSeleccionado(vehiculos);

    if (tipoVehiculo == null) {
      return null;
    }

    for (final tarifa in tarifas) {
      if (tarifa.estaActiva &&
          tarifa.montoHora > 0 &&
          tarifa.tipoVehiculo.toUpperCase() == tipoVehiculo) {
        return tarifa;
      }
    }

    return null;
  }

  Widget _infoTarifa({
    required TarifaDto? tarifa,
    required bool hayVehiculoSeleccionado,
  }) {
    if (!hayVehiculoSeleccionado) {
      return const Text(
        'Selecciona un vehículo para ver la tarifa.',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      );
    }

    if (tarifa == null) {
      return const Text(
        'Este parqueo no tiene una tarifa activa para este tipo de vehículo.',
        style: TextStyle(color: Colors.redAccent, fontSize: 12),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB7D6B9)),
      ),
      child: Text(
        'Tarifa: ${tarifa.montoHora.toStringAsFixed(2)} Bs/hora',
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<EspacioDto> _espaciosDisponiblesPorVehiculo({
    required List<EspacioDto> espacios,
    required List<VehiculoDto> vehiculos,
  }) {
    final tipoVehiculo = _tipoVehiculoSeleccionado(vehiculos);

    if (tipoVehiculo == null) {
      return [];
    }

    return espacios
        .where(
          (espacio) =>
              espacio.estado == 'DISPONIBLE' &&
              espacio.tipo.toUpperCase() == tipoVehiculo,
        )
        .toList();
  }

  DropdownMenuItem<int> _espacioItem(EspacioDto espacio) {
    return DropdownMenuItem<int>(
      value: espacio.id,
      child: Text('${espacio.codigo} - ${espacio.tipo}'),
    );
  }

  Widget _selectorEspacio({
    required List<EspacioDto> espacios,
    required List<VehiculoDto> vehiculos,
  }) {
    final espaciosDisponibles = _espaciosDisponiblesPorVehiculo(
      espacios: espacios,
      vehiculos: vehiculos,
    );

    final hayVehiculoSeleccionado = _vehiculoId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          initialValue: _espacioId,
          decoration: InputDecoration(
            labelText: 'Espacio disponible',
            prefixIcon: const Icon(Icons.local_parking),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          items: espaciosDisponibles.map(_espacioItem).toList(),
          onChanged: _guardando || !hayVehiculoSeleccionado
              ? null
              : (value) {
                  setState(() {
                    _espacioId = value;
                  });
                },
        ),
        if (!hayVehiculoSeleccionado) ...[
          const SizedBox(height: 8),
          const Text(
            'Primero selecciona un vehículo para ver espacios compatibles.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
        if (hayVehiculoSeleccionado && espaciosDisponibles.isEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'No hay espacios disponibles para este tipo de vehículo.',
            style: TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
      ],
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

  Widget _errorView({
    required String message,
    required Object error,
    required VoidCallback onRetry,
  }) {
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

  @override
  Widget build(BuildContext context) {
    final vehiculosAsync = ref.watch(vehiculosClienteProvider);
    final espaciosAsync = ref.watch(espaciosReservaProvider(_parqueoId));
    final tarifasAsync = ref.watch(tarifasReservaProvider(_parqueoId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Reservar espacio')),
      body: vehiculosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _errorView(
          message: 'No se pudieron cargar tus vehículos.',
          error: error,
          onRetry: () => ref.invalidate(vehiculosClienteProvider),
        ),
        data: (vehiculos) {
          return espaciosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _errorView(
              message: 'No se pudieron cargar los espacios.',
              error: error,
              onRetry: () =>
                  ref.invalidate(espaciosReservaProvider(_parqueoId)),
            ),
            data: (espacios) {
              return tarifasAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _errorView(
                  message: 'No se pudieron cargar las tarifas.',
                  error: error,
                  onRetry: () =>
                      ref.invalidate(tarifasReservaProvider(_parqueoId)),
                ),
                data: (tarifas) {
                  final tarifaActiva = _tarifaActivaPorVehiculo(
                    tarifas: tarifas,
                    vehiculos: vehiculos,
                  );

                  final hayVehiculoSeleccionado = _vehiculoId != null;

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
                                  _espacioId = null;
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
                            await Navigator.pushNamed(
                              context,
                              RouteNames.vehiculos,
                            );
                            ref.invalidate(vehiculosClienteProvider);
                          },
                          icon: const Icon(Icons.directions_car),
                          label: const Text('Registrar vehículo'),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _selectorEspacio(
                        espacios: espacios,
                        vehiculos: vehiculos,
                      ),
                      const SizedBox(height: 16),
                      _infoTarifa(
                        tarifa: tarifaActiva,
                        hayVehiculoSeleccionado: hayVehiculoSeleccionado,
                      ),
                      const SizedBox(height: 16),
                      _selectorHoras(),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _guardando || vehiculos.isEmpty
                              ? null
                              : () => _confirmarReserva(tarifaActiva),
                          icon: _guardando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.timer),
                          label: Text(
                            _guardando ? 'Reservando...' : 'Crear reserva',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
