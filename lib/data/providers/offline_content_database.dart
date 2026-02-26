import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'offline_content_database.g.dart';

// ─── Tabla bundles descargados ───
class DownloadedBundles extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get sizeBytes => integer().named('size_bytes')();
  IntColumn get downloadedAt => integer().named('downloaded_at')();
  TextColumn get payload => text()(); // JSON completo del bundle

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [DownloadedBundles])
class OfflineContentDatabase extends _$OfflineContentDatabase {
  static final OfflineContentDatabase _instance = OfflineContentDatabase._();
  factory OfflineContentDatabase() => _instance;

  OfflineContentDatabase._() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ─── Queries ───

  Stream<List<DownloadedBundle>> watchAllBundles() {
    return (select(
      downloadedBundles,
    )..orderBy([(t) => OrderingTerm.desc(t.downloadedAt)])).watch();
  }

  Future<List<DownloadedBundle>> getAllBundles() =>
      select(downloadedBundles).get();

  Future<DownloadedBundle?> getBundleById(String id) => (select(
    downloadedBundles,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertBundle(DownloadedBundlesCompanion bundle) =>
      into(downloadedBundles).insert(bundle);

  Future<int> deleteBundle(String id) =>
      (delete(downloadedBundles)..where((t) => t.id.equals(id))).go();

  Future<int> clearAll() => delete(downloadedBundles).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'offline_content.db'));

    return NativeDatabase(
      file,
      setup: (database) {
        database.execute('PRAGMA journal_mode=WAL;');
      },
    );
  });
}
