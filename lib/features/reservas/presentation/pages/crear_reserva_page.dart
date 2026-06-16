import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/espacios/data/datasources/espacios_remote_datasource.dart';
import 'package:la_madriguera/features/espacios/data/models/espacio_dto.dart';
import 'package:la_madriguera/features/espacios/presentation/pages/espacios_page.dart'
    show espaciosPageProvider;
import 'package:la_madriguera/features/parqueos/domain/entities/parqueo_entity.dart';
import 'package:la_madriguera/features/reservas/presentation/providers/reservas_provider.dart';
import 'package:la_madriguera/features/tarifas/data/datasources/tarifas_remote_datasource.dart';
import 'package:la_madriguera/features/vehiculos/presentation/providers/vehiculos_provider.dart';

class CrearReservaPage extends ConsumerStatefulWidget {
  const CrearReservaPage({super.key, required this.parqueo});

  final ParqueoEntity parqueo;

  @override
  ConsumerState<CrearReservaPage> createState() => _CrearReservaPageState();
}

class _CrearReservaPageState extends ConsumerState<CrearReservaPage> {
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();

  String _tipoVehiculo = 'AUTO';
  int _horasReserva = 1;
  bool _guardando = false;
  EspacioDto? _espacioSeleccionado;

  @override
  void dispose() {
    _placaController.dispose();
    super.dispose();
  }

  String? _validarPlaca(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Ingresa la placa del vehículo';
    }

    if (text.length < 5) {
      return 'La placa debe tener al menos 5 caracteres';
    }

    if (text.length > 12) {
      return 'La placa no puede superar 12 caracteres';
    }

    return null;
  }

  Future<double> _obtenerMontoHora(int parqueoId) async {
    final tarifas = await TarifasRemoteDataSource().getTarifas(
      parqueoId: parqueoId,
      tipoVehiculo: _tipoVehiculo,
    );

    for (final tarifa in tarifas) {
      if (tarifa.estado == 'ACTIVO' && tarifa.montoHora > 0) {
        return tarifa.montoHora;
      }
    }

    if (widget.parqueo.precioHora > 0) {
      return widget.parqueo.precioHora;
    }

    throw Exception(
      'Este parqueo no tiene una tarifa activa para $_tipoVehiculo.',
    );
  }

  Future<int> _obtenerOCrearVehiculoId() async {
    final placa = _placaController.text.trim().toUpperCase();
    final dataSource = ref.read(vehiculosDataSourceProvider);

    final vehiculos = await dataSource.getVehiculos();

    for (final vehiculo in vehiculos) {
      if (vehiculo.placa.toUpperCase() == placa) {
        return vehiculo.id;
      }
    }

    final nuevoVehiculo = await dataSource.createVehiculo(
      placa: placa,
      tipo: _tipoVehiculo,
    );

    ref.invalidate(vehiculosClienteProvider);

    return nuevoVehiculo.id;
  }

  Future<void> _abrirSelectorEspacio(String tipoVehiculo) async {
    final parqueoId = int.tryParse(widget.parqueo.id);

    if (parqueoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El ID del parqueo no es válido.')),
      );
      return;
    }

    setState(() {
      _tipoVehiculo = tipoVehiculo;
      _espacioSeleccionado = null;
    });

    final seleccionado = await showModalBottomSheet<EspacioDto>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SelectorEspacioSheet(
          parqueoId: parqueoId,
          tipoVehiculo: tipoVehiculo,
        );
      },
    );

    if (seleccionado == null || !mounted) return;

    setState(() {
      _espacioSeleccionado = seleccionado;
    });
  }

  Future<void> _confirmarReserva() async {
    final formValido = _formKey.currentState?.validate() ?? false;

    if (!formValido || _guardando) {
      return;
    }

    if (_espacioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un espacio disponible.')),
      );
      return;
    }

    final parqueoId = int.tryParse(widget.parqueo.id);

    if (parqueoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El ID del parqueo no es válido.')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final montoHora = await _obtenerMontoHora(parqueoId);

      final vehiculoId = await _obtenerOCrearVehiculoId();

      final fechaInicio = DateTime.now();
      final fechaFin = fechaInicio.add(Duration(hours: _horasReserva));

      final reservasDataSource = ref.read(reservasDataSourceProvider);

      await reservasDataSource.crearReserva(
        parqueoId: parqueoId,
        vehiculoId: vehiculoId,
        espacioId: _espacioSeleccionado!.id,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      ref.invalidate(misReservasProvider);
      ref.invalidate(espaciosPageProvider(parqueoId));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reserva creada. Espacio ${_espacioSeleccionado!.codigo} reservado. El cronómetro comenzará cuando el operador confirme tu ingreso. Tarifa: ${montoHora.toStringAsFixed(2)} Bs/hora.',
          ),
        ),
      );

      Navigator.pop(context, true);
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

  Widget _tipoButton({
    required String tipo,
    required String label,
    required IconData icon,
  }) {
    final seleccionado = _tipoVehiculo == tipo;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _guardando ? null : () => _abrirSelectorEspacio(tipo),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: seleccionado ? AppTheme.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: seleccionado
                  ? AppTheme.primaryGreen
                  : const Color(0xFFE2E8E4),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: seleccionado ? Colors.white : AppTheme.primaryGreen,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: seleccionado ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectorTipoVehiculo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de vehículo',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _tipoButton(
              tipo: 'AUTO',
              label: 'Auto',
              icon: Icons.directions_car,
            ),
            const SizedBox(width: 12),
            _tipoButton(tipo: 'MOTO', label: 'Moto', icon: Icons.two_wheeler),
          ],
        ),
      ],
    );
  }

  Widget _espacioElegidoCard() {
    final espacio = _espacioSeleccionado;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _guardando ? null : () => _abrirSelectorEspacio(_tipoVehiculo),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: espacio == null
              ? Colors.white
              : AppTheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: espacio == null ? const Color(0xFFE2E8E4) : AppTheme.primary,
          ),
        ),
        child: Row(
          children: [
            Icon(
              espacio == null
                  ? Icons.local_parking_outlined
                  : Icons.check_circle,
              color: espacio == null ? Colors.black45 : AppTheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                espacio == null
                    ? 'Toca Auto o Moto para escoger un espacio disponible'
                    : 'Espacio seleccionado: ${espacio.codigo} (${espacio.tipo})',
                style: TextStyle(
                  color: espacio == null ? Colors.black54 : AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_up),
          ],
        ),
      ),
    );
  }

  Widget _tarifaInfoCard() {
    final parqueoId = int.tryParse(widget.parqueo.id);

    if (parqueoId == null) {
      return const Text(
        'No se puede obtener la tarifa porque el ID del parqueo no es válido.',
        style: TextStyle(color: Colors.redAccent, fontSize: 12),
      );
    }

    return FutureBuilder<double>(
      future: _obtenerMontoHora(parqueoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Cargando tarifa...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'No hay tarifa activa para $_tipoVehiculo.',
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          );
        }

        final montoHora = snapshot.data ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFB7D6B9)),
          ),
          child: Text(
            'Tarifa: ${montoHora.toStringAsFixed(2)} Bs/hora',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Reservar espacio')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _infoParqueo(),
            const SizedBox(height: 18),
            _selectorTipoVehiculo(),
            const SizedBox(height: 14),
            _tarifaInfoCard(),
            const SizedBox(height: 14),
            _espacioElegidoCard(),
            const SizedBox(height: 18),
            TextFormField(
              controller: _placaController,
              enabled: !_guardando,
              textCapitalization: TextCapitalization.characters,
              validator: _validarPlaca,
              decoration: InputDecoration(
                labelText: 'Placa del vehículo',
                prefixIcon: const Icon(Icons.pin),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _selectorHoras(),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _confirmarReserva,
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
        ),
      ),
    );
  }
}

class _SelectorEspacioSheet extends StatelessWidget {
  const _SelectorEspacioSheet({
    required this.parqueoId,
    required this.tipoVehiculo,
  });

  final int parqueoId;
  final String tipoVehiculo;

  IconData get _iconoTipo {
    return tipoVehiculo == 'MOTO' ? Icons.two_wheeler : Icons.directions_car;
  }

  String get _labelTipo {
    return tipoVehiculo == 'MOTO' ? 'moto' : 'auto';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: FutureBuilder<List<EspacioDto>>(
        future: EspaciosRemoteDataSource().getEspacios(parqueoId: parqueoId),
        builder: (context, snapshot) {
          final cargando = snapshot.connectionState == ConnectionState.waiting;

          if (cargando) {
            return const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return SizedBox(
              height: 280,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'No se pudieron cargar los espacios: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          final espacios = snapshot.data ?? [];
          final disponibles = espacios
              .where(
                (espacio) =>
                    espacio.estado == 'DISPONIBLE' &&
                    espacio.tipo == tipoVehiculo,
              )
              .toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(_iconoTipo, color: AppTheme.primaryGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Escoge un espacio de $_labelTipo',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                disponibles.isEmpty
                    ? 'No hay espacios disponibles para este tipo de vehículo.'
                    : 'Toca un espacio verde para seleccionarlo.',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              if (disponibles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.black38,
                  ),
                )
              else
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: disponibles.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                        ),
                    itemBuilder: (context, index) {
                      final espacio = disponibles[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pop(context, espacio),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.primary),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_iconoTipo, color: AppTheme.primary),
                              const SizedBox(height: 6),
                              Text(
                                espacio.codigo,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'DISPONIBLE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
