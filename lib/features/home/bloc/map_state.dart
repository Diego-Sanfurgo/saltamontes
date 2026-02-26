part of 'map_bloc.dart';

enum MapStatus { initial, loading, loaded, error }

class MapState extends Equatable {
  final MapStatus status;
  final List<Place> places;
  final Place? selectedPlace;
  final bool isLoadingPlace;
  final Map<String, dynamic>? trackOverlayGeoJson;

  const MapState({
    this.status = MapStatus.initial,
    this.places = const [],
    this.selectedPlace,
    this.isLoadingPlace = false,
    this.trackOverlayGeoJson,
  });

  MapState copyWith({
    MapStatus? status,
    List<Place>? places,
    Place? Function()? selectedPlace,
    bool? isLoadingPlace,
    Map<String, dynamic>? Function()? trackOverlayGeoJson,
  }) {
    return MapState(
      status: status ?? this.status,
      places: places ?? this.places,
      selectedPlace: selectedPlace != null
          ? selectedPlace()
          : this.selectedPlace,
      isLoadingPlace: isLoadingPlace ?? this.isLoadingPlace,
      trackOverlayGeoJson: trackOverlayGeoJson != null
          ? trackOverlayGeoJson()
          : this.trackOverlayGeoJson,
    );
  }

  @override
  List<Object?> get props => [
    status,
    places,
    selectedPlace,
    isLoadingPlace,
    trackOverlayGeoJson,
  ];
}
