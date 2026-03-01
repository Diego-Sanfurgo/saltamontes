part of 'map_bloc.dart';

@immutable
sealed class MapEvent extends Equatable {}

/// Evento interno disparado cuando el [MapControllerProvider] notifica
/// un nuevo controller.
class _MapControllerReady extends MapEvent {
  _MapControllerReady(this.controller);

  final MapboxMap controller;

  @override
  List<Object?> get props => [controller];
}

class MapStarted extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapMoveCamera extends MapEvent {
  final double? zoomLevel;
  final LatLng? targetLocation;
  final List<LatLng>? coordinates;

  MapMoveCamera({this.zoomLevel, this.targetLocation, this.coordinates});

  @override
  List<Object?> get props => [zoomLevel, targetLocation, coordinates];
}

class MapDeselectFeature extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapSelectPlace extends MapEvent {
  MapSelectPlace({this.place, this.feature});

  final Place? place;
  final SelectedFeatureDTO? feature;

  @override
  List<Object?> get props => [place, feature];
}

class MapShowTrackOverlay extends MapEvent {
  final Map<String, dynamic> geojson;
  MapShowTrackOverlay(this.geojson);
  @override
  List<Object?> get props => [geojson];
}

class MapClearTrackOverlay extends MapEvent {
  @override
  List<Object?> get props => [];
}
