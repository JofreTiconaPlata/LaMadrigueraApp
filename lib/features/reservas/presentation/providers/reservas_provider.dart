import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/features/reservas/data/datasources/reservas_remote_datasource.dart';
import 'package:la_madriguera/features/reservas/data/models/reserva_dto.dart';

final reservasDataSourceProvider = Provider<ReservasRemoteDataSource>((ref) {
  return ReservasRemoteDataSource();
});

final misReservasProvider = FutureProvider<List<ReservaDto>>((ref) async {
  final dataSource = ref.watch(reservasDataSourceProvider);

  return dataSource.getMisReservas();
});
