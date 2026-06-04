import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/features/auth/presentation/pages/login_page.dart';
import 'package:la_madriguera/features/auth/presentation/pages/register_page.dart';
import 'package:la_madriguera/features/auth/presentation/pages/role_redirect_page.dart';
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
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.cliente],
            child: HomePage(),
          ),
        );

      case RouteNames.operadorHome:
        return MaterialPageRoute(
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.operador],
            child: HomePage(),
          ),
        );

      case RouteNames.perfil:
        return MaterialPageRoute(
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.cliente, RolEnum.operador],
            child: PerfilPage(),
          ),
        );

      case RouteNames.registrarIngreso:
        return MaterialPageRoute(
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.operador],
            child: RegistrarIngresoPage(),
          ),
        );

      case RouteNames.vehiculos:
        return MaterialPageRoute(
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.cliente],
            child: VehiculosPage(),
          ),
        );

      case RouteNames.vehiculosEstacionados:
        return MaterialPageRoute(
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.operador],
            child: VehiculosEstacionadosPage(),
          ),
        );

      case RouteNames.espacios:
        final args = settings.arguments;

        if (args is! int) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('No se recibió el parqueo para ver espacios.'),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => _RoleRequiredPage(
            allowedRoles: const [RolEnum.cliente, RolEnum.operador],
            child: EspaciosPage(parqueoId: args),
          ),
        );

      case RouteNames.historial:
        return MaterialPageRoute(
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.cliente, RolEnum.operador],
            child: HistorialPage(),
          ),
        );

      case RouteNames.tarifas:
        return MaterialPageRoute(
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.operador],
            child: TarifasPage(),
          ),
        );

      case RouteNames.crearParqueo:
        return MaterialPageRoute(
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.operador],
            child: CrearParqueoPage(),
          ),
        );

      case RouteNames.misParqueos:
        return MaterialPageRoute(
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.operador],
            child: MisParqueosPage(),
          ),
        );

      case RouteNames.crearReserva:
        final args = settings.arguments;

        if (args is ParqueoEntity) {
          return MaterialPageRoute(
            builder: (_) => _RoleRequiredPage(
              allowedRoles: const [RolEnum.cliente],
              child: CrearReservaPage(parqueo: args),
            ),
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
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.cliente],
            child: MisReservasPage(),
          ),
        );

      case RouteNames.qrTiempo:
        return MaterialPageRoute(
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.cliente, RolEnum.operador],
            child: QrTiempoPage(),
          ),
        );

      case RouteNames.salidasCobros:
        return MaterialPageRoute(
          builder: (_) => const _RoleRequiredPage(
            allowedRoles: [RolEnum.operador],
            child: CobroPage(),
          ),
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

String _homeRouteByRole(RolEnum rol) {
  switch (rol) {
    case RolEnum.cliente:
      return RouteNames.clienteHome;
    case RolEnum.operador:
      return RouteNames.operadorHome;
  }
}

class _RoleRequiredPage extends ConsumerWidget {
  const _RoleRequiredPage({required this.allowedRoles, required this.child});

  final List<RolEnum> allowedRoles;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioActual = ref.watch(sessionProvider);

    if (usuarioActual != null) {
      if (allowedRoles.contains(usuarioActual.rol)) {
        return child;
      }

      return _AccessDeniedPage(
        message: 'No tienes permiso para acceder a esta sección.',
      );
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

        if (!allowedRoles.contains(usuario.rol)) {
          return _AccessDeniedPage(
            message: 'No tienes permiso para acceder a esta sección.',
          );
        }

        return child;
      },
    );
  }
}

class _AccessDeniedPage extends StatelessWidget {
  const _AccessDeniedPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(message)));
  }
}
