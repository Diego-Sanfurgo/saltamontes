part of 'location_cubit.dart';

/// Modos de cámara para el seguimiento de ubicación.
enum CameraMode { free, following, compass }

class LocationState extends Equatable {
  final CameraMode cameraMode;
  final PuckBearing puckBearing;

  const LocationState({
    this.cameraMode = CameraMode.free,
    this.puckBearing = PuckBearing.HEADING,
  });

  LocationState copyWith({CameraMode? cameraMode, PuckBearing? puckBearing}) {
    return LocationState(
      cameraMode: cameraMode ?? this.cameraMode,
      puckBearing: puckBearing ?? this.puckBearing,
    );
  }

  /// Retorna el ViewportState según el modo de cámara actual.
  ViewportState toViewportState({double? currentZoom}) {
    switch (cameraMode) {
      case CameraMode.free:
        return IdleViewportState();
      case CameraMode.following:
        return FollowPuckViewportState(
          zoom: 14.0,
          bearing: FollowPuckViewportStateBearingConstant(0),
          pitch: 0,
        );
      case CameraMode.compass:
        return FollowPuckViewportState(
          zoom: currentZoom,
          bearing: FollowPuckViewportStateBearingHeading(),
          pitch: 45.0,
        );
    }
  }

  @override
  List<Object?> get props => [cameraMode, puckBearing];
}
