import 'package:flutter/material.dart';

class QrTiempoPage extends StatelessWidget {
  const QrTiempoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiempo y QR')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Reserva activa',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Espacio seleccionado: A1'),
            const SizedBox(height: 24),

            Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: const Icon(Icons.qr_code_2, size: 170),
            ),

            const SizedBox(height: 24),
            const Text('Tiempo transcurrido', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text(
              '00:45:00',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/cobro'),
                child: const Text('Finalizar y cobrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
