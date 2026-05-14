import 'package:flutter/foundation.dart';
import 'package:la_madriguera/features/parqueos/domain/entities/parqueo_entity.dart';

class ParqueosProvider {
  ParqueosProvider._();

  static final ValueNotifier<List<ParqueoEntity>> parqueosNotifier =
      ValueNotifier<List<ParqueoEntity>>([
    const ParqueoEntity(
      id: 'parqueo-central-demo',
      nombre: 'Parqueo Central',
      direccion: 'Centro de la ciudad',
      espaciosAutos: 12,
      espaciosMotos: 8,
      precioHora: 5,
      latitud: -17.7833,
      longitud: -63.1821,
    ),
  ]);

  static void agregarParqueo(ParqueoEntity parqueo) {
    parqueosNotifier.value = List.unmodifiable([
      ...parqueosNotifier.value,
      parqueo,
    ]);
  }
}
