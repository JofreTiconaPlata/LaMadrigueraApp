import 'package:flutter/material.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/features/auth/presentation/pages/login_page.dart';
import 'package:la_madriguera/features/auth/presentation/pages/role_redirect_page.dart';
import 'package:la_madriguera/features/clientes/presentation/pages/cliente_home_page.dart';
import 'package:la_madriguera/features/dashboard/presentation/pages/admin_home_page.dart';
import 'package:la_madriguera/features/ingresos/presentation/pages/operador_home_page.dart';

class AppRouter {
  static const String login = RouteNames.login;
  static const String redirect = RouteNames.redirect;
  static const String clienteHome = RouteNames.clienteHome;
  static const String operadorHome = RouteNames.operadorHome;
  static const String adminHome = RouteNames.adminHome;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case RouteNames.redirect:
        return MaterialPageRoute(builder: (_) => const RoleRedirectPage());

      case RouteNames.clienteHome:
        return MaterialPageRoute(builder: (_) => const ClienteHomePage());

      case RouteNames.operadorHome:
        return MaterialPageRoute(builder: (_) => const OperadorHomePage());

      case RouteNames.adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomePage());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}
