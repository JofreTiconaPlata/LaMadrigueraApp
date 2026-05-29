import 'package:flutter/material.dart';

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
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case RouteNames.redirect:
        return MaterialPageRoute(builder: (_) => const RoleRedirectPage());

      case RouteNames.clienteHome:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case RouteNames.operadorHome:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case RouteNames.adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomePage());

      case RouteNames.perfil:
        return MaterialPageRoute(builder: (_) => const PerfilPage());

      case RouteNames.registrarIngreso:
        return MaterialPageRoute(builder: (_) => const RegistrarIngresoPage());

      case RouteNames.vehiculos:
        return MaterialPageRoute(builder: (_) => const VehiculosPage());

      case RouteNames.vehiculosEstacionados:
        return MaterialPageRoute(
          builder: (_) => const VehiculosEstacionadosPage(),
        );

      case RouteNames.espacios:
        final parqueoId = (settings.arguments ?? 1) as int;
        return MaterialPageRoute(
          builder: (_) => EspaciosPage(parqueoId: parqueoId),
        );

      case RouteNames.historial:
        return MaterialPageRoute(builder: (_) => const HistorialPage());

      case RouteNames.tarifas:
        return MaterialPageRoute(builder: (_) => const TarifasPage());

      case RouteNames.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());

      case RouteNames.crearParqueo:
        return MaterialPageRoute(builder: (_) => const CrearParqueoPage());

      case RouteNames.misParqueos:
        return MaterialPageRoute(builder: (_) => const MisParqueosPage());

      case RouteNames.crearReserva:
        final args = settings.arguments;

        if (args is ParqueoEntity) {
          return MaterialPageRoute(
            builder: (_) => CrearReservaPage(parqueo: args),
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
        return MaterialPageRoute(builder: (_) => const MisReservasPage());

      case RouteNames.qrTiempo:
        return MaterialPageRoute(builder: (_) => const QrTiempoPage());

      case RouteNames.salidasCobros:
        return MaterialPageRoute(builder: (_) => const CobroPage());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}
