import 'package:flutter/material.dart';
import 'package:saltamontes/core/environment/env.dart';

class AppUtil {
  static final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext get navigatorContext =>
      navigatorKey.currentContext ?? scaffoldKey.currentContext!;

  static BuildContext get scaffoldContext =>
      scaffoldKey.currentContext as BuildContext;
}

class MapConstants {
  static const String placesID = 'places';
  static const String mountainsID = 'mountains';

  static const String waterfallID = 'waterfall';
  static const String peakID = 'peak';
  static const String waterID = 'water';
  static const String mountainPassID = 'pass';
  static const String lakeID = 'lake';
  static const String parkID = 'park';
  static const String volcanoID = 'volcano';
  static const String trackingID = 'tracking';

  // Places
  static const String placesSourceID = '$placesID-source';
  static const String placesClusterLayerID = '$placesID-cluster';
  static const String placesCountLayerID = '$placesID-count';
  static const String placesPointsLayerID = '$placesID-points';
  static const String placesSourceLayerID = 'places';

  // Mountains
  static const String mountainsSourceID = '$mountainsID-mvt-source';
  static const String mountainsLayerID = '$mountainsID-fill-layer';
  static const String mountainsSourceLayerID = 'mountain_areas_tiles';
  static const String mountainsLineLayerID = '$mountainsID-area-lines';

  // Water
  static const String waterSourceID = '$waterID-mvt-source';
  static const String waterLayerID = '$waterID-fill-layer';
  static const String waterSourceLayerID = 'water';
  static const String waterLineLayerID = '$waterID-area-lines';

  // Tracking
  static const String trackingSourceID = "$trackingID-source";
  static const String trackingLayerID = "$trackingID-line";
  static const String trackingFeatureID = "$trackingID-feature";

  static const _supabaseFunctions = "${Environment.supabaseURL}/functions/v1/";

  static const String mountainAreasMVT =
      "${_supabaseFunctions}mvt_peak_areas/{z}/{x}/{y}";
  static const String placesMVT = "${_supabaseFunctions}mvt_places/{z}/{x}/{y}";
  static const String waterMVT = "${_supabaseFunctions}mvt-water/{z}/{x}/{y}";
}
