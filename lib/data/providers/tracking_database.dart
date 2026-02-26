import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'tracking_database.g.dart';

// ─── Tabla de puntos de GPS en alta frecuencia ───
class TrackingPoints extends Table {
  IntColumn get id => integer().autoIncrement()();

  RealColumn get latitude => real().named('latitude')();
  RealColumn get longitude => real().named('longitude')();
  RealColumn get altitude => real().nullable().named('altitude')();
  RealColumn get speed => real().nullable().named('speed')();
  RealColumn get bearing => real().nullable().named('bearing')();
  RealColumn get accuracy => real().nullable().named('accuracy')();

  IntColumn get timestamp => integer().named('timestamp')();
}

// ─── Tabla cola de sincronización (Módulo 5) ───
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get excursionPayload => text().named('excursion_payload')();
  TextColumn get status =>
      text().named('status').withDefault(const Constant('pending'))();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TrackingPoints, SyncQueue])
class TrackingDatabase extends _$TrackingDatabase {
  static final TrackingDatabase _instance = TrackingDatabase._();
  factory TrackingDatabase() => _instance;

  TrackingDatabase._() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // v1 → v2: agregar bearing + sync_queue
        await customStatement(
          'ALTER TABLE tracking_points ADD COLUMN bearing REAL',
        );
        await m.createTable(syncQueue);
      }
    },
  );

  // Stream para ver el track en vivo en el mapa
  Stream<List<TrackingPoint>> watchAllPoints() {
    return (select(
      trackingPoints,
    )..orderBy([(t) => OrderingTerm(expression: t.timestamp)])).watch();
  }

  // Obtener todo el historial
  Future<List<TrackingPoint>> getAllPoints() => select(trackingPoints).get();

  // Borrar todos los puntos de tracking (post-compilación)
  Future<int> clearAllPoints() => delete(trackingPoints).go();

  // ─── SyncQueue ops ───
  Future<void> insertSyncItem(SyncQueueCompanion item) =>
      into(syncQueue).insert(item);

  Future<List<SyncQueueData>> getPendingSyncItems() =>
      (select(syncQueue)..where((t) => t.status.equals('pending'))).get();

  Stream<List<SyncQueueData>> watchPendingSyncItems() =>
      (select(syncQueue)..where((t) => t.status.equals('pending'))).watch();

  Future<void> markSynced(String id) =>
      (update(syncQueue)..where((t) => t.id.equals(id))).write(
        const SyncQueueCompanion(status: Value('synced')),
      );

  Future<int> deleteSyncItem(String id) =>
      (delete(syncQueue)..where((t) => t.id.equals(id))).go();

  Future<int> deleteAllSyncedItems() =>
      (delete(syncQueue)..where((t) => t.status.equals('synced'))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tracking.db'));

    return NativeDatabase(
      file,
      setup: (database) {
        database.execute('PRAGMA journal_mode=WAL;');
      },
    );
  });
}
