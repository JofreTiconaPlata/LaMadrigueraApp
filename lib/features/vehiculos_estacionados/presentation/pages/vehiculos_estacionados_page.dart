import 'package:flutter/material.dart';

class VehiculosEstacionadosPage extends StatelessWidget {
  const VehiculosEstacionadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vehiculos = [
      {
        'placa': '1234-ABC',
        'tipo': 'Auto',
        'espacio': 'A1',
        'horaIngreso': '08:30',
      },
      {
        'placa': '5678-DEF',
        'tipo': 'Moto',
        'espacio': 'M1',
        'horaIngreso': '09:10',
      },
      {
        'placa': '9012-GHI',
        'tipo': 'Auto',
        'espacio': 'A3',
        'horaIngreso': '10:05',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos estacionados'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vehiculos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final vehiculo = vehiculos[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(
                  Icons.directions_car,
                  color: Color(0xFF2E7D32),
                ),
              ),
              title: Text(
                vehiculo['placa']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Tipo: ${vehiculo['tipo']} • Espacio: ${vehiculo['espacio']} • Ingreso: ${vehiculo['horaIngreso']}',
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}