import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/parqueos/domain/entities/parqueo_entity.dart';
import 'package:la_madriguera/features/parqueos/presentation/providers/parqueos_provider.dart';
import 'package:la_madriguera/features/reservas/presentation/widgets/reserva_activa_card.dart';

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

  void _mostrarDetalleParqueo(
    BuildContext context,
    ParqueoEntity parqueo,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            runSpacing: 12,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_parking,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      parqueo.nombre,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                parqueo.direccion,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              Text(
                'Espacios: ${parqueo.espaciosTotales} '
                '(${parqueo.espaciosAutos} autos, ${parqueo.espaciosMotos} motos)',
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              Text(
                'Precio por hora: ${parqueo.precioHora.toStringAsFixed(2)} Bs',
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              Text(
                'Ubicación: ${parqueo.latitud.toStringAsFixed(6)}, '
                '${parqueo.longitud.toStringAsFixed(6)}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(
                      context,
                      RouteNames.crearReserva,
                      arguments: parqueo,
                    );
                  },
                  icon: const Icon(Icons.timer),
                  label: const Text('Reservar espacio'),
                ),
              ),
            ],
          ),
        );
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
                ValueListenableBuilder<List<ParqueoEntity>>(
                  valueListenable: ParqueosProvider.parqueosNotifier,
                  builder: (context, parqueos, _) {
                    return MarkerLayer(
                      markers: parqueos.map((parqueo) {
                        return Marker(
                          point: LatLng(parqueo.latitud, parqueo.longitud),
                          width: 56,
                          height: 56,
                          child: GestureDetector(
                            onTap: () => _mostrarDetalleParqueo(
                              context,
                              parqueo,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_parking,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const ReservaActivaCard(),
        ],
      ),
    );
  }
}
