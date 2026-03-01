import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:saltamontes/core/utils/track_compiler.dart';
import 'package:saltamontes/data/models/trace_point.dart';
import 'package:saltamontes/data/providers/tracking_database.dart';

//TODO: REVISAR

/// Servicio de sincronización Offline-First.
///
/// 1. Al "Finalizar Excursión": compila puntos GPS → sync_queue → limpia points.
/// 2. Escucha conectividad para auto-subir.
/// 3. Permite retry manual de items fallidos.
class SyncService {
  static final SyncService instance = SyncService._();
  SyncService._();

  final TrackingDatabase _db = TrackingDatabase();
  final SupabaseClient _client = Supabase.instance.client;
  final Connectivity _connectivity = Connectivity();
  final Uuid _uuid = const Uuid();

  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  /// Iniciar listener de conectividad
  void startListening() {
    _connectivitySub?.cancel();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final hasInternet = results.any(
        (r) =>
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.ethernet,
      );
      if (hasInternet) {
        syncPending();
      }
    });
  }

  void stopListening() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Compile-and-Queue: empaqueta puntos GPS y encola para sync.
  ///
  /// Llamado al "Finalizar Excursión":
  /// 1. Toma puntos crudos de TrackingDB
  /// 2. Compila en LineStringZM + métricas
  /// 3. Guarda en sync_queue
  /// 4. LIMPIA tracking_points para liberar espacio
  Future<void> enqueueExcursion({String? excursionId}) async {
    final points = await _db.getAllPoints();
    if (points.isEmpty) return;

    final tracePoints = points
        .map(
          (p) => TracePoint(
            lat: p.latitude,
            lon: p.longitude,
            altitude: p.altitude,
            speed: p.speed,
            bearing: p.bearing,
            accuracy: p.accuracy,
            timestamp: p.timestamp,
          ),
        )
        .toList();

    final userId = _client.auth.currentUser?.id;
    final payload = TrackCompiler.buildSyncPayload(
      points: tracePoints,
      excursionId: excursionId,
      userId: userId,
    );

    final id = _uuid.v4();
    await _db.insertSyncItem(
      SyncQueueCompanion(
        id: Value(id),
        excursionPayload: Value(jsonEncode(payload)),
        status: const Value('pending'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    // Limpiar puntos de tracking (libera para nueva grabación)
    await _db.clearAllPoints();

    // Intentar sync inmediata
    await syncPending();
  }

  /// Intentar subir todos los items pendientes de sync_queue.
  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _db.getPendingSyncItems();

      for (final item in pending) {
        try {
          final payload =
              jsonDecode(item.excursionPayload) as Map<String, dynamic>;
          await _uploadPayload(payload);
          await _db.deleteSyncItem(item.id);
        } catch (e) {
          // Si falla un item, continuar con los demás
          print('SyncService: Error subiendo ${item.id}: $e');
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Reintento manual de un item específico.
  Future<bool> retryItem(String itemId) async {
    try {
      final items = await _db.getPendingSyncItems();
      final item = items.firstWhere((i) => i.id == itemId);

      final payload = jsonDecode(item.excursionPayload) as Map<String, dynamic>;
      await _uploadPayload(payload);
      await _db.deleteSyncItem(item.id);
      return true;
    } catch (e) {
      print('SyncService: Retry failed for $itemId: $e');
      return false;
    }
  }

  /// Sube un payload a Supabase.
  Future<void> _uploadPayload(Map<String, dynamic> payload) async {
    final trackData = payload['track'] as Map<String, dynamic>;
    final excursionId = payload['excursion_id'] as String?;

    // 1. Insertar track en geo_core.user_tracks
    //    (esto dispara el trigger de geofencing automáticamente)
    final trackResponse = await _client
        .schema('geo_core')
        .from('user_tracks')
        .insert(trackData)
        .select('id')
        .single();

    final trackId = trackResponse['id'] as String;

    // 2. Actualizar excursión con el recorded_track_id
    if (excursionId != null) {
      await _client
          .from('excursions')
          .update({'recorded_track_id': trackId})
          .eq('id', excursionId);
    }
  }
}
