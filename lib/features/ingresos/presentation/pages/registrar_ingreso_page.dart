import 'package:flutter/material.dart';

class RegistrarIngresoPage extends StatefulWidget {
  const RegistrarIngresoPage({super.key});

  @override
  State<RegistrarIngresoPage> createState() => _RegistrarIngresoPageState();
}

class _RegistrarIngresoPageState extends State<RegistrarIngresoPage> {
  final TextEditingController placaController = TextEditingController();
  final TextEditingController horaController =
      TextEditingController(text: 'Ahora');

  String tipoVehiculo = 'Auto';
  String espacioAsignado = 'A1';

  void registrarIngreso() {
    if (placaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese la placa del vehículo')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ingreso registrado correctamente')),
    );

    Navigator.pushNamed(context, '/vehiculos-estacionados');
  }

  @override
  void dispose() {
    placaController.dispose();
    horaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar ingreso'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Ingreso de vehículo',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Registra la entrada del vehículo y asigna un espacio disponible.',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: placaController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Placa del vehículo',
              prefixIcon: const Icon(Icons.directions_car),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: tipoVehiculo,
            decoration: InputDecoration(
              labelText: 'Tipo de vehículo',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Auto', child: Text('Auto')),
              DropdownMenuItem(value: 'Moto', child: Text('Moto')),
            ],
            onChanged: (value) {
              setState(() {
                tipoVehiculo = value ?? 'Auto';
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: horaController,
            decoration: InputDecoration(
              labelText: 'Hora de ingreso',
              prefixIcon: const Icon(Icons.access_time),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: espacioAsignado,
            decoration: InputDecoration(
              labelText: 'Espacio asignado',
              prefixIcon: const Icon(Icons.local_parking),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'A1', child: Text('A1 - Disponible')),
              DropdownMenuItem(value: 'A3', child: Text('A3 - Disponible')),
              DropdownMenuItem(value: 'M1', child: Text('M1 - Disponible')),
            ],
            onChanged: (value) {
              setState(() {
                espacioAsignado = value ?? 'A1';
              });
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: registrarIngreso,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Registrar ingreso'),
            ),
          ),
        ],
      ),
    );
  }
}