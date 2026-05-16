import 'package:flutter/material.dart';

class DetalleParqueoPage extends StatelessWidget {
  const DetalleParqueoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del parqueo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFFDDEFE0),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.local_parking,
              size: 100,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Parqueo Central',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Av. América #123, Cochabamba'),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(Icons.directions_car),
              SizedBox(width: 8),
              Text('Espacios disponibles para autos: 12'),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.two_wheeler),
              SizedBox(width: 8),
              Text('Espacios disponibles para motos: 8'),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.payments),
              SizedBox(width: 8),
              Text('Precio: Bs 5 por hora'),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/espacios'),
              child: const Text('Seleccionar espacio'),
            ),
          ),
        ],
      ),
    );
  }
}
