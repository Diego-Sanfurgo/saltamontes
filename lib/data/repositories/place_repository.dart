import 'dart:developer';

import 'package:saltamontes/data/models/place.dart';
import 'package:saltamontes/data/providers/place_provider.dart';

class PlaceRepository {
  PlaceRepository(this._provider);

  final PlaceProvider _provider;

  Future<Set<Place>> getAll() async {
    try {
      return await _provider.fetchAll();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<Set<Place>> getPeaks() async {
    try {
      return await _provider.fetchPeaks();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<Set<Place>> getWaterfalls() async {
    try {
      return await _provider.fetchWaterfalls();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<Set<Place>> getPasses() async {
    try {
      return await _provider.fetchPasses();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<Set<Place>> getLakes() async {
    try {
      return await _provider.fetchLakes();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<Set<Place>> queryByName(String name, {bool isLimited = true}) async {
    try {
      return await _provider.queryByName(name, isLimited: isLimited);
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<Place?> getById(String id) async {
    try {
      return await _provider.fetchById(id);
    } on Exception catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<Set<Place>> getByProtectedAreaId(String protectedAreaId) async {
    try {
      return await _provider.fetchByProtectedAreaId(protectedAreaId);
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }
}
