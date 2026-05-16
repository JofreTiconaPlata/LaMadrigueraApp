import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/parqueos/domain/entities/parqueo_entity.dart';
import 'package:la_madriguera/features/reservas/domain/entities/reserva_activa_entity.dart';
import 'package:la_madriguera/features/reservas/presentation/providers/reserva_activa_provider.dart';

class CrearReservaPage extends StatefulWidget {
  const CrearReservaPage({super.key, required this.parqueo});

  final ParqueoEntity parqueo;

  @override
  State<CrearReservaPage> createState() => _CrearReservaPageState();
}

class _CrearReservaPageState extends State<CrearReservaPage> {
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _nombreConductorController = TextEditingController();

  String _tipoVehiculo = 'Auto';

  @override
  void dispose() {
    _placaController.dispose();
    _nombreConductorController.dispose();
    super.dispose();
  }

  void _confirmarReserva() {
    final formularioValido = _formKey.currentState?.validate() ?? false;

    if (!formularioValido) {
      return;
    }

    final reservaActual = ReservaActivaProvider.reservaActivaNotifier.value;

    if (reservaActual != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ya existe un parqueo activo. Finalízalo antes de iniciar otro.',
          ),
        ),
      );
      return;
    }

    final reserva = ReservaActivaEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      parqueo: widget.parqueo,
      tipoVehiculo: _tipoVehiculo,
      placa: _placaController.text.trim().toUpperCase(),
      nombreConductor: _nombreConductorController.text.trim(),
      horaEntrada: DateTime.now(),
    );

    ReservaActivaProvider.iniciarReserva(reserva);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reserva iniciada correctamente.')),
    );

    Navigator.pop(context);
  }

  String? _validarPlaca(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa la placa del vehículo';
    }

    if (value.trim().length < 3) {
      return 'La placa debe tener al menos 3 caracteres';
    }

    return null;
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
            'Tarifa: ${widget.parqueo.precioHora.toStringAsFixed(2)} Bs/hora',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Espacios: ${widget.parqueo.espaciosAutos} autos, ${widget.parqueo.espaciosMotos} motos',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _opcionVehiculo({required String tipo, required IconData icono}) {
    final seleccionado = _tipoVehiculo == tipo;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _tipoVehiculo = tipo;
          });
        },
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
                icono,
                color: seleccionado ? Colors.white : AppTheme.primaryGreen,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                tipo,
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de vehículo',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _opcionVehiculo(tipo: 'Auto', icono: Icons.directions_car),
              const SizedBox(width: 12),
              _opcionVehiculo(tipo: 'Moto', icono: Icons.two_wheeler),
            ],
          ),
        ],
      ),
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
            const SizedBox(height: 18),
            TextFormField(
              controller: _placaController,
              textCapitalization: TextCapitalization.characters,
              validator: _validarPlaca,
              decoration: InputDecoration(
                labelText: 'Placa del vehículo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreConductorController,
              decoration: InputDecoration(
                labelText: 'Nombre del conductor (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _confirmarReserva,
                icon: const Icon(Icons.timer),
                label: const Text('Iniciar cronómetro'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
