import 'package:saltamontes/data/models/trace_point.dart';

/// Compila puntos GPS crudos en un GeoJSON LineStringZM y calcula métricas.
///
/// Usado al "Finalizar Excursión" (Módulo 5) para empaquetar los datos
/// antes de meterlos en la sync_queue.
class TrackCompiler {
  /// Compila una lista de TracePoints en un payload listo para Supabase.
  static Map<String, dynamic> compile(List<TracePoint> points) {
    if (points.isEmpty) {
      return {'geojson': _emptyLineString(), 'metrics': _emptyMetrics()};
    }

    // Ordenar por timestamp
    final sorted = List<TracePoint>.from(points)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Coordenadas XYZM (lng, lat, alt, timestamp_ms)
    final coordinates = sorted.map((p) {
      return [p.lon, p.lat, p.altitude ?? 0.0, p.timestamp.toDouble()];
    }).toList();

    // Métricas
    double elevationGain = 0;
    double elevationLoss = 0;
    double maxAlt = sorted.first.altitude ?? 0;
    double minAlt = sorted.first.altitude ?? 0;
    int movingTimeMs = 0;

    const double speedThreshold =
        0.3; // m/s — umbral para considerar "moviendo"

    for (int i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final curr = sorted[i];

      // Elevación
      final prevAlt = prev.altitude ?? 0;
      final currAlt = curr.altitude ?? 0;
      final diff = currAlt - prevAlt;

      if (diff > 0) {
        elevationGain += diff;
      } else {
        elevationLoss += diff.abs();
      }

      if (currAlt > maxAlt) maxAlt = currAlt;
      if (currAlt < minAlt) minAlt = currAlt;

      // Tiempo en movimiento (si la velocidad > threshold)
      final speed = curr.speed ?? 0;
      if (speed > speedThreshold) {
        movingTimeMs += (curr.timestamp - prev.timestamp);
      }
    }

    final totalTimeMs = sorted.last.timestamp - sorted.first.timestamp;

    return {
      'geojson': {'type': 'LineString', 'coordinates': coordinates},
      'metrics': {
        'total_time_seconds': (totalTimeMs / 1000).round(),
        'moving_time_seconds': (movingTimeMs / 1000).round(),
        'elevation_gain': elevationGain,
        'elevation_loss': elevationLoss,
        'max_alt': maxAlt,
        'min_alt': minAlt,
      },
    };
  }

  /// Prepara el payload completo para sync_queue
  static Map<String, dynamic> buildSyncPayload({
    required List<TracePoint> points,
    String? excursionId,
    String? userId,
  }) {
    final compiled = compile(points);
    return {
      'track': {
        'user_id': userId,
        'geom': compiled['geojson'],
        ...compiled['metrics'] as Map<String, dynamic>,
      },
      'excursion_id': excursionId,
    };
  }

  static Map<String, dynamic> _emptyLineString() => {
    'type': 'LineString',
    'coordinates': <List<double>>[],
  };

  static Map<String, dynamic> _emptyMetrics() => {
    'total_time_seconds': 0,
    'moving_time_seconds': 0,
    'elevation_gain': 0.0,
    'elevation_loss': 0.0,
    'max_alt': 0.0,
    'min_alt': 0.0,
  };
}
