import 'package:flutter/material.dart';

class TarifasPage extends StatelessWidget {
  const TarifasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tarifas = [
      {'tipo': 'Auto', 'valor': 'Bs 5', 'unidad': 'Hora', 'estado': 'Activa'},
      {'tipo': 'Moto', 'valor': 'Bs 3', 'unidad': 'Hora', 'estado': 'Activa'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tarifas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Formulario de nueva tarifa próximamente'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Gestión de tarifas',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...tarifas.map((t) {
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                leading: const Icon(Icons.payments),
                title: Text('${t['tipo']} - ${t['valor']}'),
                subtitle: Text(
                  'Unidad: ${t['unidad']} | Estado: ${t['estado']}',
                ),
                trailing: const Icon(Icons.edit),
              ),
            );
          }),
        ],
      ),
    );
  }
}
