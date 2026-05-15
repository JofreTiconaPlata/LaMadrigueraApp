import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

<<<<<<< HEAD
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/parqueos/domain/entities/parqueo_entity.dart';
import 'package:la_madriguera/features/parqueos/presentation/providers/parqueos_provider.dart';
=======
import '../../../parqueos/domain/entities/parqueo_model.dart';
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final LatLng _centroMapa = LatLng(-17.3895, -66.1568);
<<<<<<< HEAD
=======

  static final List<ParqueoModel> _parqueos = [
    ParqueoModel(
      id: 1,
      nombre: 'Parqueo Centro Cochabamba',
      direccion: 'Plaza 14 de Septiembre, Cochabamba',
      latitud: -17.3935,
      longitud: -66.1570,
      espaciosDisponibles: 8,
      horario: '08:00 - 22:00',
      tarifaReferencia: 5,
    ),
    ParqueoModel(
      id: 2,
      nombre: 'Parqueo El Prado',
      direccion: 'Av. Ballivián, Cochabamba',
      latitud: -17.3848,
      longitud: -66.1580,
      espaciosDisponibles: 3,
      horario: '07:00 - 21:00',
      tarifaReferencia: 4,
    ),
    ParqueoModel(
      id: 3,
      nombre: 'Parqueo Cala Cala',
      direccion: 'Zona Cala Cala, Cochabamba',
      latitud: -17.3718,
      longitud: -66.1625,
      espaciosDisponibles: 0,
      horario: '24 horas',
      tarifaReferencia: 6,
    ),
  ];
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)

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
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

<<<<<<< HEAD
  void _mostrarDetalleParqueo(BuildContext context, ParqueoEntity parqueo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
=======
  void _mostrarDetalleParqueo(BuildContext context, ParqueoModel parqueo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            runSpacing: 12,
            children: [
<<<<<<< HEAD
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.local_parking, color: Colors.white),
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
=======
              Text(
                parqueo.nombre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _detalleItem(Icons.location_on, 'Dirección', parqueo.direccion),
              _detalleItem(Icons.access_time, 'Horario', parqueo.horario),
              _detalleItem(
                Icons.local_parking,
                'Disponibles',
                '${parqueo.espaciosDisponibles} espacios',
              ),
              _detalleItem(
                Icons.payments,
                'Tarifa referencial',
                'Bs ${parqueo.tarifaReferencia.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
<<<<<<< HEAD
                    Navigator.pushNamed(context, RouteNames.espacios);
=======
                    Navigator.pushNamed(context, '/espacios');
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)
                  },
                  icon: const Icon(Icons.local_parking),
                  label: const Text('Ver espacios disponibles'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

<<<<<<< HEAD
  Widget _mapaParqueos() {
    return Container(
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
              if (parqueos.isEmpty) {
                return MarkerLayer(
                  markers: [
                    Marker(
                      point: _centroMapa,
                      width: 56,
                      height: 56,
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
                          Icons.location_on,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return MarkerLayer(
                markers: parqueos.map((parqueo) {
                  return Marker(
                    point: LatLng(parqueo.latitud, parqueo.longitud),
                    width: 56,
                    height: 56,
                    child: GestureDetector(
                      onTap: () => _mostrarDetalleParqueo(context, parqueo),
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
    );
  }

=======
  Widget _detalleItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Color _colorMarcador(int disponibles) {
    if (disponibles == 0) return Colors.red;
    if (disponibles <= 3) return Colors.orange;
    return Colors.green;
  }

>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)
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
                decoration: BoxDecoration(color: AppTheme.primaryGreen),
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
<<<<<<< HEAD
              _drawerOption(
                context,
                Icons.person,
                'Mi perfil',
                RouteNames.perfil,
              ),
=======
              _drawerOption(context, Icons.person, 'Mi perfil', '/perfil'),
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)
              _drawerOption(
                context,
                Icons.login,
                'Registrar ingreso de vehículo',
<<<<<<< HEAD
                RouteNames.registrarIngreso,
=======
                '/registrar-ingreso',
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)
              ),
              _drawerOption(
                context,
                Icons.directions_car,
                'Vehículos estacionados',
<<<<<<< HEAD
                RouteNames.vehiculosEstacionados,
=======
                '/vehiculos-estacionados',
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)
              ),
              _drawerOption(
                context,
                Icons.local_parking,
                'Disponibilidad de espacios',
<<<<<<< HEAD
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
=======
                '/espacios',
              ),
              _drawerOption(context, Icons.history, 'Historial', '/historial'),
              _drawerOption(context, Icons.payments, 'Tarifas', '/tarifas'),
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)
              _drawerOption(
                context,
                Icons.admin_panel_settings,
                'Panel administrativo',
<<<<<<< HEAD
                RouteNames.adminDashboard,
=======
                '/admin-dashboard',
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)
              ),
              _drawerOption(
                context,
                Icons.add_location_alt,
                'Crear parqueo',
<<<<<<< HEAD
                RouteNames.crearParqueo,
              ),
              _drawerOption(
                context,
                Icons.qr_code_2,
                'Código QR',
                RouteNames.qrTiempo,
              ),
              const Divider(height: 24),
=======
                '/crear-parqueo',
              ),
              _drawerOption(context, Icons.qr_code_2, 'Código QR', '/qr-tiempo'),
              const Divider(),
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)
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
<<<<<<< HEAD
          _mapaParqueos(),
=======
          Container(
            height: 520,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
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
                  markers: _parqueos.map((parqueo) {
                    return Marker(
                      point: LatLng(parqueo.latitud, parqueo.longitud),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _mostrarDetalleParqueo(context, parqueo),
                        child: Icon(
                          Icons.location_on,
                          color: _colorMarcador(parqueo.espaciosDisponibles),
                          size: 45,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Parqueos disponibles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ..._parqueos.map((parqueo) {
            return Card(
              child: ListTile(
                leading: Icon(
                  Icons.local_parking,
                  color: _colorMarcador(parqueo.espaciosDisponibles),
                ),
                title: Text(parqueo.nombre),
                subtitle: Text(
                  '${parqueo.direccion}\nDisponibles: ${parqueo.espaciosDisponibles} | Tarifa: Bs ${parqueo.tarifaReferencia.toStringAsFixed(2)}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _mostrarDetalleParqueo(context, parqueo),
              ),
            );
          }),
>>>>>>> 9ff8c80 (feat: agregar servicio y modelo de parqueos)
        ],
      ),
    );
  }
}