import 'package:flutter/material.dart';

import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/reservas/data/models/reserva_dto.dart';

class ReservaCard extends StatelessWidget {
  const ReservaCard({super.key, required this.reserva});

  final ReservaDto reserva;

  String _dosDigitos(int value) => value.toString().padLeft(2, '0');

  String _formatearFecha(DateTime fecha) {
    final fechaLocal = fecha.toLocal();

    return '${_dosDigitos(fechaLocal.day)}/${_dosDigitos(fechaLocal.month)}/${fechaLocal.year} '
        '${_dosDigitos(fechaLocal.hour)}:${_dosDigitos(fechaLocal.minute)}';
  }

  String get _estadoLabel {
    switch (reserva.estado) {
      case 'ACTIVA':
        return 'EN PROGRESO';
      case 'PENDIENTE':
        return 'PENDIENTE';
      case 'COMPLETADA':
      case 'FINALIZADA':
      case 'CANCELADA':
        return 'TERMINADA';
      default:
        return reserva.estado;
    }
  }

  Color get _estadoColor {
    switch (reserva.estado) {
      case 'ACTIVA':
        return AppTheme.primary;
      case 'PENDIENTE':
        return Colors.orange;
      case 'COMPLETADA':
      case 'FINALIZADA':
      case 'CANCELADA':
        return Colors.blueGrey;
      default:
        return Colors.black54;
    }
  }

  IconData get _iconoTipoVehiculo {
    final tipo = reserva.vehiculo?.tipo ?? '';

    if (tipo == 'MOTO') {
      return Icons.two_wheeler;
    }

    return Icons.directions_car;
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppTheme.primary),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parqueoNombre =
        reserva.parqueo?.nombre ?? 'Parqueo #${reserva.parqueoId}';
    final parqueoDireccion =
        reserva.parqueo?.direccion ?? 'Sin dirección registrada';
    final placa = reserva.vehiculo?.placa ?? 'Vehículo #${reserva.vehiculoId}';
    final tipoVehiculo = reserva.vehiculo?.tipo ?? 'Vehículo';
    final espacio =
        reserva.espacio?.codigo ??
        (reserva.espacioId == null
            ? 'Sin espacio'
            : 'Espacio #${reserva.espacioId}');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE8F5E9),
                  child: Icon(Icons.event_available, color: _estadoColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reserva #${reserva.id}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Chip(
                  label: Text(_estadoLabel),
                  side: BorderSide(color: _estadoColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _infoRow(
              icon: Icons.local_parking,
              label: 'Parqueo',
              value: parqueoNombre,
            ),
            _infoRow(
              icon: Icons.place,
              label: 'Lugar',
              value: parqueoDireccion,
            ),
            _infoRow(
              icon: _iconoTipoVehiculo,
              label: 'Vehículo',
              value: '$tipoVehiculo · Placa $placa',
            ),
            _infoRow(icon: Icons.grid_view, label: 'Espacio', value: espacio),
            const Divider(height: 22),
            _infoRow(
              icon: Icons.login,
              label: 'Entrada',
              value: _formatearFecha(reserva.fechaInicio),
            ),
            _infoRow(
              icon: Icons.logout,
              label: reserva.estaEnProgreso ? 'Salida estimada' : 'Salida',
              value: _formatearFecha(reserva.fechaFin),
            ),
          ],
        ),
      ),
    );
  }
}
