import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/parqueos/data/datasources/parqueos_remote_datasource.dart';

class CrearParqueoPage extends StatefulWidget {
  const CrearParqueoPage({super.key});

  @override
  State<CrearParqueoPage> createState() => _CrearParqueoPageState();
}

class _CrearParqueoPageState extends State<CrearParqueoPage> {
  static final LatLng _centroMapa = LatLng(-17.3935, -66.1570);

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _autosController = TextEditingController();
  final _motosController = TextEditingController();
  final _tarifaAutoController = TextEditingController();
  final _tarifaMotoController = TextEditingController();

  LatLng? _ubicacionSeleccionada;
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _autosController.dispose();
    _motosController.dispose();
    _tarifaAutoController.dispose();
    _tarifaMotoController.dispose();
    super.dispose();
  }

  Future<void> _guardarParqueo() async {
    final formularioValido = _formKey.currentState?.validate() ?? false;

    if (!formularioValido) {
      return;
    }

    if (_ubicacionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una ubicación en el mapa.')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final dataSource = ParqueosRemoteDataSource();

      await dataSource.createParqueo(
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        latitud: _ubicacionSeleccionada!.latitude,
        longitud: _ubicacionSeleccionada!.longitude,
        espaciosAutos: int.parse(_autosController.text.trim()),
        espaciosMotos: int.parse(_motosController.text.trim()),
        tarifaAutoHora: double.parse(_tarifaAutoController.text.trim()),
        tarifaMotoHora: double.parse(_tarifaMotoController.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parqueo, espacios y tarifas registrados correctamente.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar el parqueo: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  String? _validarTexto(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $campo';
    }

    return null;
  }

  String? _validarEntero(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $campo';
    }

    final numero = int.tryParse(value.trim());

    if (numero == null || numero < 0) {
      return 'Ingresa un número válido';
    }

    return null;
  }

  String? _validarTarifa(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $campo';
    }

    final precio = double.tryParse(value.trim());

    if (precio == null || precio <= 0) {
      return 'Ingresa una tarifa válida mayor a 0';
    }

    return null;
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_guardando,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _tarifasCard() {
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
          const Text(
            'Tarifas por hora',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Estas tarifas se guardarán en la base de datos y se usarán al reservar.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          _campoTexto(
            controller: _tarifaAutoController,
            label: 'Tarifa para autos (Bs/hora)',
            icon: Icons.directions_car,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) => _validarTarifa(value, 'la tarifa para autos'),
          ),
          const SizedBox(height: 14),
          _campoTexto(
            controller: _tarifaMotoController,
            label: 'Tarifa para motos (Bs/hora)',
            icon: Icons.two_wheeler,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) => _validarTarifa(value, 'la tarifa para motos'),
          ),
        ],
      ),
    );
  }

  Widget _mapaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación del parqueo',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Toca el mapa para marcar dónde estará ubicado el parqueo.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFB7D6B9)),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _ubicacionSeleccionada ?? _centroMapa,
              initialZoom: 14,
              onTap: _guardando
                  ? null
                  : (_, point) {
                      setState(() {
                        _ubicacionSeleccionada = point;
                      });
                    },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.programovil.lamadriguera',
              ),
              if (_ubicacionSeleccionada != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _ubicacionSeleccionada!,
                      width: 56,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_parking,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (_ubicacionSeleccionada != null) ...[
          const SizedBox(height: 8),
          Text(
            'Lat: ${_ubicacionSeleccionada!.latitude.toStringAsFixed(6)} '
            'Lng: ${_ubicacionSeleccionada!.longitude.toStringAsFixed(6)}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Registrar parqueo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _campoTexto(
              controller: _nombreController,
              label: 'Nombre del parqueo',
              icon: Icons.local_parking,
              validator: (value) => _validarTexto(value, 'el nombre'),
            ),
            const SizedBox(height: 16),
            _campoTexto(
              controller: _direccionController,
              label: 'Dirección o referencia',
              icon: Icons.place,
              validator: (value) => _validarTexto(value, 'la dirección'),
            ),
            const SizedBox(height: 16),
            _campoTexto(
              controller: _autosController,
              label: 'Cantidad de espacios para autos',
              icon: Icons.directions_car,
              keyboardType: TextInputType.number,
              validator: (value) => _validarEntero(value, 'los espacios para autos'),
            ),
            const SizedBox(height: 16),
            _campoTexto(
              controller: _motosController,
              label: 'Cantidad de espacios para motos',
              icon: Icons.two_wheeler,
              keyboardType: TextInputType.number,
              validator: (value) => _validarEntero(value, 'los espacios para motos'),
            ),
            const SizedBox(height: 16),
            _tarifasCard(),
            const SizedBox(height: 24),
            _mapaSelector(),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardarParqueo,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_guardando ? 'Guardando...' : 'Guardar parqueo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
