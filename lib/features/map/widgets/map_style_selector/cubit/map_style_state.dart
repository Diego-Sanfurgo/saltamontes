part of 'map_style_cubit.dart';

class MapStyleState extends Equatable {
  final String styleUri;
  final Set<String> activeOverlays;

  const MapStyleState({
    this.styleUri = MapboxStyles.OUTDOORS,
    this.activeOverlays = const {},
  });

  MapStyleState copyWith({String? styleUri, Set<String>? activeOverlays}) {
    return MapStyleState(
      styleUri: styleUri ?? this.styleUri,
      activeOverlays: activeOverlays ?? this.activeOverlays,
    );
  }

  @override
  List<Object?> get props => [styleUri, activeOverlays];
}
