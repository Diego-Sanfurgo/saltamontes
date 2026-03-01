import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:saltamontes/core/services/location_service.dart';
import 'package:saltamontes/data/providers/map_controller_provider.dart';

part 'location_state.dart';

/// Cubit que gestiona el seguimiento de cámara y la orientación del mapa.
///
/// Utiliza la API de Viewport de Mapbox para delegar el control de la cámara
/// al SDK nativo, evitando conflictos de animación y lecturas manuales de sensores.
class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this._mapControllerProvider) : super(const LocationState()) {
    _mapControllerProvider.addListener(_onControllerChanged);
    _mapControllerProvider.onUserInteraction = onUserInteracted;
    _controller = _mapControllerProvider.controller;
    if (_controller != null) _initLocationSubscription();
  }

  final MapControllerProvider _mapControllerProvider;
  MapboxMap? _controller;
  final LocationService _locationService = LocationService.instance;
  StreamSubscription<geo.Position>? _locationSubscription;

  /// Umbral de velocidad baja (km/h) — debajo usa magnetómetro (HEADING).
  static const double _speedThresholdLow = 3.0;

  /// Umbral de velocidad alta (km/h) — encima usa trayectoria GPS (COURSE).
  static const double _speedThresholdHigh = 5.0;

  void _onControllerChanged() {
    _controller = _mapControllerProvider.controller;
    if (_controller != null) _initLocationSubscription();
  }

  void _initLocationSubscription() {
    _locationSubscription?.cancel();
    _locationSubscription = _locationService.positionStream.listen(
      _onLocationUpdated,
    );
  }

  /// Activa el seguimiento con brújula (heading) vía Viewport API.
  void enableTrackingAndHeading() async {
    if (_controller == null) return;

    _updatePuckBearing(PuckBearing.HEADING);

    // Leer zoom actual para mantenerlo en modo compass
    double? currentZoom;
    try {
      final camera = await _controller!.getCameraState();
      currentZoom = camera.zoom;
    } catch (_) {}

    emit(state.copyWith(cameraMode: CameraMode.compass));
    _pushViewport(currentZoom: currentZoom);
  }

  /// Fuerza re-centrado emitiendo free->following.
  void _recenterFollowing() {
    emit(state.copyWith(cameraMode: CameraMode.free));
    _pushViewport();
    emit(state.copyWith(cameraMode: CameraMode.following));
    _pushViewport();
  }

  /// Interrupción por gesto del usuario — vuelve a modo libre.
  void onUserInteracted() {
    if (state.cameraMode != CameraMode.free) {
      emit(state.copyWith(cameraMode: CameraMode.free));
      _pushViewport();
    }
  }

  /// Ciclo de modos: free → following → compass → free.
  /// Tocar en following re-centra a zoom 14.
  void toggleTracking() {
    if (_controller == null) return;

    final currentMode = state.cameraMode;

    switch (currentMode) {
      case CameraMode.free:
        emit(state.copyWith(cameraMode: CameraMode.following));
        _pushViewport();
        break;
      case CameraMode.following:
        // Re-centrar a zoom 14 y luego pasar a compass
        _recenterFollowing();
        enableTrackingAndHeading();
        break;
      case CameraMode.compass:
        emit(state.copyWith(cameraMode: CameraMode.following));
        _pushViewport();
        break;
    }
  }

  /// Notifica al widget del mapa que debe animar un cambio de viewport.
  void _pushViewport({double? currentZoom}) {
    final vp = state.toViewportState(currentZoom: currentZoom);
    _mapControllerProvider.requestViewport(
      vp,
      transition: DefaultViewportTransition(
        maxDuration: Duration(milliseconds: 500),
      ),
    );
  }

  /// Smart Toggle: evalúa velocidad para decidir PuckBearing.
  ///
  /// - < 3 km/h → HEADING (magnetómetro, ideal para usuario detenido/caminando)
  /// - > 5 km/h → COURSE (GPS, evita jittering magnético en movimiento)
  /// - 3-5 km/h → zona muerta, sin cambio (evita oscilaciones)
  void _onLocationUpdated(geo.Position position) {
    if (_controller == null || state.cameraMode != CameraMode.compass) return;

    final speedKmh = position.speed * 3.6; // m/s → km/h

    if (speedKmh < _speedThresholdLow &&
        state.puckBearing != PuckBearing.HEADING) {
      _updatePuckBearing(PuckBearing.HEADING);
    } else if (speedKmh > _speedThresholdHigh &&
        state.puckBearing != PuckBearing.COURSE) {
      _updatePuckBearing(PuckBearing.COURSE);
    }
  }

  /// Actualiza el PuckBearing en el SDK nativo y en el estado.
  void _updatePuckBearing(PuckBearing bearing) {
    _controller?.location.updateSettings(
      LocationComponentSettings(
        puckBearing: bearing,
        puckBearingEnabled: bearing == PuckBearing.HEADING,
      ),
    );
    emit(state.copyWith(puckBearing: bearing));
  }

  @override
  Future<void> close() {
    _mapControllerProvider.removeListener(_onControllerChanged);
    if (_mapControllerProvider.onUserInteraction == onUserInteracted) {
      _mapControllerProvider.onUserInteraction = null;
    }
    _locationSubscription?.cancel();
    return super.close();
  }
}
