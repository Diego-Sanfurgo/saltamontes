import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:saltamontes/data/models/trace_point.dart';
import 'package:saltamontes/core/utils/constant_and_variables.dart';

Future<void> updateMapTrack(
  List<TracePoint> tracePointList,
  MapboxMap? controller,
) async {
  if (controller == null || tracePointList.isEmpty) return;

  // 1. Convertir tus puntos al formato de Mapbox (Position: [lng, lat])
  // Recuerda: Mapbox usa Longitud, Latitud.
  List<Position> coords = tracePointList
      .map((p) => Position(p.lon, p.lat)) // Ojo al orden
      .toList();

  // 2. Crear la estructura GeoJSON
  // En el SDK v10+ se pasa el objeto Feature o la data serializada
  var newData = Feature(
    id: MapConstants.trackingFeatureID,
    geometry: LineString(coordinates: coords),
  );

  // 3. Actualizar la fuente existente
  // El truco en Flutter es "recuperar" la fuente y actualizar su data
  await controller.style.setStyleSourceProperty(
    MapConstants.trackingSourceID,
    "data",
    newData.toJson(),
  );
}
