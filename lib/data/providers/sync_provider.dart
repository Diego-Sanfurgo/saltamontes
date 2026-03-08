import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saltamontes/data/providers/tracking_database.dart';

/// Provider de datos para sincronización Offline-First.
///
/// Responsable exclusivamente de las operaciones I/O:
/// - Lectura/escritura en TrackingDatabase (Drift/SQLite local)
/// - Operaciones de red contra Supabase
/// - Stream de conectividad
///
/// Singleton: mantiene las mismas instancias de DB y Connectivity.
class SyncProvider {
  static final SyncProvider instance = SyncProvider._();
  SyncProvider._();

  final TrackingDatabase _db = TrackingDatabase();
  final SupabaseClient _supabase = Supabase.instance.client;
  final Connectivity _connectivity = Connectivity();

  // ─── Auth ───

  String? get currentUserId => _supabase.auth.currentUser?.id;

  // ─── Connectivity ───

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  // ─── TrackingDatabase: Points ───

  Future<List<TrackingPoint>> getAllPoints() => _db.getAllPoints();

  Future<int> clearAllPoints() => _db.clearAllPoints();

  // ─── TrackingDatabase: SyncQueue ───

  Future<void> insertSyncItem(SyncQueueCompanion item) =>
      _db.insertSyncItem(item);

  Future<List<SyncQueueData>> getPendingSyncItems() =>
      _db.getPendingSyncItems();

  Future<int> deleteSyncItem(String id) => _db.deleteSyncItem(id);

  // ─── Supabase: Upload ───

  /// Inserta un track en geo_core.user_tracks y retorna el trackId
  Future<String> uploadTrack(Map<String, dynamic> trackData) async {
    final response = await _supabase
        .schema('geo_core')
        .from('user_tracks')
        .insert(trackData)
        .select('id')
        .single();
    return response['id'] as String;
  }

  /// Actualiza la excursión con el recorded_track_id
  Future<void> updateExcursionTrack(String excursionId, String trackId) async {
    await _supabase
        .from('excursions')
        .update({'recorded_track_id': trackId})
        .eq('id', excursionId);
  }
}
