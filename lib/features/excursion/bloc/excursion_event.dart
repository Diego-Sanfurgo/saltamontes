part of 'excursion_bloc.dart';

abstract class ExcursionEvent extends Equatable {
  const ExcursionEvent();
  @override
  List<Object?> get props => [];
}

class LoadExcursions extends ExcursionEvent {}

class CreateQuickExcursion extends ExcursionEvent {}

class CreateScheduledExcursion extends ExcursionEvent {
  final String title;
  final String? description;
  final DateTime scheduledStart;
  final bool isPublic;
  final String? plannedTrackId;

  const CreateScheduledExcursion({
    required this.title,
    this.description,
    required this.scheduledStart,
    required this.isPublic,
    this.plannedTrackId,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    scheduledStart,
    isPublic,
    plannedTrackId,
  ];
}

class RetrySyncItem extends ExcursionEvent {
  final String syncItemId;
  const RetrySyncItem(this.syncItemId);
  @override
  List<Object?> get props => [syncItemId];
}
