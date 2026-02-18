part of 'map_bloc.dart';

@immutable
sealed class MapEvent extends Equatable {}

class MapCreated extends MapEvent {
  MapCreated(this.controller);

  final MapboxMap controller;

  @override
  List<Object?> get props => [controller];
}

class MapReload extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapCameraIdle extends MapEvent {
  MapCameraIdle(this.cameraState);

  final CameraState cameraState;

  @override
  List<Object?> get props => [cameraState];
}

class MapMoveCamera extends MapEvent {
  final double? zoomLevel;
  final LatLng? targetLocation;
  final List<LatLng>? coordinates;

  MapMoveCamera({this.zoomLevel, this.targetLocation, this.coordinates});

  @override
  List<Object?> get props => [zoomLevel, targetLocation, coordinates];
}

class MapChangeStyle extends MapEvent {
  MapChangeStyle(this.styleUri);

  final String styleUri;

  @override
  List<Object?> get props => [styleUri];
}

class MapToggleOverlay extends MapEvent {
  MapToggleOverlay(this.overlayId);

  final String overlayId;

  @override
  List<Object?> get props => [overlayId];
}

class MapFilterPlaces extends MapEvent {
  MapFilterPlaces(this.placeType);

  /// The type to filter by (e.g. 'peak', 'lake'). Null clears the filter.
  final String? placeType;

  @override
  List<Object?> get props => [placeType];
}

class MapSelectFeature extends MapEvent {
  MapSelectFeature(this.place);

  final Place place;

  @override
  List<Object?> get props => [place];
}
