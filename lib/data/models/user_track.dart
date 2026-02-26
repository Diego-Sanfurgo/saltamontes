class UserTrack {
  final String id;
  final String? userId;
  final Map<String, dynamic> geom; // GeoJSON geometry
  final Map<String, dynamic>? bbox; // GeoJSON bounding box
  final int totalTimeSeconds;
  final int movingTimeSeconds;
  final double elevationGain;
  final double elevationLoss;
  final double? maxAlt;
  final double? minAlt;
  final DateTime? createdAt;

  const UserTrack({
    required this.id,
    this.userId,
    required this.geom,
    this.bbox,
    required this.totalTimeSeconds,
    required this.movingTimeSeconds,
    required this.elevationGain,
    required this.elevationLoss,
    this.maxAlt,
    this.minAlt,
    this.createdAt,
  });

  UserTrack copyWith({
    String? id,
    String? userId,
    Map<String, dynamic>? geom,
    Map<String, dynamic>? bbox,
    int? totalTimeSeconds,
    int? movingTimeSeconds,
    double? elevationGain,
    double? elevationLoss,
    double? maxAlt,
    double? minAlt,
    DateTime? createdAt,
  }) => UserTrack(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    geom: geom ?? this.geom,
    bbox: bbox ?? this.bbox,
    totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
    movingTimeSeconds: movingTimeSeconds ?? this.movingTimeSeconds,
    elevationGain: elevationGain ?? this.elevationGain,
    elevationLoss: elevationLoss ?? this.elevationLoss,
    maxAlt: maxAlt ?? this.maxAlt,
    minAlt: minAlt ?? this.minAlt,
    createdAt: createdAt ?? this.createdAt,
  );

  factory UserTrack.fromJson(Map<String, dynamic> json) => UserTrack(
    id: json['id'] as String,
    userId: json['user_id'] as String?,
    geom: json['geom'] is Map ? json['geom'] as Map<String, dynamic> : {},
    bbox: json['bbox'] is Map ? json['bbox'] as Map<String, dynamic> : null,
    totalTimeSeconds: (json['total_time_seconds'] as num).toInt(),
    movingTimeSeconds: (json['moving_time_seconds'] as num).toInt(),
    elevationGain: (json['elevation_gain'] as num).toDouble(),
    elevationLoss: (json['elevation_loss'] as num).toDouble(),
    maxAlt: json['max_alt'] != null
        ? (json['max_alt'] as num).toDouble()
        : null,
    minAlt: json['min_alt'] != null
        ? (json['min_alt'] as num).toDouble()
        : null,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'geom': geom,
    'bbox': bbox,
    'total_time_seconds': totalTimeSeconds,
    'moving_time_seconds': movingTimeSeconds,
    'elevation_gain': elevationGain,
    'elevation_loss': elevationLoss,
    'max_alt': maxAlt,
    'min_alt': minAlt,
    'created_at': createdAt?.toIso8601String(),
  };

  /// Formato resumido para mostrar métricas en la UI
  String get formattedDuration {
    final h = totalTimeSeconds ~/ 3600;
    final m = (totalTimeSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String get formattedElevation =>
      '+${elevationGain.round()}m / -${elevationLoss.round()}m';
}
