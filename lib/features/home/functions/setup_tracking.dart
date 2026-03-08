import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:saltamontes/core/di/injection.dart';
import 'package:saltamontes/core/services/location_service.dart';

///Este método se encarga de actualizar la cámara del mapa para que siga al usuario
void setupPositionTracking(MapboxMap controller) {
  sl<LocationService>().positionStream.listen((position) {
    controller.easeTo(
      CameraOptions(
        zoom: 12,
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
      ),
      MapAnimationOptions(duration: 500),
    );
  });
}
