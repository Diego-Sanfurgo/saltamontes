import 'dart:developer';

import 'package:saltamontes/data/models/place.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlaceProvider {
  factory PlaceProvider() => _instance;
  static final PlaceProvider _instance = PlaceProvider._internal();
  final SupabaseClient supabase = Supabase.instance.client;
  PlaceProvider._internal();

  Future<Set<Place>> fetchAll() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
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
      final List<Map<String, dynamic>> response = await supabase
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
      final List<Map<String, dynamic>> response = await supabase
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
      final List<Map<String, dynamic>> response = await supabase
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
      final List<Map<String, dynamic>> response = await supabase
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
      final List<Map<String, dynamic>> response = await supabase
          .from('places')
          .select('*')
          .ilike('name', '%$name%') // Búsqueda parcial insensible a mayúsculas
          .limit(isLimited ? 10 : 50); // Limita resultados para performance UI
      return response.map((e) => Place.fromJson(e)).toSet();
    } catch (e) {
      log(e.toString());
      return <Place>{};
    }
  }

  Future<Place?> fetchById(String id) async {
    try {
      final Map<String, dynamic>? response = await supabase
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
      final List<Map<String, dynamic>> response = await supabase
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
