import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:saltamontes/core/theme/colors.dart';
import 'package:saltamontes/core/utils/constant_and_variables.dart';

import 'image_service.dart';

class LayerService {
  static Future<void> addPlacesSource(MapboxMap mapboxMap) async {
    if (!await _ensureStyleIsLoaded(mapboxMap)) return;

    const String sourceID = MapConstants.placesSourceID;

    // 1. Cargar imágenes para cada tipo de punto
    const List<String> placeTypes = [
      MapConstants.lakeID,
      MapConstants.mountainPassID,
      MapConstants.peakID,
      MapConstants.waterfallID,
    ];
    for (final String type in placeTypes) {
      await addPlaceImageToStyle(mapboxMap, type);
    }

    // 2. Fuente
    // Verificar si ya existe para evitar errores en Hot Reload
    if (!await mapboxMap.style.styleSourceExists(sourceID)) {
      await mapboxMap.style.addSource(
        VectorSource(
          id: sourceID,
          tiles: [MapConstants.placesMVT],
          minzoom: 5,
          maxzoom: 40,
        ),
      );
    }

    const String clusterLayerID = MapConstants.placesClusterLayerID;
    const String countLayerID = MapConstants.placesCountLayerID;
    const String pointsLayerID = MapConstants.placesPointsLayerID;

    // 3. Agregar Capa con lógica de Cluster
    if (!await mapboxMap.style.styleLayerExists(clusterLayerID)) {
      await mapboxMap.style.addLayer(
        CircleLayer(
          id: clusterLayerID,
          sourceId: sourceID,
          sourceLayer: MapConstants.placesSourceLayerID,
          filter: [
            ">",
            ["get", "point_count"],
            1,
          ],
          circleRadius: 18.0,
          circleColor: AppColors.accentColor.toARGB32(),
          circleStrokeWidth: 2.0,
          circleStrokeColor: Colors.white.toARGB32(),
        ),
      );
    }

    // 4. Agregar Texto con el conteo del cluster
    if (!await mapboxMap.style.styleLayerExists(countLayerID)) {
      await mapboxMap.style.addLayer(
        SymbolLayer(
          id: countLayerID,
          sourceId: sourceID,
          sourceLayer: MapConstants.placesSourceLayerID,
          filter: [
            ">",
            ["get", "point_count"],
            1,
          ],
          textFieldExpression: [
            "to-string",
            ["get", "point_count"],
          ],
          textSize: 12.0,
          textColor: Colors.white.toARGB32(),
          textIgnorePlacement: true,
          textAllowOverlap: true,
        ),
      );
    }

    // 5. Agregar SymbolLayer para puntos individuales
    if (!await mapboxMap.style.styleLayerExists(pointsLayerID)) {
      await mapboxMap.style.addLayer(
        SymbolLayer(
          id: pointsLayerID,
          sourceId: sourceID,
          sourceLayer: MapConstants.placesSourceLayerID,
          // Filtro inverso al cluster: muestra puntos donde point_count NO es > 1
          filter: [
            "!",
            [
              ">",
              [
                "coalesce",
                ["get", "point_count"],
                0,
              ],
              1,
            ],
          ],
          // Icono dinámico basado en el tipo de punto
          iconImageExpression: [
            "concat",
            ["get", "type"],
            "-marker",
          ],
          iconSize: 0.4,
          iconHaloColor: Colors.white.toARGB32(),
          iconHaloWidth: 2,
          textOffset: [0, 3],
          textColor: Colors.black.toARGB32(),
          textSize: 14.0,
          textHaloColor: Colors.white.toARGB32(),
          textHaloWidth: 1.5,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          // feature-state:selected para gestionar interacciones
          iconSizeExpression: [
            "case",
            [
              "boolean",
              ["feature-state", "selected"],
              false,
            ],
            2.5, // Selected size
            1.0, // Normal size
          ],
        ),
      );

      // Texto dinámico: nombre + altura (si existe)
      await mapboxMap.style.setStyleLayerProperty(pointsLayerID, 'text-field', [
        "case",
        ["has", "alt"],
        [
          "concat",
          ["get", "name"],
          "\n",
          ["get", "alt"],
          "m",
        ],
        ["get", "name"],
      ]);
    }
  }

  static Future<void> addTrackingLayer(
    MapboxMap controller,
    String geoJson,
    String sourceBaseID,
  ) async {
    final String sourceID = '$sourceBaseID-source';

    if (!await _ensureStyleIsLoaded(controller)) return;

    // Add Source
    if (!await controller.style.styleSourceExists(sourceID)) {
      await controller.style.addSource(
        GeoJsonSource(id: sourceID, data: geoJson, cluster: false),
      );
    }

    // Line Layer
    final String lineLayerID = '$sourceBaseID-line';
    if (!await controller.style.styleLayerExists(lineLayerID)) {
      // 2. Crear la capa de línea conectada a esa fuente
      final LineLayer layer = LineLayer(
        id: lineLayerID,
        sourceId: sourceID,
        lineWidth: 5.0,
        lineColor: AppColors.accentColor
            .toARGB32(), // O el color hexadecimal en int
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
      );
      await controller.style.addLayer(layer);
    }
  }

  /// Carga una imagen para un tipo de lugar específico (lake, pass, peak, waterfall)
  static Future<void> addPlaceImageToStyle(
    MapboxMap controller,
    String placeType,
  ) async {
    final String imageName = '$placeType-marker';

    try {
      if (await controller.style.hasStyleImage(imageName)) return;

      if (!await _ensureStyleIsLoaded(controller)) return;

      final SizedImage imageBytes = await ImageService.loadSizedImage(
        _getAssetPath(placeType),
      );

      await controller.style.addStyleImage(
        imageName,
        1.2,
        MbxImage(
          width: imageBytes.width,
          height: imageBytes.height,
          data: imageBytes.data,
        ),
        false,
        [],
        [],
        null,
      );

      log("✅ Place image added to style: $imageName");
    } catch (e) {
      log("❌ Error adding place image $imageName: $e");
    }
  }

  static Future<void> addMountainAreaAll(MapboxMap controller) async {
    const String sourceId = MapConstants.mountainsSourceID;
    const String layerId = MapConstants.mountainsLayerID;

    await controller.style.addSource(
      VectorSource(
        id: sourceId,
        tiles: [MapConstants.mountainAreasMVT], // Correcto: Lista de templates
        maxzoom: 22,
      ),
    );

    // Add layers below the places layers so points render on top
    await controller.style.addLayerAt(
      LineLayer(
        id: MapConstants.mountainsLineLayerID,
        sourceId: sourceId,
        sourceLayer: MapConstants.mountainsSourceLayerID,
        lineColor: Colors.black.toARGB32(),
        lineWidth: .05,
        lineOpacity: 1.0,
      ),
      LayerPosition(below: MapConstants.placesClusterLayerID),
    );

    // 2. Añadir Capa
    await controller.style.addLayerAt(
      FillLayer(
        id: layerId,
        sourceId: sourceId,
        sourceLayer: MapConstants.mountainsSourceLayerID,
        fillColor: Colors.blue.toARGB32(),
        fillOpacity: 0.4,
        fillOutlineColor: Colors.green[900]!.toARGB32(),
      ),
      LayerPosition(below: MapConstants.mountainsLineLayerID),
    );
  }

  /// Removes an overlay by removing its [layerIds] first, then the [sourceId].
  static Future<void> removeOverlay(
    MapboxMap controller,
    String sourceId,
    List<String> layerIds,
  ) async {
    for (final layerId in layerIds) {
      if (await controller.style.styleLayerExists(layerId)) {
        await controller.style.removeStyleLayer(layerId);
      }
    }
    if (await controller.style.styleSourceExists(sourceId)) {
      await controller.style.removeStyleSource(sourceId);
    }
  }

  static Future<void> filterFeatureArea(
    MapboxMap controller,
    String featureType,
    List<String> featureIds,
  ) async {
    final layerInfo = _getLayerIdsForType(featureType);

    if (layerInfo == null) {
      log("⚠️ No layer configuration found for feature type: $featureType");
      return;
    }

    // Ensure the layer is added (e.g., mountains)
    if (featureType == MapConstants.peakID) {
      await addMountainAreaAll(controller);
    }

    final filter = [
      "in",
      ["get", "place_id"], // Campo en el MVT
      ["literal", featureIds],
    ];

    await controller.style.setStyleLayerProperties(
      layerInfo.fillLayerId,
      jsonEncode({"filter": filter, "fill-color": "#729B79"}),
    );

    // Also filter and style the line layer for selection
    await controller.style.setStyleLayerProperties(
      layerInfo.lineLayerId,
      jsonEncode({"filter": filter, "line-color": "#FFFFFF", "line-width": 4}),
    );
  }

  static Future<void> clearFeatureAreaFilter(
    MapboxMap controller,
    String featureType,
  ) async {
    final layerInfo = _getLayerIdsForType(featureType);

    if (layerInfo == null) return;

    // Remove the overlay to hide the area
    await removeOverlayById(controller, layerInfo.sourceId);
  }

  static ({String sourceId, String fillLayerId, String lineLayerId})?
  _getLayerIdsForType(String featureType) {
    switch (featureType) {
      case MapConstants.peakID:
        return (
          sourceId: MapConstants.mountainsSourceID,
          fillLayerId: MapConstants.mountainsLayerID,
          lineLayerId: MapConstants.mountainsLineLayerID,
        );
      // Add other cases here (lake, park) when they are ready
      default:
        return null; // Return null if not configured
    }
  }

  static Future<void> filterUserMountains(
    MapboxMap controller,
    List<String> userPeakIds,
  ) async {
    await filterFeatureArea(controller, MapConstants.peakID, userPeakIds);
  }

  // Para restaurar y ver todas de nuevo:
  static Future<void> resetMountainsFilter(MapboxMap controller) async {
    await clearFeatureAreaFilter(controller, MapConstants.peakID);
  }

  static Future<void> addOverlay(MapboxMap controller, String overlayId) async {
    switch (overlayId) {
      case MapConstants.mountainsSourceID:
        await addMountainAreaAll(controller);
      default:
        log('Unknown overlay: $overlayId');
    }
  }

  static Future<void> removeOverlayById(
    MapboxMap controller,
    String overlayId,
  ) async {
    switch (overlayId) {
      case MapConstants.mountainsSourceID:
        await removeOverlay(controller, MapConstants.mountainsSourceID, [
          MapConstants.mountainsLayerID,
          MapConstants.mountainsLineLayerID,
        ]);
      default:
        log('Unknown overlay: $overlayId');
    }
  }

  static Future<void> applyPlaceTypeFilter(
    MapboxMap controller,
    String? placeType,
  ) async {
    const pointsLayerID = MapConstants.placesPointsLayerID;
    const clusterLayerID = MapConstants.placesClusterLayerID;
    const countLayerID = MapConstants.placesCountLayerID;

    // Base filter for non-clustered points
    final pointsBaseFilter = [
      "!",
      [
        ">",
        [
          "coalesce",
          ["get", "point_count"],
          0,
        ],
        1,
      ],
    ];

    // Base filter for clusters
    final clusterBaseFilter = [
      ">",
      ["get", "point_count"],
      1,
    ];

    if (placeType != null) {
      final typeCondition = [
        "==",
        ["get", "type"],
        placeType,
      ];

      // Points: non-clustered + type match
      await controller.style.setStyleLayerProperty(pointsLayerID, 'filter', [
        "all",
        pointsBaseFilter,
        typeCondition,
      ]);

      // Clusters: clustered + type match
      await controller.style.setStyleLayerProperty(clusterLayerID, 'filter', [
        "all",
        clusterBaseFilter,
        typeCondition,
      ]);

      // Count labels: same as clusters
      await controller.style.setStyleLayerProperty(countLayerID, 'filter', [
        "all",
        clusterBaseFilter,
        typeCondition,
      ]);
    } else {
      // Restore original filters
      await controller.style.setStyleLayerProperty(
        pointsLayerID,
        'filter',
        pointsBaseFilter,
      );
      await controller.style.setStyleLayerProperty(
        clusterLayerID,
        'filter',
        clusterBaseFilter,
      );
      await controller.style.setStyleLayerProperty(
        countLayerID,
        'filter',
        clusterBaseFilter,
      );
    }
  }
}

String _getAssetPath(String sourceBaseID) {
  switch (sourceBaseID) {
    case MapConstants.waterfallID:
      return AppAssets.WATERFALL_PIN;
    case MapConstants.peakID:
      return AppAssets.PEAK_PIN;
    case MapConstants.mountainPassID:
      return AppAssets.BRIDGE_PIN;
    case MapConstants.lakeID:
      return AppAssets.LAKE_PIN;
    case MapConstants.parkID:
      return AppAssets.PARK_PIN;
    case MapConstants.volcanoID:
      return AppAssets.VOLCANO_PIN;
    default:
      throw ArgumentError('Unsupported sourceBaseID: $sourceBaseID');
  }
}

// Ensure style is loaded
Future<bool> _ensureStyleIsLoaded(MapboxMap controller) async {
  int retryCount = 0;
  while (!await controller.style.isStyleLoaded() && retryCount < 10) {
    await Future.delayed(const Duration(milliseconds: 200));
    retryCount++;
  }
  return retryCount < 10;
}
