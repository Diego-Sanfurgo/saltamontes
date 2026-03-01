import 'dart:developer';

import 'package:saltamontes/data/models/place.dart';
import 'package:saltamontes/data/providers/place_provider.dart';

class TrackingMapRepository {
  TrackingMapRepository(this._placeProvider);

  final PlaceApiProvider _placeProvider;

  Future<Set<Place>> getPeaks() async {
    try {
      return await _placeProvider.fetchPeaks();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<Set<Place>> getWaterfalls() async {
    try {
      return await _placeProvider.fetchWaterfalls();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<Set<Place>> getPasses() async {
    try {
      return await _placeProvider.fetchPasses();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<Set<Place>> getLakes() async {
    try {
      return await _placeProvider.fetchLakes();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }
}
