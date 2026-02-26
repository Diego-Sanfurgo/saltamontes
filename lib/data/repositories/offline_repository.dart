import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saltamontes/data/providers/offline_content_database.dart';

/// Repositorio para gestionar descargas offline (bundles).
class OfflineRepository {
  final OfflineContentDatabase _db;
  final SupabaseClient _client;

  OfflineRepository({OfflineContentDatabase? db, SupabaseClient? client})
    : _db = db ?? OfflineContentDatabase(),
      _client = client ?? Supabase.instance.client;

  /// Descarga un bundle desde el RPC y lo guarda localmente.
  Future<void> downloadBundle(String trackId) async {
    // Llamar al RPC de Supabase
    final response = await _client.rpc(
      'download_offline_bundle',
      params: {'track_id_input': trackId},
    );

    final data = response as Map<String, dynamic>;

    if (data.containsKey('error')) {
      throw Exception(data['error']);
    }

    // Preparar payload
    final payloadJson = jsonEncode(data);
    final sizeBytes = payloadJson.length; // Tamaño en bytes del JSON

    // Título del bundle
    final excursion = data['excursion'] as Map<String, dynamic>?;
    final title = excursion?['title'] as String? ?? 'Track $trackId';

    // Guardar en Drift
    await _db.insertBundle(
      DownloadedBundlesCompanion(
        id: Value(trackId),
        title: Value(title),
        sizeBytes: Value(sizeBytes),
        downloadedAt: Value(DateTime.now().millisecondsSinceEpoch),
        payload: Value(payloadJson),
      ),
    );
  }

  /// Obtener todos los bundles descargados (stream).
  Stream<List<DownloadedBundle>> watchBundles() => _db.watchAllBundles();

  /// Obtener un bundle por ID para consultar sus datos (track, backup tracks, etc.)
  Future<Map<String, dynamic>?> getBundleData(String bundleId) async {
    final bundle = await _db.getBundleById(bundleId);
    if (bundle == null) return null;
    return jsonDecode(bundle.payload) as Map<String, dynamic>;
  }

  /// Obtener los tracks de backup de un bundle para mostrar en el mapa.
  Future<List<Map<String, dynamic>>> getBackupTracks(String bundleId) async {
    final data = await getBundleData(bundleId);
    if (data == null) return [];
    final backups = data['backup_tracks'] as List?;
    return backups?.cast<Map<String, dynamic>>() ?? [];
  }

  /// Eliminar un bundle (cascading delete del Drift + limpieza).
  Future<void> deleteBundle(String id) async {
    await _db.deleteBundle(id);
  }

  /// Eliminar todos los bundles.
  Future<void> clearAll() async => await _db.clearAll();
}
