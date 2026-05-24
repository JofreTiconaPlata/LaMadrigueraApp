import 'package:latlong2/latlong.dart';

class MapCityPreset {
  const MapCityPreset({
    required this.name,
    required this.center,
    required this.zoom,
  });

  final String name;
  final LatLng center;
  final double zoom;
}

class MapCityPresets {
  static const cochabamba = MapCityPreset(
    name: 'Cochabamba',
    center: LatLng(-17.3935, -66.1570),
    zoom: 14,
  );

  static const laPaz = MapCityPreset(
    name: 'La Paz',
    center: LatLng(-16.5000, -68.1500),
    zoom: 13,
  );

  static const santaCruz = MapCityPreset(
    name: 'Santa Cruz',
    center: LatLng(-17.7833, -63.1821),
    zoom: 13,
  );

  static const defaultCity = cochabamba;
}
