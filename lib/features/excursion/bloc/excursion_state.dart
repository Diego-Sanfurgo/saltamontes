part of 'excursion_bloc.dart';

class ExcursionState extends Equatable {
  final bool isLoading;
  final List<Excursion> excursions;
  final int pendingSyncCount;
  final String? activeExcursionId;
  final String? error;

  const ExcursionState({
    this.isLoading = false,
    this.excursions = const [],
    this.pendingSyncCount = 0,
    this.activeExcursionId,
    this.error,
  });

  ExcursionState copyWith({
    bool? isLoading,
    List<Excursion>? excursions,
    int? pendingSyncCount,
    String? activeExcursionId,
    String? error,
  }) => ExcursionState(
    isLoading: isLoading ?? this.isLoading,
    excursions: excursions ?? this.excursions,
    pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    activeExcursionId: activeExcursionId ?? this.activeExcursionId,
    error: error,
  );

  @override
  List<Object?> get props => [
    isLoading,
    excursions,
    pendingSyncCount,
    activeExcursionId,
    error,
  ];
}
