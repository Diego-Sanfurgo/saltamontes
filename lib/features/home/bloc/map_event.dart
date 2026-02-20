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

class MapFilter extends MapEvent {
  MapFilter({this.togglePlaceType, this.minAlt, this.maxAlt});

  /// The type to toggle in the filter set (e.g. 'peak', 'lake').
  final String? togglePlaceType;
  final double? minAlt;
  final double? maxAlt;

  @override
  List<Object?> get props => [togglePlaceType, minAlt, maxAlt];
}

class MapClearFilters extends MapEvent {
  @override
  List<Object?> get props => [];
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
