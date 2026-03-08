import 'dart:developer';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saltamontes/data/models/place.dart';

@lazySingleton
class PlaceApiProvider {
  final SupabaseClient _client;

  PlaceApiProvider(this._client);

  Future<Set<Place>> fetchAll() async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('places')
          .select('*');
      return response.map((e) => Place.fromJson(e)).toSet();
    } catch (e) {
      log(e.toString());
      return <Place>{};
    }
  }

  Future<Set<Place>> fetchPeaks() async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('places')
          .select('*')
          .eq('type', 'peak');
      return response.map((e) => Place.fromJson(e)).toSet();
    } catch (e) {
      log(e.toString());
      return <Place>{};
    }
  }

  Future<Set<Place>> fetchWaterfalls() async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('places')
          .select('*')
          .eq('type', 'waterfall');
      return response.map((e) => Place.fromJson(e)).toSet();
    } catch (e) {
      log(e.toString());
      return <Place>{};
    }
  }

  Future<Set<Place>> fetchPasses() async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('places')
          .select('*')
          .eq('type', 'pass');
      return response.map((e) => Place.fromJson(e)).toSet();
    } catch (e) {
      log(e.toString());
      return <Place>{};
    }
  }

  Future<Set<Place>> fetchLakes() async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('places')
          .select('*')
          .eq('type', 'lake');
      return response.map((e) => Place.fromJson(e)).toSet();
    } catch (e) {
      log(e.toString());
      return <Place>{};
    }
  }

  Future<Set<Place>> queryByName(String name, {bool isLimited = true}) async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('places')
          .select('*')
          .ilike('name', '%$name%')
          .limit(isLimited ? 10 : 50);
      return response.map((e) => Place.fromJson(e)).toSet();
    } catch (e) {
      log(e.toString());
      return <Place>{};
    }
  }

  Future<Place?> fetchById(String id) async {
    try {
      final Map<String, dynamic>? response = await _client
          .from('places')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      return Place.fromJson(response);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<Set<Place>> fetchByProtectedAreaId(String protectedAreaId) async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('places')
          .select('*')
          .eq('protected_area_id', protectedAreaId)
          .neq('type', 'park');
      return response.map((e) => Place.fromJson(e)).toSet();
    } catch (e) {
      log(e.toString());
      return <Place>{};
    }
  }
}
