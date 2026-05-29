import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/reservas/data/models/reserva_dto.dart';
import 'package:la_madriguera/features/reservas/presentation/providers/reservas_provider.dart';
import 'package:la_madriguera/features/reservas/presentation/widgets/reserva_card.dart';

class MisReservasPage extends ConsumerWidget {
  const MisReservasPage({super.key});

  Future<void> _cancelarReserva(
    BuildContext context,
    WidgetRef ref,
    ReservaDto reserva,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar reserva'),
          content: Text(
            '¿Seguro que deseas cancelar la reserva #${reserva.id}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Volver'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancelar reserva'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      final dataSource = ref.read(reservasDataSourceProvider);

      await dataSource.cancelarReserva(reserva.id);

      ref.invalidate(misReservasProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada correctamente')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cancelar la reserva: $error')),
      );
    }
  }

  Future<void> _recargar(WidgetRef ref) async {
    ref.invalidate(misReservasProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservasAsync = ref.watch(misReservasProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mis reservas'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(misReservasProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _recargar(ref),
        child: reservasAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(24),
            children: const [
              SizedBox(height: 180),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text(
                'No se pudieron cargar tus reservas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          data: (reservas) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (reservas.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aún no tienes reservas registradas.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...reservas.map(
                    (reserva) => ReservaCard(
                      reserva: reserva,
                      onCancel: () => _cancelarReserva(context, ref, reserva),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
