import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

/// Servicio de localización GPS global.
///
/// Proporciona un stream de posiciones y la última posición conocida.
/// Inyectado como lazy singleton — no usa BuildContext.
@lazySingleton
class LocationService {
  // Última ubicación conocida
  Position? lastPosition;

  // StreamController que emite actualizaciones
  final StreamController<Position> _positionController =
      StreamController.broadcast();

  // Exponer stream global
  Stream<Position> get positionStream => _positionController.stream;

  StreamSubscription<Position>? _subscription;

  // Inicializar el servicio
  @PostConstruct(preResolve: true)
  Future<void> init() async {
    final hasPermission = await _ensurePermissions();
    if (!hasPermission) return;

    // Obtener la última ubicación inicial
    lastPosition =
        await Geolocator.getLastKnownPosition() ??
        await Geolocator.getCurrentPosition();

    // Empezamos a escuchar el stream del GPS
    _subscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, // cada 5 metros envía update
          ),
        ).listen((Position pos) {
          lastPosition = pos;
          _positionController.add(pos);
        });
  }

  // Permisos
  Future<bool> _ensurePermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Liberar recursos
  @disposeMethod
  void dispose() {
    _subscription?.cancel();
    _positionController.close();
  }
}
