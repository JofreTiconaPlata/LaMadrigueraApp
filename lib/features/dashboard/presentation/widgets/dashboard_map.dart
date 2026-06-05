import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/features/parqueos/data/models/parqueo_dto.dart';

class DashboardMapCard extends StatelessWidget {
  const DashboardMapCard({
    super.key,
    required this.height,
    required this.borderRadius,
    required this.initialCenter,
    required this.initialZoom,
    required this.parqueosAsync,
    required this.currentUserLocation,
    required this.onParqueoTap,
    this.highlightedParqueoIds = const {},
  });

  final double height;
  final double borderRadius;
  final LatLng initialCenter;
  final double initialZoom;
  final AsyncValue<List<ParqueoDto>> parqueosAsync;
  final LatLng? currentUserLocation;
  final ValueChanged<ParqueoDto> onParqueoTap;
  final Set<int> highlightedParqueoIds;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: null,
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.programovil.lamadriguera',
          ),
          parqueosAsync.when(
            loading: () => const MarkerLayer(markers: []),
            error: (_, _) => const MarkerLayer(markers: []),
            data: (parqueos) {
              return MarkerLayer(
                markers: parqueos.map((parqueo) {
                  final isHighlighted = highlightedParqueoIds.contains(
                    parqueo.id,
                  );

                  return Marker(
                    point: LatLng(parqueo.latitud, parqueo.longitud),
                    width: 56,
                    height: 56,
                    child: GestureDetector(
                      onTap: () => onParqueoTap(parqueo),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: isHighlighted
                              ? Colors.greenAccent.shade700
                              : AppTheme.primary,
                          borderRadius: BorderRadius.circular(16),
                          border: isHighlighted
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_parking,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          if (currentUserLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: currentUserLocation!,
                  width: 46,
                  height: 46,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
