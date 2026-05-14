class ParqueoEntity {
  const ParqueoEntity({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.espaciosAutos,
    required this.espaciosMotos,
    required this.precioHora,
    required this.latitud,
    required this.longitud,
  });

  final String id;
  final String nombre;
  final String direccion;
  final int espaciosAutos;
  final int espaciosMotos;
  final double precioHora;
  final double latitud;
  final double longitud;

  int get espaciosTotales => espaciosAutos + espaciosMotos;
}
