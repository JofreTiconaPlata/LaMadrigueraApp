import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/vehiculos/data/models/vehiculo_dto.dart';

class VehiculoCard extends StatelessWidget {
  const VehiculoCard({
    super.key,
    required this.vehiculo,
    required this.onDelete,
  });

  final VehiculoDto vehiculo;
  final VoidCallback onDelete;

  IconData get _icono {
    return vehiculo.tipo == 'MOTO' ? Icons.two_wheeler : Icons.directions_car;
  }

  @override
  Widget build(BuildContext context) {
    final detalles = [
      if (vehiculo.marca != null && vehiculo.marca!.isNotEmpty) vehiculo.marca,
      if (vehiculo.modelo != null && vehiculo.modelo!.isNotEmpty)
        vehiculo.modelo,
      if (vehiculo.color != null && vehiculo.color!.isNotEmpty) vehiculo.color,
    ].join(' · ');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8F5E9),
          child: Icon(_icono, color: AppTheme.primary),
        ),
        title: Text(
          vehiculo.placa,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          detalles.isEmpty ? vehiculo.tipo : '${vehiculo.tipo} · $detalles',
        ),
        trailing: IconButton(
          tooltip: 'Eliminar vehículo',
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
