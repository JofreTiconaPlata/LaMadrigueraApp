import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/reservas/data/datasources/reservas_remote_datasource.dart';
import 'package:la_madriguera/features/reservas/data/models/reserva_dto.dart';

enum TipoReporteVehiculo { general, auto, moto }

enum PeriodoReporte { diario, tresDias, semanal, mensual, anual }

extension TipoReporteVehiculoX on TipoReporteVehiculo {
  String get label {
    switch (this) {
      case TipoReporteVehiculo.general:
        return 'General';
      case TipoReporteVehiculo.auto:
        return 'Autos';
      case TipoReporteVehiculo.moto:
        return 'Motos';
    }
  }

  String get title {
    switch (this) {
      case TipoReporteVehiculo.general:
        return 'Reporte general de vehículos';
      case TipoReporteVehiculo.auto:
        return 'Reportes de Autos';
      case TipoReporteVehiculo.moto:
        return 'Reportes de Motos';
    }
  }

  String get description {
    switch (this) {
      case TipoReporteVehiculo.general:
        return 'Autos y motos juntos por periodo.';
      case TipoReporteVehiculo.auto:
        return 'Estadísticas solo de autos.';
      case TipoReporteVehiculo.moto:
        return 'Estadísticas solo de motos.';
    }
  }

  IconData get icon {
    switch (this) {
      case TipoReporteVehiculo.general:
        return Icons.analytics_outlined;
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
      elevation: 1,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipo.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tipo == TipoReporteVehiculo.general) ...[
                      const SizedBox(height: 4),
                      Text(
                        tipo.description,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
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
          const SizedBox(height: 14),
          _tipoCard(context: context, tipo: TipoReporteVehiculo.general),
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
        leading: const Icon(Icons.calendar_month, color: AppTheme.primary),
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
      appBar: AppBar(title: Text(tipo.title)),
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
          const SizedBox(height: 8),
          Text(
            tipo.description,
            style: const TextStyle(color: AppTheme.textSecondary),
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
  late Future<List<ReservaDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = ReservasRemoteDataSource().getReservasOperador();
  }

  String _tipoVehiculo(ReservaDto reserva) {
    return reserva.vehiculo?.tipo.trim().toUpperCase() ?? '';
  }

  bool _esAuto(ReservaDto reserva) => _tipoVehiculo(reserva) == 'AUTO';

  bool _esMoto(ReservaDto reserva) => _tipoVehiculo(reserva) == 'MOTO';

  bool _estaEnProgreso(ReservaDto reserva) {
    final estado = reserva.estado.trim().toUpperCase();
    return estado == 'ACTIVA' ||
        estado == 'PENDIENTE' ||
        estado == 'RESERVADA' ||
        estado == 'EN_PROGRESO';
  }

  List<ReservaDto> _filtrarPorPeriodo(List<ReservaDto> reservas) {
    final ahora = DateTime.now();
    final desde = widget.periodo.desde(ahora);

    return reservas.where((reserva) {
      final fecha = reserva.fechaInicio;
      return fecha.isAfter(desde) || fecha.isAtSameMomentAs(desde);
    }).toList();
  }

  List<ReservaDto> _filtrarPorTipo(List<ReservaDto> reservas) {
    switch (widget.tipo) {
      case TipoReporteVehiculo.general:
        return reservas.where((reserva) {
          return _esAuto(reserva) || _esMoto(reserva);
        }).toList();
      case TipoReporteVehiculo.auto:
        return reservas.where(_esAuto).toList();
      case TipoReporteVehiculo.moto:
        return reservas.where(_esMoto).toList();
    }
  }

  String _formatearFecha(DateTime fecha) {
    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(fecha.day)}/${two(fecha.month)}/${fecha.year} '
        '${two(fecha.hour)}:${two(fecha.minute)}';
  }

  String _parqueoMasUsado(List<ReservaDto> reservas) {
    if (reservas.isEmpty) return 'Sin datos';

    final conteo = <String, int>{};

    for (final reserva in reservas) {
      final nombre = reserva.parqueo?.nombre ?? 'Parqueo #${reserva.parqueoId}';
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
    return Container(
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
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(List<Widget> children) {
    return Row(
      children: [
        for (int index = 0; index < children.length; index++) ...[
          Expanded(child: children[index]),
          if (index != children.length - 1) const SizedBox(width: 10),
        ],
      ],
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

  Widget _detalleList(List<ReservaDto> reservas) {
    if (reservas.isEmpty) {
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
      children: reservas.map((reserva) {
        final vehiculo = reserva.vehiculo;
        final parqueo = reserva.parqueo;
        final espacio = reserva.espacio;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Icon(
              _esMoto(reserva) ? Icons.two_wheeler : Icons.directions_car,
              color: AppTheme.primary,
            ),
            title: Text(
              '${vehiculo?.placa ?? 'Sin placa'} · '
              '${parqueo?.nombre ?? 'Parqueo #${reserva.parqueoId}'}',
            ),
            subtitle: Text(
              '${espacio?.codigo ?? 'Espacio #${reserva.espacioId ?? '-'}'} · '
              '${_formatearFecha(reserva.fechaInicio)}',
            ),
            trailing: Text(
              reserva.estado,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _tituloReporte() {
    final periodo = widget.periodo.label.toLowerCase();

    if (widget.tipo == TipoReporteVehiculo.general) {
      return 'Reporte general $periodo';
    }

    return 'Reporte $periodo de ${widget.tipo.label}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('${widget.tipo.label} · ${widget.periodo.label}'),
      ),
      body: FutureBuilder<List<ReservaDto>>(
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

          final reservasPeriodo = _filtrarPorPeriodo(snapshot.data ?? []);
          final autosPeriodo = reservasPeriodo.where(_esAuto).toList();
          final motosPeriodo = reservasPeriodo.where(_esMoto).toList();
          final seleccionadas = _filtrarPorTipo(reservasPeriodo);

          final parqueoMasUsado = _parqueoMasUsado(seleccionadas);
          final enProgreso = seleccionadas
              .where((reserva) => _estaEnProgreso(reserva))
              .length;
          final terminadas = seleccionadas.length - enProgreso;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = ReservasRemoteDataSource().getReservasOperador();
              });
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  _tituloReporte(),
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
                _chartCard(
                  autos: autosPeriodo.length,
                  motos: motosPeriodo.length,
                ),
                const SizedBox(height: 16),
                if (widget.tipo == TipoReporteVehiculo.general) ...[
                  _metricRow([
                    _metricCard(
                      icon: Icons.directions_car,
                      title: 'Autos',
                      value: '${autosPeriodo.length}',
                    ),
                    _metricCard(
                      icon: Icons.two_wheeler,
                      title: 'Motos',
                      value: '${motosPeriodo.length}',
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _metricRow([
                    _metricCard(
                      icon: Icons.summarize,
                      title: 'Total general',
                      value: '${seleccionadas.length}',
                    ),
                    _metricCard(
                      icon: Icons.timelapse,
                      title: 'En progreso',
                      value: '$enProgreso',
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _metricRow([
                    _metricCard(
                      icon: Icons.check_circle,
                      title: 'Terminadas',
                      value: '$terminadas',
                    ),
                    _metricCard(
                      icon: Icons.calendar_month,
                      title: 'Total periodo',
                      value: '${reservasPeriodo.length}',
                    ),
                  ]),
                ] else ...[
                  _metricRow([
                    _metricCard(
                      icon: widget.tipo.icon,
                      title: widget.tipo.label,
                      value: '${seleccionadas.length}',
                    ),
                    _metricCard(
                      icon: Icons.summarize,
                      title: 'Total periodo',
                      value: '${reservasPeriodo.length}',
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _metricRow([
                    _metricCard(
                      icon: Icons.timelapse,
                      title: 'En progreso',
                      value: '$enProgreso',
                    ),
                    _metricCard(
                      icon: Icons.check_circle,
                      title: 'Terminadas',
                      value: '$terminadas',
                    ),
                  ]),
                ],
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
