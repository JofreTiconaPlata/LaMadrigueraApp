import 'package:flutter/material.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  Widget _option(IconData icon, String title, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFF2E7D32),
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 12),
            const Text('Usuario La Madriguera', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('usuario@gmail.com'),
            const SizedBox(height: 24),

            _option(Icons.add_location_alt, 'Registrar parqueo', () {
              Navigator.pushNamed(context, '/crear-parqueo');
            }),
            _option(Icons.history, 'Historial de reservas', () {}),
            _option(Icons.settings, 'Configuración', () {}),
            _option(Icons.logout, 'Cerrar sesión', () {
              Navigator.pushReplacementNamed(context, '/login');
            }),
          ],
        ),
      ),
    );
  }
}