part of 'map_bloc.dart';

enum MapStatus { initial, loading, loaded, error }

class MapState extends Equatable {
  final MapStatus status;
  final List<Place> places;
  final String styleUri;
  final Set<String> activeOverlays;
  final Set<String> placeTypeFilter;
  final double? altitudeMin;
  final double? altitudeMax;
  final Place? selectedPlace;
  final bool isLoadingPlace;

  const MapState({
    this.status = MapStatus.initial,
    this.places = const [],
    this.styleUri = MapboxStyles.OUTDOORS,
    this.activeOverlays = const {},
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
    String? styleUri,
    Set<String>? activeOverlays,
    Set<String>? placeTypeFilter,
    double? Function()? altitudeMin,
    double? Function()? altitudeMax,
    Place? Function()? selectedPlace,
    bool? isLoadingPlace,
  }) {
    return MapState(
      status: status ?? this.status,
      places: places ?? this.places,
      styleUri: styleUri ?? this.styleUri,
      activeOverlays: activeOverlays ?? this.activeOverlays,
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
    styleUri,
    activeOverlays,
    placeTypeFilter,
    altitudeMin,
    altitudeMax,
    selectedPlace,
    isLoadingPlace,
  ];
}
