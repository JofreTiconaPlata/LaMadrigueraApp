import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:la_madriguera/features/auth/presentation/pages/login_page.dart';
import 'package:la_madriguera/features/auth/presentation/pages/register_page.dart';
import 'package:la_madriguera/features/auth/presentation/pages/role_redirect_page.dart';
import 'package:la_madriguera/features/dashboard/presentation/pages/admin_home_page.dart';
import 'package:la_madriguera/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:la_madriguera/features/espacios/presentation/pages/espacios_page.dart';
import 'package:la_madriguera/features/historial/presentation/pages/historial_page.dart';
import 'package:la_madriguera/features/ingresos/presentation/pages/registrar_ingreso_page.dart';
import 'package:la_madriguera/features/parqueos/domain/entities/parqueo_entity.dart';
import 'package:la_madriguera/features/parqueos/presentation/pages/crear_parqueo_page.dart';
import 'package:la_madriguera/features/parqueos/presentation/pages/mis_parqueos_page.dart';
import 'package:la_madriguera/features/perfil/presentation/pages/perfil_page.dart';
import 'package:la_madriguera/features/qr/presentation/pages/qr_tiempo_page.dart';
import 'package:la_madriguera/features/reservas/presentation/pages/crear_reserva_page.dart';
import 'package:la_madriguera/features/reservas/presentation/pages/mis_reservas_page.dart';
import 'package:la_madriguera/features/salidas_cobros/presentation/pages/salidas_cobros_page.dart';
import 'package:la_madriguera/features/tarifas/presentation/pages/tarifas_page.dart';
import 'package:la_madriguera/features/vehiculos/presentation/pages/vehiculos_page.dart';
import 'package:la_madriguera/features/vehiculos_estacionados/presentation/pages/vehiculos_estacionados_page.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class AppRouter {
  static const String login = RouteNames.login;
  static const String register = RouteNames.register;
  static const String redirect = RouteNames.redirect;
  static const String clienteHome = RouteNames.clienteHome;
  static const String operadorHome = RouteNames.operadorHome;
  static const String adminHome = RouteNames.adminHome;

  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const _LoginSessionGate());

      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case RouteNames.redirect:
        return MaterialPageRoute(builder: (_) => const RoleRedirectPage());

      case RouteNames.clienteHome:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: HomePage()),
        );

      case RouteNames.operadorHome:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: HomePage()),
        );

      case RouteNames.adminHome:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: AdminHomePage()),
        );

      case RouteNames.perfil:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: PerfilPage()),
        );

      case RouteNames.registrarIngreso:
        return MaterialPageRoute(
          builder: (_) =>
              const _SessionRequiredPage(child: RegistrarIngresoPage()),
        );

      case RouteNames.vehiculos:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: VehiculosPage()),
        );

      case RouteNames.vehiculosEstacionados:
        return MaterialPageRoute(
          builder: (_) =>
              const _SessionRequiredPage(child: VehiculosEstacionadosPage()),
        );

      case RouteNames.espacios:
        final parqueoId = (settings.arguments ?? 1) as int;
        return MaterialPageRoute(
          builder: (_) =>
              _SessionRequiredPage(child: EspaciosPage(parqueoId: parqueoId)),
        );

      case RouteNames.historial:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: HistorialPage()),
        );

      case RouteNames.tarifas:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: TarifasPage()),
        );

      case RouteNames.adminDashboard:
        return MaterialPageRoute(
          builder: (_) =>
              const _SessionRequiredPage(child: AdminDashboardPage()),
        );

      case RouteNames.crearParqueo:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: CrearParqueoPage()),
        );

      case RouteNames.misParqueos:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: MisParqueosPage()),
        );

      case RouteNames.crearReserva:
        final args = settings.arguments;

        if (args is ParqueoEntity) {
          return MaterialPageRoute(
            builder: (_) =>
                _SessionRequiredPage(child: CrearReservaPage(parqueo: args)),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('No se recibió el parqueo para reservar.'),
            ),
          ),
        );

      case RouteNames.misReservas:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: MisReservasPage()),
        );

      case RouteNames.qrTiempo:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: QrTiempoPage()),
        );

      case RouteNames.salidasCobros:
        return MaterialPageRoute(
          builder: (_) => const _SessionRequiredPage(child: CobroPage()),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}

class _LoginSessionGate extends ConsumerWidget {
  const _LoginSessionGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionInitializerProvider);

    return sessionAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const LoginPage(),
      data: (usuario) {
        if (usuario == null) {
          return const LoginPage();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }

          final route = _homeRouteByRole(usuario.rol);
          Navigator.pushReplacementNamed(context, route);
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _SessionRequiredPage extends ConsumerWidget {
  const _SessionRequiredPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioActual = ref.watch(sessionProvider);

    if (usuarioActual != null) {
      return child;
    }

    final sessionAsync = ref.watch(sessionInitializerProvider);

    return sessionAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const LoginPage(),
      data: (usuario) {
        if (usuario == null) {
          return const LoginPage();
        }

        return child;
      },
    );
  }
}

String _homeRouteByRole(RolEnum rol) {
  switch (rol) {
    case RolEnum.cliente:
      return RouteNames.clienteHome;
    case RolEnum.operador:
      return RouteNames.operadorHome;
    case RolEnum.administrador:
      return RouteNames.adminHome;
  }
}
