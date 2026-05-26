import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/vehiculos/presentation/providers/vehiculos_provider.dart';
import 'package:la_madriguera/features/vehiculos/presentation/widgets/vehiculo_card.dart';

class VehiculosPage extends ConsumerStatefulWidget {
  const VehiculosPage({super.key});

  @override
  ConsumerState<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends ConsumerState<VehiculosPage> {
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _colorController = TextEditingController();

  String _tipo = 'AUTO';
  bool _guardando = false;

  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  String? _validarPlaca(String? value) {
    final text = value?.trim() ?? '';

    if (text.length < 5) {
      return 'La placa debe tener al menos 5 caracteres';
    }

    if (text.length > 12) {
      return 'La placa no puede superar 12 caracteres';
    }

    return null;
  }

  Future<void> _crearVehiculo() async {
    final formValido = _formKey.currentState?.validate() ?? false;

    if (!formValido || _guardando) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final dataSource = ref.read(vehiculosDataSourceProvider);

      await dataSource.createVehiculo(
        placa: _placaController.text,
        tipo: _tipo,
        marca: _marcaController.text,
        modelo: _modeloController.text,
        color: _colorController.text,
      );

      if (!mounted) return;

      _placaController.clear();
      _marcaController.clear();
      _modeloController.clear();
      _colorController.clear();

      ref.invalidate(vehiculosClienteProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo registrado correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar el vehículo: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Future<void> _eliminarVehiculo(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar vehículo'),
          content: const Text('¿Seguro que deseas eliminar este vehículo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      final dataSource = ref.read(vehiculosDataSourceProvider);

      await dataSource.deleteVehiculo(id);

      ref.invalidate(vehiculosClienteProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vehículo eliminado')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el vehículo: $error')),
      );
    }
  }

  Widget _formulario() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Registrar vehículo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _placaController,
                textCapitalization: TextCapitalization.characters,
                validator: _validarPlaca,
                decoration: InputDecoration(
                  labelText: 'Placa',
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: const Icon(Icons.directions_car),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'AUTO', child: Text('Auto')),
                  DropdownMenuItem(value: 'MOTO', child: Text('Moto')),
                  DropdownMenuItem(
                    value: 'CAMIONETA',
                    child: Text('Camioneta'),
                  ),
                ],
                onChanged: _guardando
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _tipo = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _marcaController,
                decoration: InputDecoration(
                  labelText: 'Marca opcional',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(
                  labelText: 'Modelo opcional',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(
                  labelText: 'Color opcional',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _crearVehiculo,
                  icon: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(_guardando ? 'Guardando...' : 'Agregar vehículo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _recargar() async {
    ref.invalidate(vehiculosClienteProvider);
  }

  @override
  Widget build(BuildContext context) {
    final vehiculosAsync = ref.watch(vehiculosClienteProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mis vehículos'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(vehiculosClienteProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _recargar,
        child: vehiculosAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(24),
            children: const [
              SizedBox(height: 180),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
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
            ],
          ),
          data: (vehiculos) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _formulario(),
                const SizedBox(height: 18),
                const Text(
                  'Vehículos registrados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (vehiculos.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aún no tienes vehículos registrados.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...vehiculos.map(
                    (vehiculo) => VehiculoCard(
                      vehiculo: vehiculo,
                      onDelete: () => _eliminarVehiculo(vehiculo.id),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
