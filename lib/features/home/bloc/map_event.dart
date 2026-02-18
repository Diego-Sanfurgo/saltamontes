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

  /// The type to toggle in the filter set (e.g. 'peak', 'lake').
  final String placeType;

  @override
  List<Object?> get props => [placeType];
}

class MapFilterAltitude extends MapEvent {
  MapFilterAltitude({this.min, this.max});

  final double? min;
  final double? max;

  @override
  List<Object?> get props => [min, max];
}

class MapClearFilters extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapSelectFeature extends MapEvent {
  MapSelectFeature(this.place);

  final Place place;

  @override
  List<Object?> get props => [place];
}

class MapDeselectFeature extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapZoomIn extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapZoomOut extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapFeatureTapped extends MapEvent {
  MapFeatureTapped(this.feature);

  final SelectedFeatureDTO feature;

  @override
  List<Object?> get props => [feature];
}
