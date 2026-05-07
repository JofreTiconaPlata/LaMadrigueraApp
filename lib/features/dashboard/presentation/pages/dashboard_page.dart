import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const LatLng _centroMapa = LatLng(-17.3895, -66.1568);

  static const List<LatLng> _parqueosDemo = [
    LatLng(-17.3895, -66.1568),
    LatLng(-17.3920, -66.1585),
    LatLng(-17.3868, -66.1542),
  ];

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
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 520,
              width: double.infinity,
              child: Stack(
                children: [
                  FlutterMap(
                    options: const MapOptions(
                      initialCenter: _centroMapa,
                      initialZoom: 15.5,
                      minZoom: 5,
                      maxZoom: 19,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.lamadriguera.app',
                      ),

                      MarkerLayer(
                        markers: _parqueosDemo.map((punto) {
                          return Marker(
                            point: punto,
                            width: 48,
                            height: 48,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_parking,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Color(0xFF2E7D32),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Buscar parqueos cercanos',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.my_location,
                            color: Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '© OpenStreetMap',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}