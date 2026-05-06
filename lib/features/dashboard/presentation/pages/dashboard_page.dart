import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _parkingCard(BuildContext context, String title, String address, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2E7D32),
          child: Icon(Icons.local_parking, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(address),
        trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () => Navigator.pushNamed(context, '/detalle-parqueo'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.local_parking),
                title: Text('La Madriguera'),
                subtitle: Text('Menú principal'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Perfil'),
                onTap: () => Navigator.pushNamed(context, '/perfil'),
              ),
              ListTile(
                leading: const Icon(Icons.add_location_alt),
                title: const Text('Crear parqueo'),
                onTap: () => Navigator.pushNamed(context, '/crear-parqueo'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Parqueos cercanos'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/perfil'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 230,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDDEFE0),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 80, color: Color(0xFF2E7D32)),
                  SizedBox(height: 8),
                  Text('Mapa de parqueos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Aquí luego puedes conectar Google Maps'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _parkingCard(context, 'Parqueo Central', 'Av. América #123', 'Bs 5/h'),
                _parkingCard(context, 'Parqueo Norte', 'Zona Queru Queru', 'Bs 4/h'),
                _parkingCard(context, 'Parqueo Seguro', 'Cerca del centro', 'Bs 6/h'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}