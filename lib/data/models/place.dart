import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import 'package:saltamontes/core/utils/normalize_map.dart';

Place placeFromJson(String str) => Place.fromJson(json.decode(str));

String placeToJson(Place data) => json.encode(data.toJson());

enum PlaceType { peak, lake, pass, waterfall, park }

class Place {
  final String id;
  final String name;
  final int? alt;
  final PlaceType type;
  // final String type;
  final double lng;
  final double lat;
  final PlaceGeometry geom;
  final String? stateId;
  final String? districtId;
  final String? protectedAreaId;
  final String? stateName;
  final String? districtName;
  final String? protectedAreaName;

  Place({
    required this.id,
    required this.name,
    required this.alt,
    required this.type,
    required this.lng,
    required this.lat,
    required this.geom,
    required this.stateId,
    required this.districtId,
    required this.protectedAreaId,
    required this.stateName,
    required this.districtName,
    required this.protectedAreaName,
  });

  Place copyWith({
    String? id,
    String? name,
    dynamic alt,
    PlaceType? type,
    double? lng,
    double? lat,
    PlaceGeometry? geom,
    String? stateId,
    String? districtId,
    dynamic protectedAreaId,
    String? stateName,
    String? districtName,
    dynamic protectedAreaName,
  }) => Place(
    id: id ?? this.id,
    name: name ?? this.name,
    alt: alt ?? this.alt,
    type: type ?? this.type,
    lng: lng ?? this.lng,
    lat: lat ?? this.lat,
    geom: geom ?? this.geom,
    stateId: stateId ?? this.stateId,
    districtId: districtId ?? this.districtId,
    protectedAreaId: protectedAreaId ?? this.protectedAreaId,
    stateName: stateName ?? this.stateName,
    districtName: districtName ?? this.districtName,
    protectedAreaName: protectedAreaName ?? this.protectedAreaName,
  );

  String? get simpleStateName {
    if (stateName == null) return null;
    return _simplifyName(stateName!);
  }

  String? get simpleDistrictName {
    if (districtName == null) return null;
    return _simplifyName(districtName!);
  }

  String _simplifyName(String name) {
    const targets = [
      "Departamento de",
      "Departamento",
      "Partido de",
      "Partido",
      "Provincia del",
      "Provincia de",
      "Provincia",
    ];

    for (final target in targets) {
      if (name.contains(target)) {
        return name.substring(name.indexOf(target) + target.length).trim();
      }
    }
    return name;
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    PlaceType type = _getType(json["type"]);
    late final String name;
    if (json["name"] == null) {
      switch (type) {
        case PlaceType.peak:
          name = "Cerro (nombre no verificado)";
          break;
        case PlaceType.lake:
          name = "Lago (nombre no verificado)";
          break;
        case PlaceType.pass:
          name = "Paso (nombre no verificado)";
          break;
        case PlaceType.waterfall:
          name = "Cascada (nombre no verificado)";
          break;
        case PlaceType.park:
          name = "Parque (nombre no verificado)";
          break;
      }
    } else {
      name = json["name"];
    }
    return Place(
      id: json["id"],
      name: name,
      alt: json["alt"],
      type: type,
      lng: json["lng"]?.toDouble(),
      lat: json["lat"]?.toDouble(),
      geom: PlaceGeometry.fromJson(json["geom"]),
      stateId: json["state_id"],
      districtId: json["district_id"],
      protectedAreaId: json["protected_area_id"],
      stateName: json["state_name"],
      districtName: json["district_name"],
      protectedAreaName: json["protected_area_name"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "alt": alt,
    "type": type.name,
    "lng": lng,
    "lat": lat,
    "geom": geom.toJson(),
    "state_id": stateId,
    "district_id": districtId,
    "protected_area_id": protectedAreaId,
    "state_name": stateName,
    "district_name": districtName,
    "protected_area_name": protectedAreaName,
  };
}

class PlaceGeometry {
  final String type;
  final LatLng coordinates;

  PlaceGeometry({required this.type, required this.coordinates});

  PlaceGeometry copyWith({String? type, LatLng? coordinates}) => PlaceGeometry(
    type: type ?? this.type,
    coordinates: coordinates ?? this.coordinates,
  );

  factory PlaceGeometry.fromJson(Map<String, dynamic> json) =>
      PlaceGeometry(type: json["type"], coordinates: LatLng.fromJson(json));

  factory PlaceGeometry.fromFeature(Map<String?, Object?> rawFeature) {
    final Map<String, dynamic> json = normalizeMap(rawFeature);
    return PlaceGeometry.fromJson(json['geometry']);
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates.toJson()['coordinates'],
  };

  mb.Position toMapboxPosition() =>
      mb.Position(coordinates.longitude, coordinates.latitude);

  mb.Point toMapboxPoint() => mb.Point.fromJson(coordinates.toJson());
  geo.Position toGeoPosition() => geo.Position.fromMap(coordinates.toJson());
}

PlaceType _getType(String type) {
  switch (type) {
    case 'peak':
      return PlaceType.peak;
    case 'lake':
      return PlaceType.lake;
    case 'pass':
      return PlaceType.pass;
    case 'waterfall':
      return PlaceType.waterfall;
    case 'park':
      return PlaceType.park;
    default:
      return PlaceType.peak;
  }
}

// class Geom {
//   final String type;
//   final List<double> coordinates;

//   Geom({required this.type, required this.coordinates});

//   Geom copyWith({String? type, List<double>? coordinates}) => Geom(
//     type: type ?? this.type,
//     coordinates: coordinates ?? this.coordinates,
//   );

//   factory Geom.fromJson(Map<String, dynamic> json) => Geom(
//     type: json["type"],
//     // crs: Crs.fromJson(json["crs"]),
//     coordinates: List<double>.from(
//       json["coordinates"].map((x) => x?.toDouble()),
//     ),
//   );

//   Map<String, dynamic> toJson() => {
//     "type": type,
//     "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
//   };
// }
