import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/salidas_cobros/data/datasources/salidas_cobros_remote_datasource.dart';
import 'package:la_madriguera/features/salidas_cobros/data/models/salida_cobro_dto.dart';

enum TipoReporteVehiculo { auto, moto }

enum PeriodoReporte { diario, tresDias, semanal, mensual, anual }

extension TipoReporteVehiculoX on TipoReporteVehiculo {
  String get label {
    switch (this) {
      case TipoReporteVehiculo.auto:
        return 'Autos';
      case TipoReporteVehiculo.moto:
        return 'Motos';
    }
  }

  String get backendValue {
    switch (this) {
      case TipoReporteVehiculo.auto:
        return 'AUTO';
      case TipoReporteVehiculo.moto:
        return 'MOTO';
    }
  }

  IconData get icon {
    switch (this) {
      case TipoReporteVehiculo.auto:
        return Icons.directions_car;
      case TipoReporteVehiculo.moto:
        return Icons.two_wheeler;
    }
  }
}

extension PeriodoReporteX on PeriodoReporte {
  String get label {
    switch (this) {
      case PeriodoReporte.diario:
        return 'Diario';
      case PeriodoReporte.tresDias:
        return 'Cada 3 días';
      case PeriodoReporte.semanal:
        return 'Semanal';
      case PeriodoReporte.mensual:
        return 'Mensual';
      case PeriodoReporte.anual:
        return 'Anual';
    }
  }

  DateTime desde(DateTime ahora) {
    switch (this) {
      case PeriodoReporte.diario:
        return DateTime(ahora.year, ahora.month, ahora.day);
      case PeriodoReporte.tresDias:
        return ahora.subtract(const Duration(days: 3));
      case PeriodoReporte.semanal:
        return ahora.subtract(const Duration(days: 7));
      case PeriodoReporte.mensual:
        return DateTime(ahora.year, ahora.month, 1);
      case PeriodoReporte.anual:
        return DateTime(ahora.year);
    }
  }
}

class ReportesOperadorPage extends StatelessWidget {
  const ReportesOperadorPage({super.key});

  void _abrirPeriodos(BuildContext context, TipoReporteVehiculo tipo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _SeleccionPeriodoPage(tipo: tipo)),
    );
  }

  Widget _tipoCard({
    required BuildContext context,
    required TipoReporteVehiculo tipo,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _abrirPeriodos(context, tipo),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(tipo.icon, color: AppTheme.primary, size: 34),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Reportes de ${tipo.label}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Reportes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Selecciona el tipo de vehículo',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Consulta estadísticas de autos y motos por día, semana, mes o año.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 22),
          _tipoCard(context: context, tipo: TipoReporteVehiculo.auto),
          const SizedBox(height: 14),
          _tipoCard(context: context, tipo: TipoReporteVehiculo.moto),
        ],
      ),
    );
  }
}

class _SeleccionPeriodoPage extends StatelessWidget {
  const _SeleccionPeriodoPage({required this.tipo});

  final TipoReporteVehiculo tipo;

  void _abrirReporte(BuildContext context, PeriodoReporte periodo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _DetalleReportePage(tipo: tipo, periodo: periodo),
      ),
    );
  }

  Widget _periodoCard(BuildContext context, PeriodoReporte periodo) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Icon(Icons.calendar_month, color: AppTheme.primary),
        title: Text(
          periodo.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Ver reporte ${periodo.label.toLowerCase()}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _abrirReporte(context, periodo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodos = PeriodoReporte.values;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text('Reportes de ${tipo.label}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Selecciona el periodo',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...periodos.map((periodo) => _periodoCard(context, periodo)),
        ],
      ),
    );
  }
}

class _DetalleReportePage extends StatefulWidget {
  const _DetalleReportePage({required this.tipo, required this.periodo});

  final TipoReporteVehiculo tipo;
  final PeriodoReporte periodo;

  @override
  State<_DetalleReportePage> createState() => _DetalleReportePageState();
}

class _DetalleReportePageState extends State<_DetalleReportePage> {
  late Future<List<SalidaCobroDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = SalidasCobrosRemoteDataSource().getSalidasCobros();
  }

  List<SalidaCobroDto> _filtrarPorPeriodo(List<SalidaCobroDto> salidas) {
    final ahora = DateTime.now();
    final desde = widget.periodo.desde(ahora);

    return salidas.where((salida) {
      final fecha = salida.fechaSalida;
      return fecha.isAfter(desde) || fecha.isAtSameMomentAs(desde);
    }).toList();
  }

  List<SalidaCobroDto> _filtrarPorTipo(
    List<SalidaCobroDto> salidas,
    String tipo,
  ) {
    return salidas.where((salida) {
      return salida.ingreso.vehiculo.tipo == tipo;
    }).toList();
  }

  double _sumarMonto(List<SalidaCobroDto> salidas) {
    return salidas.fold<double>(
      0,
      (total, salida) => total + salida.montoTotal,
    );
  }

  double _promedioTiempo(List<SalidaCobroDto> salidas) {
    if (salidas.isEmpty) return 0;

    final total = salidas.fold<int>(
      0,
      (sum, salida) => sum + salida.tiempoTotalMinutos,
    );

    return total / salidas.length;
  }

  String _formatearFecha(DateTime fecha) {
    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(fecha.day)}/${two(fecha.month)}/${fecha.year} '
        '${two(fecha.hour)}:${two(fecha.minute)}';
  }

  String _parqueoMasUsado(List<SalidaCobroDto> salidas) {
    if (salidas.isEmpty) return 'Sin datos';

    final conteo = <String, int>{};

    for (final salida in salidas) {
      final nombre = salida.ingreso.parqueo.nombre;
      conteo[nombre] = (conteo[nombre] ?? 0) + 1;
    }

    final ordenado = conteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ordenado.first.key;
  }

  Widget _metricCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8E4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard({required int autos, required int motos}) {
    final total = autos + motos;

    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(Icons.pie_chart_outline, size: 56, color: Colors.black38),
            SizedBox(height: 10),
            Text(
              'Todavía no hay datos para generar el gráfico.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    final porcentajeAutos = ((autos / total) * 100).round();
    final porcentajeMotos = ((motos / total) * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8E4)),
      ),
      child: Column(
        children: [
          const Text(
            'Comparación Autos vs Motos',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 46,
                sectionsSpace: 3,
                sections: [
                  PieChartSectionData(
                    value: autos.toDouble(),
                    title: '$porcentajeAutos%',
                    color: AppTheme.primary,
                    radius: 62,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: motos.toDouble(),
                    title: '$porcentajeMotos%',
                    color: Colors.orange,
                    radius: 62,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: AppTheme.primary, label: 'Autos: $autos'),
              const SizedBox(width: 16),
              _LegendItem(color: Colors.orange, label: 'Motos: $motos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detalleList(List<SalidaCobroDto> salidas) {
    if (salidas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            'No hay registros para este reporte.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: salidas.map((salida) {
        final vehiculo = salida.ingreso.vehiculo;
        final parqueo = salida.ingreso.parqueo;
        final espacio = salida.ingreso.espacio;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Icon(
              vehiculo.tipo == 'MOTO'
                  ? Icons.two_wheeler
                  : Icons.directions_car,
              color: AppTheme.primary,
            ),
            title: Text('${vehiculo.placa} · ${parqueo.nombre}'),
            subtitle: Text(
              '${espacio.codigo} · ${_formatearFecha(salida.fechaSalida)}',
            ),
            trailing: Text(
              '${salida.montoTotal.toStringAsFixed(2)} Bs',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('${widget.tipo.label} · ${widget.periodo.label}'),
      ),
      body: FutureBuilder<List<SalidaCobroDto>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo cargar el reporte: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final salidasPeriodo = _filtrarPorPeriodo(snapshot.data ?? []);
          final autos = _filtrarPorTipo(salidasPeriodo, 'AUTO');
          final motos = _filtrarPorTipo(salidasPeriodo, 'MOTO');

          final seleccionadas = _filtrarPorTipo(
            salidasPeriodo,
            widget.tipo.backendValue,
          );

          final monto = _sumarMonto(seleccionadas);
          final promedio = _promedioTiempo(seleccionadas);
          final parqueoMasUsado = _parqueoMasUsado(seleccionadas);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = SalidasCobrosRemoteDataSource().getSalidasCobros();
              });
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Reporte ${widget.periodo.label.toLowerCase()} de ${widget.tipo.label}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Parqueo más usado: $parqueoMasUsado',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 18),
                _chartCard(autos: autos.length, motos: motos.length),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _metricCard(
                      icon: widget.tipo.icon,
                      title: widget.tipo.label,
                      value: '${seleccionadas.length}',
                    ),
                    const SizedBox(width: 10),
                    _metricCard(
                      icon: Icons.payments,
                      title: 'Recaudado',
                      value: '${monto.toStringAsFixed(2)} Bs',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _metricCard(
                      icon: Icons.timer,
                      title: 'Tiempo promedio',
                      value: '${promedio.round()} min',
                    ),
                    const SizedBox(width: 10),
                    _metricCard(
                      icon: Icons.summarize,
                      title: 'Total periodo',
                      value: '${salidasPeriodo.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Detalle de registros',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _detalleList(seleccionadas),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
