part of 'map_bloc.dart';

@immutable
sealed class MapEvent extends Equatable {}

class MapCreated extends MapEvent {
  MapCreated(this.controller);

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

class MapDeselectFeature extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapZoom extends MapEvent {
  MapZoom(this.delta);

  final double delta;

  @override
  List<Object?> get props => [delta];
}

class MapSelectPlace extends MapEvent {
  MapSelectPlace({this.place, this.feature});

  final Place? place;
  final SelectedFeatureDTO? feature;

  @override
  List<Object?> get props => [place, feature];
}
