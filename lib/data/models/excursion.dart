class Excursion {
  final String id;
  final String? ownerId;
  final String title;
  final String? description;
  final bool isPublic;
  final DateTime scheduledStart;
  final String? plannedTrackId;
  final String? recordedTrackId;
  final String? inviteToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Excursion({
    required this.id,
    this.ownerId,
    required this.title,
    this.description,
    this.isPublic = false,
    required this.scheduledStart,
    this.plannedTrackId,
    this.recordedTrackId,
    this.inviteToken,
    this.createdAt,
    this.updatedAt,
  });

  Excursion copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    bool? isPublic,
    DateTime? scheduledStart,
    String? plannedTrackId,
    String? recordedTrackId,
    String? inviteToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Excursion(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    title: title ?? this.title,
    description: description ?? this.description,
    isPublic: isPublic ?? this.isPublic,
    scheduledStart: scheduledStart ?? this.scheduledStart,
    plannedTrackId: plannedTrackId ?? this.plannedTrackId,
    recordedTrackId: recordedTrackId ?? this.recordedTrackId,
    inviteToken: inviteToken ?? this.inviteToken,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Excursion.fromJson(Map<String, dynamic> json) => Excursion(
    id: json['id'] as String,
    ownerId: json['owner_id'] as String?,
    title: json['title'] as String,
    description: json['description'] as String?,
    isPublic: json['is_public'] as bool? ?? false,
    scheduledStart: DateTime.parse(json['scheduled_start'] as String),
    plannedTrackId: json['planned_track_id'] as String?,
    recordedTrackId: json['recorded_track_id'] as String?,
    inviteToken: json['invite_token'] as String?,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'owner_id': ownerId,
    'title': title,
    'description': description,
    'is_public': isPublic,
    'scheduled_start': scheduledStart.toIso8601String(),
    'planned_track_id': plannedTrackId,
    'recorded_track_id': recordedTrackId,
    'invite_token': inviteToken,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  /// Carga mínima para crear draft (Excursión Rápida)
  Map<String, dynamic> toDraftInsert() => {
    'title': title,
    'owner_id': ownerId,
    'is_public': false,
    'scheduled_start': scheduledStart.toIso8601String(),
  };

  /// Carga completa para Excursión Programada
  Map<String, dynamic> toScheduledInsert() => {
    'title': title,
    'owner_id': ownerId,
    'description': description,
    'is_public': isPublic,
    'scheduled_start': scheduledStart.toIso8601String(),
    if (plannedTrackId != null) 'planned_track_id': plannedTrackId,
  };
}
