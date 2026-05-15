import 'package:flutter/material.dart';

class HistorialPage extends StatelessWidget {
  const HistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final registros = [
      {
        'placa': 'ABC-123',
        'tipo': 'Auto',
        'entrada': '08:30',
        'salida': '10:30',
        'monto': 'Bs 10',
        'usuario': 'Operador 1',
      },
      {
        'placa': 'XYZ-789',
        'tipo': 'Moto',
        'entrada': '09:15',
        'salida': '11:00',
        'monto': 'Bs 6',
        'usuario': 'Operador 2',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Historial de operaciones',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...registros.map((r) {
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['placa']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Tipo: ${r['tipo']}'),
                    Text('Entrada: ${r['entrada']}'),
                    Text('Salida: ${r['salida']}'),
                    Text('Monto: ${r['monto']}'),
                    Text('Responsable: ${r['usuario']}'),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
