part of 'map_bloc.dart';

enum MapStatus { initial, loading, loaded, error }

class MapState extends Equatable {
  final MapStatus status;
  final List<Place> places;
  final Place? selectedPlace;
  final bool isLoadingPlace;

  const MapState({
    this.status = MapStatus.initial,
    this.places = const [],
    this.selectedPlace,
    this.isLoadingPlace = false,
  });

  MapState copyWith({
    MapStatus? status,
    List<Place>? places,
    Place? Function()? selectedPlace,
    bool? isLoadingPlace,
  }) {
    return MapState(
      status: status ?? this.status,
      places: places ?? this.places,
      selectedPlace: selectedPlace != null
          ? selectedPlace()
          : this.selectedPlace,
      isLoadingPlace: isLoadingPlace ?? this.isLoadingPlace,
    );
  }

  @override
  List<Object?> get props => [status, places, selectedPlace, isLoadingPlace];
}
