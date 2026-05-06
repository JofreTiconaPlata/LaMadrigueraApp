import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _menuButton(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2E7D32),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _parkingCard(
    BuildContext context,
    String title,
    String address,
    String price,
  ) {
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
                leading: const Icon(Icons.login),
                title: const Text('Registrar ingreso'),
                onTap: () => Navigator.pushNamed(context, '/registrar-ingreso'),
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Vehículos estacionados'),
                onTap: () => Navigator.pushNamed(context, '/vehiculos-estacionados'),
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Panel administrativo'),
                onTap: () => Navigator.pushNamed(context, '/admin-dashboard'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 230,
            width: double.infinity,
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
                  Text(
                    'Mapa de parqueos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('Aquí luego puedes conectar Google Maps'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Acciones rápidas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _menuButton(
            context,
            'Registrar ingreso de vehículo',
            Icons.login,
            '/registrar-ingreso',
          ),
          _menuButton(
            context,
            'Vehículos estacionados',
            Icons.directions_car,
            '/vehiculos-estacionados',
          ),
          _menuButton(
            context,
            'Disponibilidad de espacios',
            Icons.local_parking,
            '/espacios',
          ),
          _menuButton(
            context,
            'Historial',
            Icons.history,
            '/historial',
          ),
          _menuButton(
            context,
            'Tarifas',
            Icons.payments,
            '/tarifas',
          ),
          _menuButton(
            context,
            'Panel administrativo',
            Icons.admin_panel_settings,
            '/admin-dashboard',
          ),
          _menuButton(
            context,
            'Crear parqueo',
            Icons.add_location_alt,
            '/crear-parqueo',
          ),
          _menuButton(
            context,
            'Código QR',
            Icons.qr_code_2,
            '/qr-tiempo',
          ),

          const SizedBox(height: 20),

          const Text(
            'Parqueos disponibles',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _parkingCard(context, 'Parqueo Central', 'Av. América #123', 'Bs 5/h'),
          _parkingCard(context, 'Parqueo Norte', 'Zona Queru Queru', 'Bs 4/h'),
          _parkingCard(context, 'Parqueo Seguro', 'Cerca del centro', 'Bs 6/h'),
        ],
      ),
    );
  }
}