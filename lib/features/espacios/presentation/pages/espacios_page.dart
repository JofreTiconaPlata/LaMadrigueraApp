import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class EspaciosPage extends ConsumerWidget {
  const EspaciosPage({super.key});

  void _handleSpaceTap(
    BuildContext context, {
    required int number,
    required bool ocupado,
    required RolEnum? rol,
  }) {
    if (rol == RolEnum.operador) {
      if (ocupado) {
        Navigator.pushNamed(context, RouteNames.salidasCobros);
        return;
      }

      Navigator.pushNamed(context, RouteNames.registrarIngreso);
      return;
    }

    if (ocupado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El espacio A$number está ocupado')),
      );
      return;
    }

    Navigator.pushNamed(context, RouteNames.qrTiempo);
  }

  Widget _spaceButton(
    BuildContext context, {
    required int number,
    required bool ocupado,
    required RolEnum? rol,
  }) {
    final esOperador = rol == RolEnum.operador;

    final statusText = ocupado ? 'Ocupado' : 'Disponible';
    final actionText = esOperador
        ? ocupado
              ? 'Cobrar salida'
              : 'Registrar ingreso'
        : ocupado
        ? 'No disponible'
        : 'Reservar';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () =>
          _handleSpaceTap(context, number: number, ocupado: ocupado, rol: rol),
      child: Container(
        decoration: BoxDecoration(
          color: ocupado ? Colors.red.shade100 : Colors.green.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ocupado ? Colors.red : Colors.green),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A$number',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ocupado ? Colors.red : Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: ocupado ? Colors.red.shade700 : Colors.green.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              actionText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  String _titleByRole(RolEnum? rol) {
    if (rol == RolEnum.operador) {
      return 'Gestión de espacios';
    }

    return 'Seleccionar espacio';
  }

  String _subtitleByRole(RolEnum? rol) {
    if (rol == RolEnum.operador) {
      return 'Toca un espacio disponible para registrar ingreso o uno ocupado para cobrar salida.';
    }

    return 'Elige un espacio disponible para generar tu reserva y código QR.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sessionProvider);
    final rol = usuario?.rol;
    final ocupados = {2, 5, 9};

    return Scaffold(
      appBar: AppBar(title: Text(_titleByRole(rol))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              rol == RolEnum.operador
                  ? 'Espacios del parqueo'
                  : 'Espacios disponibles',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _subtitleByRole(rol),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _legendItem(color: Colors.green, text: 'Disponible'),
                const SizedBox(width: 16),
                _legendItem(color: Colors.red, text: 'Ocupado'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final number = index + 1;
                  return _spaceButton(
                    context,
                    number: number,
                    ocupado: ocupados.contains(number),
                    rol: rol,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
