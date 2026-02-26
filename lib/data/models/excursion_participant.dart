enum ParticipantStatus { pending, accepted, declined, attended }

ParticipantStatus _parseStatus(String? s) {
  switch (s) {
    case 'accepted':
      return ParticipantStatus.accepted;
    case 'declined':
      return ParticipantStatus.declined;
    case 'attended':
      return ParticipantStatus.attended;
    default:
      return ParticipantStatus.pending;
  }
}

class ExcursionParticipant {
  final String excursionId;
  final String userId;
  final ParticipantStatus status;
  final bool isOrganizer;

  const ExcursionParticipant({
    required this.excursionId,
    required this.userId,
    this.status = ParticipantStatus.pending,
    this.isOrganizer = false,
  });

  ExcursionParticipant copyWith({
    String? excursionId,
    String? userId,
    ParticipantStatus? status,
    bool? isOrganizer,
  }) => ExcursionParticipant(
    excursionId: excursionId ?? this.excursionId,
    userId: userId ?? this.userId,
    status: status ?? this.status,
    isOrganizer: isOrganizer ?? this.isOrganizer,
  );

  factory ExcursionParticipant.fromJson(Map<String, dynamic> json) =>
      ExcursionParticipant(
        excursionId: json['excursion_id'] as String,
        userId: json['user_id'] as String,
        status: _parseStatus(json['status'] as String?),
        isOrganizer: json['is_organizer'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
    'excursion_id': excursionId,
    'user_id': userId,
    'status': status.name,
    'is_organizer': isOrganizer,
  };
}
