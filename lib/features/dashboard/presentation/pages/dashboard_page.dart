import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _drawerOption(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF2E7D32),
                ),
                accountName: Text('Usuario La Madriguera'),
                accountEmail: Text('usuario@gmail.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 42,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),

              _drawerOption(
                context,
                Icons.person,
                'Mi perfil',
                '/perfil',
              ),
              _drawerOption(
                context,
                Icons.login,
                'Registrar ingreso de vehículo',
                '/registrar-ingreso',
              ),
              _drawerOption(
                context,
                Icons.directions_car,
                'Vehículos estacionados',
                '/vehiculos-estacionados',
              ),
              _drawerOption(
                context,
                Icons.local_parking,
                'Disponibilidad de espacios',
                '/espacios',
              ),
              _drawerOption(
                context,
                Icons.history,
                'Historial',
                '/historial',
              ),
              _drawerOption(
                context,
                Icons.payments,
                'Tarifas',
                '/tarifas',
              ),
              _drawerOption(
                context,
                Icons.admin_panel_settings,
                'Panel administrativo',
                '/admin-dashboard',
              ),
              _drawerOption(
                context,
                Icons.add_location_alt,
                'Crear parqueo',
                '/crear-parqueo',
              ),
              _drawerOption(
                context,
                Icons.qr_code_2,
                'Código QR',
                '/qr-tiempo',
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        title: const Text('Parqueos cercanos'),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 520,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFDDEFE0),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 90, color: Color(0xFF2E7D32)),
                  SizedBox(height: 10),
                  Text(
                    'Mapa de parqueos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Aquí luego conectaremos Google Maps'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}