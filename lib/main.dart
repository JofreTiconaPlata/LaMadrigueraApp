import 'package:flutter/material.dart';

import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/parqueos/presentation/pages/detalle_parqueo_page.dart';
import 'features/parqueos/presentation/pages/crear_parqueo_page.dart';
import 'features/espacios/presentation/pages/espacios_page.dart';
import 'features/qr/presentation/pages/qr_tiempo_page.dart';
import 'features/salidas_cobros/presentation/pages/salidas_cobros_page.dart';
import 'features/perfil/presentation/pages/perfil_page.dart';

import 'features/ingresos/presentation/pages/registrar_ingreso_page.dart';
import 'features/vehiculos/presentation/pages/vehiculos_estacionados_page.dart';
import 'features/historial/presentation/pages/historial_page.dart';
import 'features/tarifas/presentation/pages/tarifas_page.dart';
import 'features/admin/presentation/pages/admin_dashboard_page.dart';

void main() {
  runApp(const LaMadrigueraApp());
}

class LaMadrigueraApp extends StatelessWidget {
  const LaMadrigueraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Madriguera',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
        ),
      ),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const HomePage(),
        '/detalle-parqueo': (_) => const DetalleParqueoPage(),
        '/crear-parqueo': (_) => const CrearParqueoPage(),
        '/espacios': (_) => const EspaciosPage(),
        '/qr-tiempo': (_) => const QrTiempoPage(),
        '/cobro': (_) => const CobroPage(),
        '/perfil': (_) => const PerfilPage(),
        
        '/registrar-ingreso': (_) => RegistrarIngresoPage(),
        '/vehiculos-estacionados': (_) => VehiculosEstacionadosPage(),
        '/historial': (_) => HistorialPage(),
        '/tarifas': (_) => TarifasPage(),
        '/admin-dashboard': (_) => AdminDashboardPage(),
      },
    );
  }
}