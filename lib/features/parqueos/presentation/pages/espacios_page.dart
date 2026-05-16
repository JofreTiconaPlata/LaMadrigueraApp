import 'package:flutter/material.dart';

class EspaciosPage extends StatelessWidget {
  const EspaciosPage({super.key});

  Widget _spaceButton(BuildContext context, int number, bool ocupado) {
    return InkWell(
      onTap: ocupado ? null : () => Navigator.pushNamed(context, '/qr-tiempo'),
      child: Container(
        decoration: BoxDecoration(
          color: ocupado ? Colors.red.shade100 : Colors.green.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ocupado ? Colors.red : Colors.green),
        ),
        child: Center(
          child: Text(
            'A$number',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ocupado ? Colors.red : Colors.green.shade800,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ocupados = {2, 5, 9};

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar espacio')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Espacios para autos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final number = index + 1;
                  return _spaceButton(
                    context,
                    number,
                    ocupados.contains(number),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
