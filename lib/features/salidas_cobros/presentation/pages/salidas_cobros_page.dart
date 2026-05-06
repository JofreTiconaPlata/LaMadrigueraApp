import 'package:flutter/material.dart';

class CobroPage extends StatelessWidget {
  const CobroPage({super.key});

  @override
  Widget build(BuildContext context) {
    const horas = 2;
    const precioHora = 5;
    const total = horas * precioHora;

    return Scaffold(
      appBar: AppBar(title: const Text('Cobro')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.payments, size: 90, color: Color(0xFF2E7D32)),
            const SizedBox(height: 20),
            const Text('Resumen de pago', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Espacio'), Text('A1')]),
                    Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tiempo'), Text('2 horas')]),
                    Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Precio/hora'), Text('Bs 5')]),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Bs 10', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                child: const Text('Confirmar pago'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}