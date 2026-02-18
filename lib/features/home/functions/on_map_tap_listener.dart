import 'dart:async'; // Necesario para StreamController

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:saltamontes/core/utils/normalize_map.dart';
import 'package:saltamontes/data/models/place.dart';
import 'package:saltamontes/features/home/dto/selected_feature_dto.dart';

Stream<SelectedFeatureDTO> addOnMapTapListener(
  MapboxMap controller,
  List<String> sourceBaseIDList,
) {
  final streamController = StreamController<SelectedFeatureDTO>();

  List<String> layerIDList = [];
  for (var sourceBaseID in sourceBaseIDList) {
    layerIDList.addAll(['$sourceBaseID-cluster', '$sourceBaseID-points']);
  }

  controller.setOnMapTapListener((MapContentGestureContext mapContext) async {
    final List<QueriedRenderedFeature?> features = await controller
        .queryRenderedFeatures(
          RenderedQueryGeometry.fromScreenCoordinate(mapContext.touchPosition),
          RenderedQueryOptions(layerIds: layerIDList, filter: null),
        );

    if (features.isEmpty) return;

    final QueriedRenderedFeature? feature = features.first;
    final rawFeature = feature!.queriedFeature.feature;
    final List<String> layerStrings = feature.layers.single!.split('-');

    double zoom = 14.5;
    final bool isCluster = layerStrings.contains('cluster');
    final String sourceIDSelected = '${layerStrings.first}-source';

    final PlaceGeometry geometry = PlaceGeometry.fromFeature(rawFeature);

    if (isCluster) {
      // Obtenemos el zoom actual
      final CameraState cameraState = await controller.getCameraState();
      final double currentZoom = cameraState.zoom;
      zoom = currentZoom + 2.0;
      if (zoom > 15.5) zoom = 15.5;

      await controller.easeTo(
        CameraOptions(center: geometry.toMapboxPoint(), zoom: zoom),
        MapAnimationOptions(duration: 500),
      );
    }

    final normalizedMap = normalizeMap(rawFeature);

    streamController.add(
      SelectedFeatureDTO(
        featureId: isCluster ? '' : normalizedMap['properties']['id'],
        isCluster: isCluster,
        sourceID: sourceIDSelected,
        type: normalizedMap['properties']['type'],
        lat: geometry.coordinates.latitude,
        lng: geometry.coordinates.longitude,
      ),
    );
  });

  // Retornamos el stream para que el Bloc pueda escucharlo
  return streamController.stream;
}

Future<void> handleClusterTap(
  MapboxMap controller,
  ScreenCoordinate screenCoordinate,
) async {
  // 1. Consultar qué hay en el punto tocado
  final List<QueriedRenderedFeature?> features = await controller
      .queryRenderedFeatures(
        RenderedQueryGeometry.fromScreenCoordinate(screenCoordinate),
        RenderedQueryOptions(
          layerIds: ['places-layer'], // El ID definido en LayerService
          filter: null,
        ),
      );

  if (features.isEmpty) return;

  final QueriedRenderedFeature feature = features.first!;
  final rawFeature = feature.queriedFeature.feature;
  // final Object? properties = feature.queriedFeature.feature['properties'];
  if (rawFeature.isEmpty) return;

  final Map<String, dynamic> normalizedMap = normalizeMap(rawFeature);

  // 2. Verificar si es un Cluster
  // Nota: point_count viene del SQL. Asegúrate de leerlo como numérico.
  final int pointCount = normalizedMap['point_count'] is int
      ? normalizedMap['point_count']
      : int.tryParse(normalizedMap['point_count'].toString()) ?? 1;

  if (pointCount > 1) {
    // === ES UN CLUSTER ===

    // Obtenemos la geometría del centro del cluster
    // final geometry = feature.queriedFeature.feature['geometry'];
    // final geometry = feature.queriedFeature.feature['geometry'];
    final List<dynamic> coordinates = normalizedMap['geometry']['coordinates'];
    final double lng = coordinates[0];
    final double lat = coordinates[1];

    // Obtenemos el zoom actual
    final CameraState cameraState = await controller.getCameraState();
    final double currentZoom = cameraState.zoom;

    // 3. Calcular Zoom Objetivo
    // Saltamos 2 niveles para romper el cluster.
    // Topeamos en 16 (o 15) donde tu SQL ya deja de agrupar.
    double targetZoom = currentZoom + 2.0;
    if (targetZoom > 15.5) targetZoom = 15.5;

    // 4. Mover la Cámara
    await controller.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: targetZoom,
      ),
      MapAnimationOptions(duration: 500, startDelay: 0),
    );

    // Detenemos aquí para no procesar el tap como "selección de punto individual"
    return;
  }

  // === ES UN PUNTO INDIVIDUAL ===
  // Aquí continúa tu lógica normal de seleccionar el lugar, mostrar BottomSheet, etc.
  // ...
}
