import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:saltamontes/core/utils/track_compiler.dart';
import 'package:saltamontes/data/models/trace_point.dart';
import 'package:saltamontes/data/providers/sync_provider.dart';
import 'package:saltamontes/data/providers/tracking_database.dart';

/// Repositorio de sincronización Offline-First.
///
/// Orquesta la lógica de negocio:
/// 1. Compila puntos GPS → payload
/// 2. Encola en sync_queue → limpia points
/// 3. Escucha conectividad para auto-subir
/// 4. Permite retry manual
///
/// Delega toda operación I/O al [SyncProvider].
@lazySingleton
class SyncRepository {
  final SyncProvider _provider;
  final Uuid _uuid = const Uuid();

  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  SyncRepository(this._provider);

  /// Iniciar listener de conectividad
  void startListening() {
    _connectivitySub?.cancel();
    _connectivitySub = _provider.onConnectivityChanged.listen((results) {
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
    final points = await _provider.getAllPoints();
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

    final userId = _provider.currentUserId;
    final payload = TrackCompiler.buildSyncPayload(
      points: tracePoints,
      excursionId: excursionId,
      userId: userId,
    );

    final id = _uuid.v4();
    await _provider.insertSyncItem(
      SyncQueueCompanion(
        id: Value(id),
        excursionPayload: Value(jsonEncode(payload)),
        status: const Value('pending'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    // Limpiar puntos de tracking (libera para nueva grabación)
    await _provider.clearAllPoints();

    // Intentar sync inmediata
    await syncPending();
  }

  /// Intentar subir todos los items pendientes de sync_queue.
  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _provider.getPendingSyncItems();

      for (final item in pending) {
        try {
          final payload =
              jsonDecode(item.excursionPayload) as Map<String, dynamic>;
          await _uploadPayload(payload);
          await _provider.deleteSyncItem(item.id);
        } catch (e) {
          log('SyncRepository: Error subiendo ${item.id}: $e');
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Reintento manual de un item específico.
  Future<bool> retryItem(String itemId) async {
    try {
      final items = await _provider.getPendingSyncItems();
      final item = items.firstWhere((i) => i.id == itemId);

      final payload = jsonDecode(item.excursionPayload) as Map<String, dynamic>;
      await _uploadPayload(payload);
      await _provider.deleteSyncItem(item.id);
      return true;
    } catch (e) {
      log('SyncRepository: Retry failed for $itemId: $e');
      return false;
    }
  }

  /// Obtener conteo de items pendientes
  Future<int> getPendingCount() async {
    final items = await _provider.getPendingSyncItems();
    return items.length;
  }

  /// Sube un payload a Supabase.
  Future<void> _uploadPayload(Map<String, dynamic> payload) async {
    final trackData = payload['track'] as Map<String, dynamic>;
    final excursionId = payload['excursion_id'] as String?;

    // 1. Insertar track en geo_core.user_tracks
    final trackId = await _provider.uploadTrack(trackData);

    // 2. Actualizar excursión con el recorded_track_id
    if (excursionId != null) {
      await _provider.updateExcursionTrack(excursionId, trackId);
    }
  }
}
