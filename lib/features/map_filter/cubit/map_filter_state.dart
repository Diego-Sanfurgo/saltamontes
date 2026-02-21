part of 'map_filter_cubit.dart';

class MapFilterState extends Equatable {
  const MapFilterState({
    this.placeTypeFilter = const {},
    this.altitudeMin,
    this.altitudeMax,
  });

  final Set<String> placeTypeFilter;
  final double? altitudeMin;
  final double? altitudeMax;

  MapFilterState copyWith({
    Set<String>? placeTypeFilter,
    double? Function()? altitudeMin,
    double? Function()? altitudeMax,
  }) {
    return MapFilterState(
      placeTypeFilter: placeTypeFilter ?? this.placeTypeFilter,
      altitudeMin: altitudeMin != null ? altitudeMin() : this.altitudeMin,
      altitudeMax: altitudeMax != null ? altitudeMax() : this.altitudeMax,
    );
  }

  bool get hasActiveFilters =>
      placeTypeFilter.isNotEmpty || altitudeMin != null || altitudeMax != null;

  @override
  List<Object?> get props => [placeTypeFilter, altitudeMin, altitudeMax];
}
