import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/reservas/data/models/reserva_dto.dart';
import 'package:la_madriguera/features/reservas/presentation/providers/reservas_provider.dart';
import 'package:la_madriguera/features/reservas/presentation/widgets/reserva_card.dart';

class MisReservasPage extends ConsumerStatefulWidget {
  const MisReservasPage({super.key});

  @override
  ConsumerState<MisReservasPage> createState() => _MisReservasPageState();
}

class _MisReservasPageState extends ConsumerState<MisReservasPage> {
  final Set<int> _reservasCancelando = <int>{};

  Future<void> _recargar() async {
    ref.invalidate(misReservasProvider);
    await ref.read(misReservasProvider.future);
  }

  Future<void> _cancelarReserva(ReservaDto reserva) async {
    if (!reserva.puedeCancelar || _reservasCancelando.contains(reserva.id)) {
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final espacio = reserva.espacio?.codigo ?? 'asignado';

        return AlertDialog(
          title: const Text('Cancelar reserva'),
          content: Text(
            '¿Deseas cancelar la reserva #${reserva.id}? '
            'El espacio $espacio volverá a estar disponible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Volver'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar reserva'),
            ),
          ],
        );
      },
    );

    if (confirmado != true || !mounted) {
      return;
    }

    setState(() {
      _reservasCancelando.add(reserva.id);
    });

    try {
      await ref.read(reservasDataSourceProvider).cancelarReserva(reserva.id);

      ref.invalidate(misReservasProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada y espacio liberado.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cancelar la reserva: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _reservasCancelando.remove(reserva.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservasAsync = ref.watch(misReservasProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Mis reservas'),
          actions: [
            IconButton(
              onPressed: () => ref.invalidate(misReservasProvider),
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'En progreso'),
              Tab(text: 'Terminadas'),
            ],
          ),
        ),
        body: reservasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorReservas(
            error: error,
            onRetry: () => ref.invalidate(misReservasProvider),
          ),
          data: (reservas) {
            final enProgreso = reservas
                .where((reserva) => reserva.estaEnProgreso)
                .toList();

            final terminadas = reservas
                .where((reserva) => reserva.estaTerminada)
                .toList();

            return TabBarView(
              children: [
                _ListaReservas(
                  reservas: enProgreso,
                  emptyTitle: 'No tienes reservas en progreso.',
                  emptySubtitle:
                      'Cuando reserves un espacio activo, aparecerá aquí.',
                  onRefresh: _recargar,
                  onCancelar: _cancelarReserva,
                  reservasCancelando: _reservasCancelando,
                ),
                _ListaReservas(
                  reservas: terminadas,
                  emptyTitle: 'Aún no tienes reservas terminadas.',
                  emptySubtitle:
                      'Cuando finalices un parqueo, aparecerá aquí como historial.',
                  onRefresh: _recargar,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ListaReservas extends StatelessWidget {
  const _ListaReservas({
    required this.reservas,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    this.onCancelar,
    this.reservasCancelando = const <int>{},
  });

  final List<ReservaDto> reservas;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final ValueChanged<ReservaDto>? onCancelar;
  final Set<int> reservasCancelando;

  @override
  Widget build(BuildContext context) {
    if (reservas.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 100),
            const Icon(Icons.history, size: 72, color: AppTheme.primary),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Total: ${reservas.length} reserva(s)',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          ...reservas.map(
            (reserva) => ReservaCard(
              reserva: reserva,
              cancelando: reservasCancelando.contains(reserva.id),
              onCancelar: reserva.puedeCancelar && onCancelar != null
                  ? () => onCancelar!(reserva)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorReservas extends StatelessWidget {
  const _ErrorReservas({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
