import 'package:flutter/material.dart';

class VehiculosEstacionadosPage extends StatelessWidget {
  const VehiculosEstacionadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vehiculos = [
      {'placa': 'ABC-123', 'tipo': 'Auto', 'hora': '08:30', 'espacio': 'A1'},
      {'placa': 'XYZ-789', 'tipo': 'Moto', 'hora': '09:15', 'espacio': 'M1'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Vehículos estacionados')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Vehículos actuales',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (vehiculos.isEmpty)
            const Center(child: Text('No hay vehículos estacionados.')),

          ...vehiculos.map((v) {
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.directions_car)),
                title: Text(v['placa']!),
                subtitle: Text(
                  'Tipo: ${v['tipo']} | Hora: ${v['hora']} | Espacio: ${v['espacio']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    Navigator.pushNamed(context, '/cobro');
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
