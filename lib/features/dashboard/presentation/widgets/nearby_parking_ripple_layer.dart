import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:la_madriguera/app/theme/app_theme.dart';

class NearbyParkingRippleLayer extends StatefulWidget {
  const NearbyParkingRippleLayer({
    super.key,
    required this.center,
    required this.radiusMeters,
    required this.visible,
    this.onCompleted,
  });

  final LatLng center;
  final double radiusMeters;
  final bool visible;
  final VoidCallback? onCompleted;

  @override
  State<NearbyParkingRippleLayer> createState() =>
      _NearbyParkingRippleLayerState();
}

class _NearbyParkingRippleLayerState extends State<NearbyParkingRippleLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call();
      }
    });

    if (widget.visible) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant NearbyParkingRippleLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible && !oldWidget.visible) {
      _controller.forward(from: 0);
    }

    if (widget.visible &&
        oldWidget.center != widget.center &&
        oldWidget.visible == widget.visible) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final progress = _animation.value;
        final radius = widget.radiusMeters * progress;
        final opacity = (1 - progress).clamp(0.0, 1.0);

        return CircleLayer(
          circles: [
            CircleMarker(
              point: widget.center,
              radius: radius,
              useRadiusInMeter: true,
              color: AppTheme.primary.withValues(alpha: 0.10 * opacity),
              borderColor: AppTheme.primary.withValues(alpha: 0.60 * opacity),
              borderStrokeWidth: 3,
            ),
            CircleMarker(
              point: widget.center,
              radius: widget.radiusMeters,
              useRadiusInMeter: true,
              color: Colors.transparent,
              borderColor: AppTheme.primary.withValues(alpha: 0.18),
              borderStrokeWidth: 1.5,
            ),
          ],
        );
      },
    );
  }
}
