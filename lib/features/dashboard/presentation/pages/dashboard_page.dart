import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/core/storage/local_storage_service.dart';
import 'package:la_madriguera/features/parqueos/data/datasources/parqueos_remote_datasource.dart';
import 'package:la_madriguera/features/parqueos/data/models/parqueo_dto.dart';
import 'package:la_madriguera/features/reservas/presentation/widgets/reserva_activa_card.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

final parqueosDashboardProvider = FutureProvider<List<ParqueoDto>>((ref) async {
  final dataSource = ParqueosRemoteDataSource();

  return dataSource.getParqueos();
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static final LatLng _centroMapa = LatLng(-17.3935, -66.1570);

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

  List<Widget> _drawerOptionsByRole(BuildContext context, RolEnum? rol) {
    final commonOptions = <Widget>[
      _drawerOption(context, Icons.person, 'Mi perfil', RouteNames.perfil),
      _drawerOption(
        context,
        Icons.local_parking,
        'Disponibilidad de espacios',
        RouteNames.espacios,
      ),
      _drawerOption(context, Icons.history, 'Historial', RouteNames.historial),
    ];

    if (rol == RolEnum.operador) {
      return [
        _drawerOption(context, Icons.person, 'Mi perfil', RouteNames.perfil),
        _drawerOption(
          context,
          Icons.add_location_alt,
          'Crear parqueo',
          RouteNames.crearParqueo,
        ),
        _drawerOption(
          context,
          Icons.local_parking,
          'Disponibilidad de espacios',
          RouteNames.espacios,
        ),
        _drawerOption(
          context,
          Icons.login,
          'Registrar ingreso de vehículo',
          RouteNames.registrarIngreso,
        ),
        _drawerOption(
          context,
          Icons.qr_code_scanner,
          'Validar QR',
          RouteNames.qrTiempo,
        ),
        _drawerOption(
          context,
          Icons.directions_car,
          'Vehículos estacionados',
          RouteNames.vehiculosEstacionados,
        ),
        _drawerOption(
          context,
          Icons.add_location_alt,
          'Crear parqueo',
          RouteNames.crearParqueo,
        ),
        _drawerOption(context, Icons.payments, 'Tarifas', RouteNames.tarifas),
        _drawerOption(
          context,
          Icons.point_of_sale,
          'Cobro y salida',
          RouteNames.salidasCobros,
        ),
        _drawerOption(context, Icons.payments, 'Tarifas', RouteNames.tarifas),
        _drawerOption(
          context,
          Icons.history,
          'Historial de operaciones',
          RouteNames.historial,
        ),
      ];
    }
    if (rol == RolEnum.administrador) {
      return [
        ...commonOptions,
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
        _drawerOption(context, Icons.payments, 'Tarifas', RouteNames.tarifas),
      ];
    }

    return [
      ...commonOptions,
      _drawerOption(context, Icons.qr_code_2, 'Código QR', RouteNames.qrTiempo),
    ];
  }

  String _homeTitleByRole(RolEnum? rol) {
    switch (rol) {
      case RolEnum.operador:
        return 'Panel operador';
      case RolEnum.administrador:
        return 'Panel administrador';
      case RolEnum.cliente:
      case null:
        return 'Parqueos cercanos';
    }
  }

  void _mostrarDetalleParqueo(BuildContext context, ParqueoDto parqueo) {
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
                'Espacios: ${parqueo.capacidadTotal} '
                '(${parqueo.espaciosAutos} autos, ${parqueo.espaciosMotos} motos)',
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              Text(
                'Estado: ${parqueo.estado}',
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
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(context, RouteNames.espacios);
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Ver espacios'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(context, RouteNames.crearReserva);
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

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    ref.read(sessionProvider.notifier).state = null;
    await LocalStorageService.clearToken();

    if (!context.mounted) {
      return;
    }

    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primaryGreen),
                accountName: Text(
                  usuario?.nombre ?? 'Usuario La Madriguera',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  usuario?.correo ?? 'usuario@gmail.com',
                  style: const TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 42,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
              ..._drawerOptionsByRole(context, usuario?.rol),
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
                  _logout(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          _homeTitleByRole(usuario?.rol),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
              options: MapOptions(initialCenter: _centroMapa, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.programovil.lamadriguera',
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final parqueosAsync = ref.watch(parqueosDashboardProvider);

                    return parqueosAsync.when(
                      loading: () => const MarkerLayer(markers: []),
                      error: (_, _) => const MarkerLayer(markers: []),
                      data: (parqueos) {
                        return MarkerLayer(
                          markers: parqueos.map((parqueo) {
                            return Marker(
                              point: LatLng(parqueo.latitud, parqueo.longitud),
                              width: 56,
                              height: 56,
                              child: GestureDetector(
                                onTap: () =>
                                    _mostrarDetalleParqueo(context, parqueo),
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
