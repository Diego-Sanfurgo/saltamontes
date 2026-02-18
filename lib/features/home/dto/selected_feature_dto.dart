import 'package:saltamontes/core/utils/constant_and_variables.dart';
import 'package:saltamontes/data/models/place.dart';

class SelectedFeatureDTO {
  final String featureId;
  final bool isCluster;
  final String sourceID;
  final String type;
  final double? lat;
  final double? lng;

  SelectedFeatureDTO({
    required this.featureId,
    required this.isCluster,
    required this.sourceID,
    required this.type,
    this.lat,
    this.lng,
  });

  factory SelectedFeatureDTO.fromFeature(Map<String, dynamic> feature) =>
      SelectedFeatureDTO(
        featureId: feature['properties']['id'],
        isCluster: feature['properties']['cluster'] as bool,
        sourceID: feature['sourceId']!,
        type: feature['properties']['type'] as String,
      );

  factory SelectedFeatureDTO.fromPlace(Place place) => SelectedFeatureDTO(
    featureId: place.id,
    isCluster: false,
    sourceID: MapConstants.placesSourceID,
    type: place.type.name,
    lat: place.geom.coordinates.latitude,
    lng: place.geom.coordinates.longitude,
  );

  factory SelectedFeatureDTO.empty() => SelectedFeatureDTO(
    featureId: '',
    isCluster: false,
    sourceID: '',
    type: '',
  );
}
