import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class QrTiempoPage extends ConsumerWidget {
  const QrTiempoPage({super.key});

  String _titleByRole(RolEnum? rol) {
    if (rol == RolEnum.operador) {
      return 'Validación QR';
    }

    return 'Mi reserva';
  }

  String _subtitleByRole(RolEnum? rol) {
    if (rol == RolEnum.operador) {
      return 'Escanea o valida el código QR del cliente para gestionar el ingreso o salida.';
    }

    return 'Presenta este código QR al operador del parqueo para validar tu reserva.';
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.black54)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, RolEnum? rol) {
    if (rol == RolEnum.operador) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, RouteNames.salidasCobros),
          icon: const Icon(Icons.point_of_sale),
          label: const Text('Finalizar y cobrar'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reserva cancelada correctamente')),
          );

          Navigator.pushReplacementNamed(context, RouteNames.clienteHome);
        },
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Cancelar reserva'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sessionProvider);
    final rol = usuario?.rol;

    return Scaffold(
      appBar: AppBar(title: Text(_titleByRole(rol))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                rol == RolEnum.operador
                    ? 'Código QR del cliente'
                    : 'Reserva activa',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitleByRole(rol),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.qr_code_2, size: 170),
              ),
              const SizedBox(height: 24),
              _infoCard(
                icon: Icons.local_parking,
                title: 'Espacio seleccionado',
                value: 'A1',
              ),
              _infoCard(
                icon: Icons.timer_outlined,
                title: rol == RolEnum.operador
                    ? 'Tiempo transcurrido'
                    : 'Tiempo reservado',
                value: '00:45:00',
              ),
              _infoCard(
                icon: Icons.payments_outlined,
                title: 'Tarifa estimada',
                value: 'Bs 10',
              ),
              const Spacer(),
              _actionButton(context, rol),
            ],
          ),
        ),
      ),
    );
  }
}
