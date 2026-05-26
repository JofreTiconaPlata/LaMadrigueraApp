import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/reservas/data/models/reserva_dto.dart';

class ReservaCard extends StatelessWidget {
  const ReservaCard({super.key, required this.reserva, required this.onCancel});

  final ReservaDto reserva;
  final VoidCallback onCancel;

  String _dosDigitos(int value) => value.toString().padLeft(2, '0');

  String _formatearFecha(DateTime fecha) {
    return '${_dosDigitos(fecha.day)}/${_dosDigitos(fecha.month)}/${fecha.year} '
        '${_dosDigitos(fecha.hour)}:${_dosDigitos(fecha.minute)}';
  }

  bool get _puedeCancelar =>
      reserva.estado == 'ACTIVA' || reserva.estado == 'PENDIENTE';

  Color get _estadoColor {
    switch (reserva.estado) {
      case 'ACTIVA':
        return AppTheme.primary;
      case 'COMPLETADA':
        return Colors.blueGrey;
      case 'CANCELADA':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      fontSize: 16,
                    ),
                  ),
                ),
                Chip(
                  label: Text(reserva.estado),
                  side: BorderSide(color: _estadoColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Parqueo ID: ${reserva.parqueoId}',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            Text(
              'Vehículo ID: ${reserva.vehiculoId}',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            if (reserva.espacioId != null)
              Text(
                'Espacio ID: ${reserva.espacioId}',
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            const SizedBox(height: 8),
            Text(
              'Inicio: ${_formatearFecha(reserva.fechaInicio)}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            Text(
              'Fin: ${_formatearFecha(reserva.fechaFin)}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            if (_puedeCancelar) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar reserva'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
