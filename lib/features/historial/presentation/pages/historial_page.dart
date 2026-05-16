import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class HistorialPage extends ConsumerWidget {
  const HistorialPage({super.key});

  List<Map<String, String>> _clienteRegistros() {
    return [
      {
        'parqueo': 'Parqueo Central',
        'espacio': 'A1',
        'fecha': '15/05/2026',
        'tiempo': '45 min',
        'monto': 'Bs 10',
        'estado': 'Completada',
      },
      {
        'parqueo': 'La Madriguera Norte',
        'espacio': 'M3',
        'fecha': '14/05/2026',
        'tiempo': '1 h 20 min',
        'monto': 'Bs 12',
        'estado': 'Completada',
      },
    ];
  }

  List<Map<String, String>> _operadorRegistros() {
    return [
      {
        'placa': 'ABC-123',
        'tipo': 'Auto',
        'entrada': '08:30',
        'salida': '10:30',
        'monto': 'Bs 10',
        'responsable': 'Operador 1',
      },
      {
        'placa': 'XYZ-789',
        'tipo': 'Moto',
        'entrada': '09:15',
        'salida': '11:00',
        'monto': 'Bs 6',
        'responsable': 'Operador 2',
      },
    ];
  }

  Widget _clienteCard(Map<String, String> registro) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              registro['parqueo']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Espacio: ${registro['espacio']}'),
            Text('Fecha: ${registro['fecha']}'),
            Text('Tiempo usado: ${registro['tiempo']}'),
            Text('Monto pagado: ${registro['monto']}'),
            const SizedBox(height: 8),
            Chip(
              label: Text(registro['estado']!),
              backgroundColor: Colors.green.shade100,
              labelStyle: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _operadorCard(Map<String, String> registro) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              registro['placa']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Tipo: ${registro['tipo']}'),
            Text('Entrada: ${registro['entrada']}'),
            Text('Salida: ${registro['salida']}'),
            Text('Monto: ${registro['monto']}'),
            Text('Responsable: ${registro['responsable']}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sessionProvider);
    final esOperador = usuario?.rol == RolEnum.operador;

    final titulo = esOperador
        ? 'Historial de operaciones'
        : 'Historial de reservas';

    final subtitulo = esOperador
        ? 'Movimientos registrados durante la operación del parqueo.'
        : 'Reservas y usos realizados con tu cuenta.';

    final registrosCliente = _clienteRegistros();
    final registrosOperador = _operadorRegistros();

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(subtitulo, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          if (esOperador)
            ...registrosOperador.map(_operadorCard)
          else
            ...registrosCliente.map(_clienteCard),
        ],
      ),
    );
  }
}
