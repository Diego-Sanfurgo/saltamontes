part of 'map_bloc.dart';

enum MapStatus { initial, loading, loaded, error }

class MapState extends Equatable {
  final MapStatus status;
  final List<Place> places;
  final Set<String> placeTypeFilter;
  final double? altitudeMin;
  final double? altitudeMax;
  final Place? selectedPlace;
  final bool isLoadingPlace;

  const MapState({
    this.status = MapStatus.initial,
    this.places = const [],
    this.placeTypeFilter = const {},
    this.altitudeMin,
    this.altitudeMax,
    this.selectedPlace,
    this.isLoadingPlace = false,
  });

  bool get hasActiveFilters =>
      placeTypeFilter.isNotEmpty || altitudeMin != null || altitudeMax != null;

  MapState copyWith({
    MapStatus? status,
    List<Place>? places,
    Set<String>? placeTypeFilter,
    double? Function()? altitudeMin,
    double? Function()? altitudeMax,
    Place? Function()? selectedPlace,
    bool? isLoadingPlace,
  }) {
    return MapState(
      status: status ?? this.status,
      places: places ?? this.places,
      placeTypeFilter: placeTypeFilter ?? this.placeTypeFilter,
      altitudeMin: altitudeMin != null ? altitudeMin() : this.altitudeMin,
      altitudeMax: altitudeMax != null ? altitudeMax() : this.altitudeMax,
      selectedPlace: selectedPlace != null
          ? selectedPlace()
          : this.selectedPlace,
      isLoadingPlace: isLoadingPlace ?? this.isLoadingPlace,
    );
  }

  @override
  List<Object?> get props => [
    status,
    places,
    placeTypeFilter,
    altitudeMin,
    altitudeMax,
    selectedPlace,
    isLoadingPlace,
  ];
}
