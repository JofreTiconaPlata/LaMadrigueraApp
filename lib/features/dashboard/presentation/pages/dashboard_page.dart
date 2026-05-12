import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final LatLng _centroMapa = LatLng(-17.7833, -63.1821);

  Widget _drawerOption(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                ),
                accountName: Text(
                  'Usuario La Madriguera',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  'usuario@gmail.com',
                  style: TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 42,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
              _drawerOption(
                context,
                Icons.person,
                'Mi perfil',
                RouteNames.perfil,
              ),
              _drawerOption(
                context,
                Icons.login,
                'Registrar ingreso de vehículo',
                RouteNames.registrarIngreso,
              ),
              _drawerOption(
                context,
                Icons.directions_car,
                'Vehículos estacionados',
                RouteNames.vehiculosEstacionados,
              ),
              _drawerOption(
                context,
                Icons.local_parking,
                'Disponibilidad de espacios',
                RouteNames.espacios,
              ),
              _drawerOption(
                context,
                Icons.history,
                'Historial',
                RouteNames.historial,
              ),
              _drawerOption(
                context,
                Icons.payments,
                'Tarifas',
                RouteNames.tarifas,
              ),
              _drawerOption(
                context,
                Icons.point_of_sale,
                'Cobro y salida',
                RouteNames.salidasCobros,
              ),
              _drawerOption(
                context,
                Icons.admin_panel_settings,
                'Panel administrativo',
                RouteNames.adminDashboard,
              ),
              _drawerOption(
                context,
                Icons.add_location_alt,
                'Crear parqueo',
                RouteNames.crearParqueo,
              ),
              _drawerOption(
                context,
                Icons.qr_code_2,
                'Código QR',
                RouteNames.qrTiempo,
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, RouteNames.login);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'Parqueos cercanos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFB7D6B9)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _centroMapa,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.programovil.lamadriguera',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _centroMapa,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}