import 'dart:developer';

import 'package:injectable/injectable.dart';
import 'package:saltamontes/data/models/place.dart';
import 'package:saltamontes/data/providers/place_provider.dart';

/// Repositorio de datos del mapa principal.
///
/// Proporciona acceso a peaks, waterfalls, passes y lakes
/// para renderizar en las capas del mapa.
@lazySingleton
class MapPlaceRepository {
  MapPlaceRepository(this._placeProvider);

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
