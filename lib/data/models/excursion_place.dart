//TODO: Este objeto deberia venir incustado dentro de Excursion
class ExcursionPlace {
  final String excursionId;
  final String placeId;
  final DateTime? visitedAt;

  const ExcursionPlace({
    required this.excursionId,
    required this.placeId,
    this.visitedAt,
  });

  factory ExcursionPlace.fromJson(Map<String, dynamic> json) => ExcursionPlace(
    excursionId: json['excursion_id'] as String,
    placeId: json['place_id'] as String,
    visitedAt: json['visited_at'] != null
        ? DateTime.parse(json['visited_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'excursion_id': excursionId,
    'place_id': placeId,
    'visited_at': visitedAt?.toIso8601String(),
  };
}
