import 'package:flutter/material.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/features/ingresos/data/datasources/ingresos_remote_datasource.dart';
import 'package:la_madriguera/features/ingresos/data/models/ingreso_dto.dart';
import 'package:la_madriguera/features/salidas_cobros/data/datasources/salidas_cobros_remote_datasource.dart';
import 'package:la_madriguera/features/salidas_cobros/data/models/salida_cobro_dto.dart';

final ingresoCobroProvider = FutureProvider.family<IngresoDto, int>((
  ref,
  ingresoId,
) async {
  final dataSource = IngresosRemoteDataSource();

  return dataSource.getIngresoById(ingresoId);
});

class CobroPage extends ConsumerStatefulWidget {
  const CobroPage({super.key});

  @override
  ConsumerState<CobroPage> createState() => _CobroPageState();
}

class _CobroPageState extends ConsumerState<CobroPage> {
  String metodoPago = 'EFECTIVO';
  bool registrando = false;
  SalidaCobroDto? salidaCobro;

  int? _obtenerIngresoId(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is int) {
      return args;
    }

    return null;
  }

  String _formatearHora(DateTime fecha) {
    final local = fecha.toLocal();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  Future<void> _confirmarPago(int ingresoId) async {
    setState(() {
      registrando = true;
    });

    try {
      final dataSource = SalidasCobrosRemoteDataSource();

      final resultado = await dataSource.registrarSalidaCobro(
        ingresoId: ingresoId,
        metodoPago: metodoPago,
        referencia: 'Pago registrado desde app',
      );

      if (!mounted) return;

      setState(() {
        salidaCobro = resultado;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salida y cobro registrados')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar el cobro: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          registrando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingresoId = _obtenerIngresoId(context);

    if (ingresoId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cobro')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No se recibió el ingreso para realizar el cobro.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final ingresoAsync = ref.watch(ingresoCobroProvider(ingresoId));

    return Scaffold(
      appBar: AppBar(title: const Text('Cobro')),
      body: ingresoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text(
                  'No se pudo cargar el ingreso.',
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
                  onPressed: () =>
                      ref.invalidate(ingresoCobroProvider(ingresoId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (ingreso) {
          final salida = salidaCobro;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.payments, size: 90, color: AppTheme.primary),
              const SizedBox(height: 20),
              const Text(
                'Resumen de pago',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _ResumenRow(
                        label: 'Placa',
                        value: ingreso.vehiculo.placa,
                      ),
                      const Divider(),
                      _ResumenRow(label: 'Tipo', value: ingreso.vehiculo.tipo),
                      const Divider(),
                      _ResumenRow(
                        label: 'Espacio',
                        value: ingreso.espacio.codigo,
                      ),
                      const Divider(),
                      _ResumenRow(
                        label: 'Ingreso',
                        value: _formatearHora(ingreso.fechaIngreso),
                      ),
                      const Divider(),
                      if (salida == null)
                        const _ResumenRow(
                          label: 'Estado',
                          value: 'Pendiente de cobro',
                        )
                      else ...[
                        _ResumenRow(
                          label: 'Tiempo',
                          value: '${salida.tiempoTotalMinutos} min',
                        ),
                        const Divider(),
                        _ResumenRow(
                          label: 'Total',
                          value: 'Bs ${salida.montoTotal.toStringAsFixed(2)}',
                          destacado: true,
                        ),
                        const Divider(),
                        _ResumenRow(
                          label: 'Pago',
                          value: salida.estadoPago,
                          destacado: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: metodoPago,
                decoration: InputDecoration(
                  labelText: 'Método de pago',
                  prefixIcon: const Icon(Icons.payment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'EFECTIVO', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'QR', child: Text('QR')),
                  DropdownMenuItem(value: 'TARJETA', child: Text('Tarjeta')),
                  DropdownMenuItem(
                    value: 'TRANSFERENCIA',
                    child: Text('Transferencia'),
                  ),
                ],
                onChanged: registrando || salida != null
                    ? null
                    : (value) {
                        setState(() {
                          metodoPago = value ?? 'EFECTIVO';
                        });
                      },
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: registrando || salida != null
                      ? null
                      : () => _confirmarPago(ingreso.id),
                  icon: registrando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    salida != null
                        ? 'Cobro registrado'
                        : registrando
                        ? 'Registrando...'
                        : 'Confirmar pago',
                  ),
                ),
              ),
              if (salida != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/vehiculos-estacionados',
                      (_) => false,
                    ),
                    icon: const Icon(Icons.local_parking),
                    label: const Text('Volver a vehículos estacionados'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ResumenRow extends StatelessWidget {
  const _ResumenRow({
    required this.label,
    required this.value,
    this.destacado = false,
  });

  final String label;
  final String value;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final style = destacado
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Flexible(
          child: Text(value, textAlign: TextAlign.end, style: style),
        ),
      ],
    );
  }
}
