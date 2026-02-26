import 'dart:math' as math;

/// Calcula pendientes entre pares de coordenadas XYZM y asigna colores
/// verde→rojo según el desnivel. Diseñado para ejecutarse en un Isolate.
///
/// Entrada: Lista de coordenadas [lng, lat, alt, timestamp]
/// Salida: Lista de stops [offset, color] para line-gradient de Mapbox.
class SlopeCalculator {
  /// Top-level function para compute() en Isolate
  static List<Map<String, dynamic>> calculateGradientStops(
    List<List<double>> coordinates,
  ) {
    if (coordinates.length < 2) return [];

    final stops = <Map<String, dynamic>>[];
    final totalPoints = coordinates.length;

    for (int i = 0; i < totalPoints - 1; i++) {
      final curr = coordinates[i];
      final next = coordinates[i + 1];

      // Distancia horizontal (Haversine simplificado)
      final dx = _haversineDistance(
        curr[1],
        curr[0], // lat, lng
        next[1],
        next[0],
      );

      // Desnivel
      final dz =
          (next.length > 2 ? next[2] : 0) - (curr.length > 2 ? curr[2] : 0);

      // Pendiente (%) — clamp entre -50% y +50%
      double slope = 0;
      if (dx > 0) {
        slope = (dz / dx) * 100;
        slope = slope.clamp(-50, 50);
      }

      // Normalizar a [0, 1] donde 0 = -50% ↓ y 1 = +50% ↑
      final normalized = (slope + 50) / 100;

      // Color: verde (bajada suave) → amarillo → rojo (subida fuerte)
      final color = _slopeToColor(normalized);

      // Posición como fracción del total
      final offset = i / (totalPoints - 1).toDouble();

      stops.add({'offset': offset, 'color': color});
    }

    // Último punto
    if (stops.isNotEmpty) {
      stops.add({'offset': 1.0, 'color': stops.last['color']});
    }

    return stops;
  }

  /// Convierte valor normalizado [0,1] a color hexadecimal verde→amarillo→rojo
  static String _slopeToColor(double normalized) {
    // 0.0 = verde (bajada), 0.5 = amarillo (plano), 1.0 = rojo (subida)
    int r, g, b;

    if (normalized < 0.5) {
      // Verde → Amarillo
      final t = normalized * 2;
      r = (255 * t).round();
      g = 200;
      b = 50;
    } else {
      // Amarillo → Rojo
      final t = (normalized - 0.5) * 2;
      r = 255;
      g = (200 * (1 - t)).round();
      b = 50;
    }

    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// Haversine simplificado (retorna metros)
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0; // Radio de la Tierra en metros
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}
