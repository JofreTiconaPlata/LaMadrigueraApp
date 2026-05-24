import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/core/storage/local_storage_service.dart';
import 'package:la_madriguera/features/dashboard/presentation/config/map_city_presets.dart';
import 'package:la_madriguera/features/parqueos/data/datasources/parqueos_remote_datasource.dart';
import 'package:la_madriguera/features/parqueos/data/models/parqueo_dto.dart';
import 'package:la_madriguera/features/parqueos/domain/entities/parqueo_entity.dart';
import 'package:la_madriguera/features/reservas/presentation/widgets/reserva_activa_card.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

final parqueosDashboardProvider = FutureProvider<List<ParqueoDto>>((ref) async {
  final dataSource = ParqueosRemoteDataSource();

  return dataSource.getParqueos();
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedBottomIndex = 0;

  static final LatLng _centroMapa = MapCityPresets.defaultCity.center;
  static final double _zoomMapa = MapCityPresets.defaultCity.zoom;

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
                    Navigator.pushNamed(
                      context,
                      RouteNames.crearReserva,
                      arguments: parqueo.toEntity(),
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

  List<_DashboardBottomItem> _bottomItemsByRole(RolEnum? rol) {
    if (rol == RolEnum.operador) {
      return const [
        _DashboardBottomItem(icon: Icons.dashboard_rounded, label: 'Panel'),
        _DashboardBottomItem(
          icon: Icons.login_rounded,
          label: 'Ingresos',
          route: RouteNames.registrarIngreso,
        ),
        _DashboardBottomItem(
          icon: Icons.qr_code_scanner_rounded,
          label: 'QR',
          route: RouteNames.qrTiempo,
        ),
        _DashboardBottomItem(
          icon: Icons.point_of_sale_rounded,
          label: 'Cobros',
          route: RouteNames.salidasCobros,
        ),
      ];
    }

    return const [
      _DashboardBottomItem(icon: Icons.explore_rounded, label: 'Explorar'),
      _DashboardBottomItem(
        icon: Icons.local_parking_rounded,
        label: 'Espacios',
        route: RouteNames.espacios,
      ),
      _DashboardBottomItem(
        icon: Icons.history_rounded,
        label: 'Historial',
        route: RouteNames.historial,
      ),
      _DashboardBottomItem(
        icon: Icons.person_rounded,
        label: 'Perfil',
        route: RouteNames.perfil,
      ),
    ];
  }

  void _onBottomItemTap(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
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
  Widget build(BuildContext context) {
    final usuario = ref.watch(sessionProvider);
    final bottomItems = _bottomItemsByRole(usuario?.rol);

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
      bottomNavigationBar: _DashboardBottomNavigation(
        selectedIndex: _selectedBottomIndex,
        items: bottomItems,
        onItemTap: _onBottomItemTap,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                    initialZoom: _zoomMapa,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.programovil.lamadriguera',
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final parqueosAsync = ref.watch(
                          parqueosDashboardProvider,
                        );

                        return parqueosAsync.when(
                          loading: () => const MarkerLayer(markers: []),
                          error: (_, _) => const MarkerLayer(markers: []),
                          data: (parqueos) {
                            return MarkerLayer(
                              markers: parqueos.map((parqueo) {
                                return Marker(
                                  point: LatLng(
                                    parqueo.latitud,
                                    parqueo.longitud,
                                  ),
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
          _DashboardOverlayPanel(
            item: bottomItems[_selectedBottomIndex],
            visible: _selectedBottomIndex != 0,
            onClose: () {
              setState(() {
                _selectedBottomIndex = 0;
              });
            },
            onOpenRoute: (route) => Navigator.pushNamed(context, route),
          ),
        ],
      ),
    );
  }
}

class _DashboardBottomItem {
  const _DashboardBottomItem({
    required this.icon,
    required this.label,
    this.route,
  });

  final IconData icon;
  final String label;
  final String? route;
}

class _DashboardBottomNavigation extends StatelessWidget {
  const _DashboardBottomNavigation({
    required this.selectedIndex,
    required this.items,
    required this.onItemTap,
  });

  final int selectedIndex;
  final List<_DashboardBottomItem> items;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 16, end: 0),
        builder: (context, offset, child) {
          return Transform.translate(offset: Offset(0, offset), child: child);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == selectedIndex;

                return Expanded(
                  child: _DashboardBottomNavigationItem(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => onItemTap(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardBottomNavigationItem extends StatelessWidget {
  const _DashboardBottomNavigationItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _DashboardBottomItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                scale: isSelected ? 1.06 : 1,
                child: Icon(
                  item.icon,
                  color: isSelected ? AppTheme.primaryGreen : Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryGreen : Colors.white,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardOverlayPanel extends StatelessWidget {
  const _DashboardOverlayPanel({
    required this.item,
    required this.visible,
    required this.onClose,
    required this.onOpenRoute,
  });

  final _DashboardBottomItem item;
  final bool visible;
  final VoidCallback onClose;
  final ValueChanged<String> onOpenRoute;

  String get _title {
    switch (item.label) {
      case 'Reservas':
        return 'Mis reservas';
      case 'QR':
        return 'Acceso QR';
      case 'Perfil':
        return 'Mi perfil';
      case 'Ingresos':
        return 'Registrar ingreso';
      case 'Cobros':
        return 'Cobro y salida';
      default:
        return item.label;
    }
  }

  String get _description {
    switch (item.label) {
      case 'Reservas':
        return 'Consulta tu reserva activa, revisa el parqueo seleccionado y continúa el flujo sin salir del mapa.';
      case 'QR':
        return 'Gestiona códigos QR para validar tiempo, acceso o control de parqueo de forma rápida.';
      case 'Perfil':
        return 'Revisa los datos principales de tu cuenta y accede a la configuración del usuario.';
      case 'Ingresos':
        return 'Registra el ingreso de vehículos al parqueo y mantén actualizado el control operativo.';
      case 'Cobros':
        return 'Gestiona salidas, calcula cobros y finaliza estacionamientos activos.';
      default:
        return 'Acceso rápido desde el panel principal de La Madriguera.';
    }
  }

  List<_OverlayInfoItem> get _infoItems {
    switch (item.label) {
      case 'Reservas':
        return const [
          _OverlayInfoItem(
            icon: Icons.confirmation_number_rounded,
            title: 'Reserva activa',
            subtitle:
                'Muestra el parqueo, placa y hora de entrada si existe una reserva en curso.',
          ),
          _OverlayInfoItem(
            icon: Icons.map_rounded,
            title: 'Contexto del mapa',
            subtitle:
                'El mapa permanece visible para no perder la ubicación del parqueo.',
          ),
        ];
      case 'QR':
        return const [
          _OverlayInfoItem(
            icon: Icons.qr_code_2_rounded,
            title: 'Validación rápida',
            subtitle:
                'Accede al módulo QR para consultar o validar tickets de parqueo.',
          ),
          _OverlayInfoItem(
            icon: Icons.security_rounded,
            title: 'Control seguro',
            subtitle:
                'Ideal para flujos donde se necesita comprobar tiempo o acceso.',
          ),
        ];
      case 'Perfil':
        return const [
          _OverlayInfoItem(
            icon: Icons.person_rounded,
            title: 'Cuenta del usuario',
            subtitle:
                'Accede a tus datos personales y preferencias principales.',
          ),
          _OverlayInfoItem(
            icon: Icons.logout_rounded,
            title: 'Sesión',
            subtitle:
                'Desde el perfil puedes revisar tu cuenta o cerrar sesión.',
          ),
        ];
      case 'Ingresos':
        return const [
          _OverlayInfoItem(
            icon: Icons.login_rounded,
            title: 'Nuevo ingreso',
            subtitle:
                'Registra placa, tipo de vehículo y datos necesarios para iniciar el estacionamiento.',
          ),
          _OverlayInfoItem(
            icon: Icons.directions_car_rounded,
            title: 'Vehículos activos',
            subtitle:
                'Mantén control de los vehículos actualmente estacionados.',
          ),
        ];
      case 'Cobros':
        return const [
          _OverlayInfoItem(
            icon: Icons.point_of_sale_rounded,
            title: 'Finalizar salida',
            subtitle:
                'Calcula el cobro y registra la salida del vehículo estacionado.',
          ),
          _OverlayInfoItem(
            icon: Icons.receipt_long_rounded,
            title: 'Control operativo',
            subtitle: 'Apoya el cierre correcto de ingresos activos y pagos.',
          ),
        ];
      default:
        return const [
          _OverlayInfoItem(
            icon: Icons.info_rounded,
            title: 'Acceso rápido',
            subtitle: 'Selecciona una acción para continuar.',
          ),
        ];
    }
  }

  String get _primaryActionLabel {
    switch (item.label) {
      case 'QR':
        return 'Abrir módulo QR';
      case 'Perfil':
        return 'Ver perfil';
      case 'Ingresos':
        return 'Registrar ingreso';
      case 'Cobros':
        return 'Ir a cobros';
      default:
        return 'Abrir ${item.label}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        opacity: visible ? 1 : 0,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: visible ? 7 : 0,
                  sigmaY: visible ? 7 : 0,
                ),
                child: Container(color: Colors.black.withValues(alpha: 0.10)),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                offset: visible ? Offset.zero : const Offset(0, 0.08),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 280,
                    maxHeight: 420,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFB7D6B9)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6E5D8),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(item.icon, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _title,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _description,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: onClose,
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._infoItems.map(
                            (info) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _OverlayInfoTile(info: info),
                            ),
                          ),
                          if (item.label == 'Reservas') ...[
                            const SizedBox(height: 4),
                            const ReservaActivaCard(),
                          ],
                          if (item.route != null) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => onOpenRoute(item.route!),
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: Text(_primaryActionLabel),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayInfoItem {
  const _OverlayInfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _OverlayInfoTile extends StatelessWidget {
  const _OverlayInfoTile({required this.info});

  final _OverlayInfoItem info;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0EEE2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(info.icon, color: AppTheme.primaryGreen, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    info.subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension ParqueoDtoMapper on ParqueoDto {
  ParqueoEntity toEntity() {
    return ParqueoEntity(
      id: id.toString(),
      nombre: nombre,
      direccion: direccion,
      espaciosAutos: espaciosAutos,
      espaciosMotos: espaciosMotos,
      precioHora: 0,
      latitud: latitud,
      longitud: longitud,
    );
  }
}
