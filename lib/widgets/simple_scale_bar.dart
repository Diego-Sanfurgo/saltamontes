import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class SimpleScaleBar extends StatelessWidget {
  const SimpleScaleBar({
    super.key,
    required this.cameraStateNotifier,
    this.alignment = Alignment.centerRight,
  });

  final ValueNotifier<CameraState?> cameraStateNotifier;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ValueListenableBuilder<CameraState?>(
        valueListenable: cameraStateNotifier,
        builder: (context, cameraState, child) {
          if (cameraState == null) return const SizedBox.shrink();
          return _ScaleBarPainterWrapper(
            zoom: cameraState.zoom,
            latitude: cameraState.center.coordinates.lat.toDouble(),
          );
        },
      ),
    );
  }
}

class _ScaleBarPainterWrapper extends StatelessWidget {
  const _ScaleBarPainterWrapper({required this.zoom, required this.latitude});

  final double zoom;
  final double latitude;

  @override
  Widget build(BuildContext context) {
    // 1. Calculate meters per pixel at this latitude and zoom
    // Formula: (circumference * cos(lat)) / 2^(zoom + 8)  (assuming 256px tiles)
    // Mapbox GL JS / Native often use 512px tiles, so it might be 2^(zoom+9) or
    // simply scale adjusted.
    // Let's standard usage for Web Mercator on Mapbox:
    // meters/px = 156543.03392 * cos(lat) / 2^zoom
    final double latRad = latitude * pi / 180.0;
    final double metersPerPixel = (156543.03392 * cos(latRad)) / pow(2, zoom);

    // 2. Determine a target display height for the bar (e.g. 50-150px)
    const double targetHeightPx = 100.0;

    // 3. Current distance for that target height
    final double roughDistanceMeters = metersPerPixel * targetHeightPx;

    // 4. Round to a nice number
    final double niceDistanceMeters = _getNiceDistance(roughDistanceMeters);

    // 5. Calculate exact pixel height for that nice distance
    final double barHeight = niceDistanceMeters / metersPerPixel;

    // 6. Formatted text
    final String label = _formatDistance(niceDistanceMeters);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Top tick
        Container(height: 1, width: 8, color: Colors.black),
        // Vertical line and Text
        SizedBox(
          height: barHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(width: 2, color: Colors.black),
            ],
          ),
        ),
        // Bottom tick
        Container(height: 1, width: 8, color: Colors.black),
      ],
    );
  }

  double _getNiceDistance(double distance) {
    // Identify order of magnitude
    final double magnitude = pow(10, (log(distance) / ln10).floor()).toDouble();
    final double residual = distance / magnitude;

    // Standard "nice" steps: 1, 2, 5, 10
    if (residual > 5) {
      return 10 * magnitude;
    } else if (residual > 2) {
      return 5 * magnitude;
    } else if (residual > 1) {
      return 2 * magnitude;
    } else {
      return 1 * magnitude;
    }
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(0)} km';
    } else {
      return '${meters.toStringAsFixed(0)} m';
    }
  }
}
