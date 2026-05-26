import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_madriguera/features/vehiculos/data/datasources/vehiculos_remote_datasource.dart';
import 'package:la_madriguera/features/vehiculos/data/models/vehiculo_dto.dart';

final vehiculosDataSourceProvider = Provider<VehiculosRemoteDataSource>((ref) {
  return VehiculosRemoteDataSource();
});

final vehiculosClienteProvider = FutureProvider<List<VehiculoDto>>((ref) async {
  final dataSource = ref.watch(vehiculosDataSourceProvider);

  return dataSource.getVehiculos();
});
