import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Widget _card(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 38, color: AppTheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel administrativo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Resumen del parqueo',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _card('Espacios ocupados', '8', Icons.car_rental),
              _card('Espacios libres', '14', Icons.local_parking),
              _card('Ingresos del día', 'Bs 120', Icons.payments),
              _card('Vehículos atendidos', '24', Icons.analytics),
            ],
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/registrar-ingreso'),
            icon: const Icon(Icons.login),
            label: const Text('Registrar ingreso'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, '/vehiculos-estacionados'),
            icon: const Icon(Icons.directions_car),
            label: const Text('Vehículos estacionados'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/historial'),
            icon: const Icon(Icons.history),
            label: const Text('Historial'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/tarifas'),
            icon: const Icon(Icons.payments),
            label: const Text('Tarifas'),
          ),
        ],
      ),
    );
  }
}
