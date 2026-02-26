// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_content_database.dart';

// ignore_for_file: type=lint
class $DownloadedBundlesTable extends DownloadedBundles
    with TableInfo<$DownloadedBundlesTable, DownloadedBundle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedBundlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<int> downloadedAt = GeneratedColumn<int>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    sizeBytes,
    downloadedAt,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_bundles';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedBundle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadedBundle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedBundle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_at'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $DownloadedBundlesTable createAlias(String alias) {
    return $DownloadedBundlesTable(attachedDatabase, alias);
  }
}

class DownloadedBundle extends DataClass
    implements Insertable<DownloadedBundle> {
  final String id;
  final String title;
  final int sizeBytes;
  final int downloadedAt;
  final String payload;
  const DownloadedBundle({
    required this.id,
    required this.title,
    required this.sizeBytes,
    required this.downloadedAt,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['downloaded_at'] = Variable<int>(downloadedAt);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  DownloadedBundlesCompanion toCompanion(bool nullToAbsent) {
    return DownloadedBundlesCompanion(
      id: Value(id),
      title: Value(title),
      sizeBytes: Value(sizeBytes),
      downloadedAt: Value(downloadedAt),
      payload: Value(payload),
    );
  }

  factory DownloadedBundle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedBundle(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      downloadedAt: serializer.fromJson<int>(json['downloadedAt']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'downloadedAt': serializer.toJson<int>(downloadedAt),
      'payload': serializer.toJson<String>(payload),
    };
  }

  DownloadedBundle copyWith({
    String? id,
    String? title,
    int? sizeBytes,
    int? downloadedAt,
    String? payload,
  }) => DownloadedBundle(
    id: id ?? this.id,
    title: title ?? this.title,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    payload: payload ?? this.payload,
  );
  DownloadedBundle copyWithCompanion(DownloadedBundlesCompanion data) {
    return DownloadedBundle(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedBundle(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, sizeBytes, downloadedAt, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedBundle &&
          other.id == this.id &&
          other.title == this.title &&
          other.sizeBytes == this.sizeBytes &&
          other.downloadedAt == this.downloadedAt &&
          other.payload == this.payload);
}

class DownloadedBundlesCompanion extends UpdateCompanion<DownloadedBundle> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> sizeBytes;
  final Value<int> downloadedAt;
  final Value<String> payload;
  final Value<int> rowid;
  const DownloadedBundlesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadedBundlesCompanion.insert({
    required String id,
    required String title,
    required int sizeBytes,
    required int downloadedAt,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       sizeBytes = Value(sizeBytes),
       downloadedAt = Value(downloadedAt),
       payload = Value(payload);
  static Insertable<DownloadedBundle> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? sizeBytes,
    Expression<int>? downloadedAt,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadedBundlesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? sizeBytes,
    Value<int>? downloadedAt,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return DownloadedBundlesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<int>(downloadedAt.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedBundlesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$OfflineContentDatabase extends GeneratedDatabase {
  _$OfflineContentDatabase(QueryExecutor e) : super(e);
  $OfflineContentDatabaseManager get managers =>
      $OfflineContentDatabaseManager(this);
  late final $DownloadedBundlesTable downloadedBundles =
      $DownloadedBundlesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [downloadedBundles];
}

typedef $$DownloadedBundlesTableCreateCompanionBuilder =
    DownloadedBundlesCompanion Function({
      required String id,
      required String title,
      required int sizeBytes,
      required int downloadedAt,
      required String payload,
      Value<int> rowid,
    });
typedef $$DownloadedBundlesTableUpdateCompanionBuilder =
    DownloadedBundlesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> sizeBytes,
      Value<int> downloadedAt,
      Value<String> payload,
      Value<int> rowid,
    });

class $$DownloadedBundlesTableFilterComposer
    extends Composer<_$OfflineContentDatabase, $DownloadedBundlesTable> {
  $$DownloadedBundlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadedBundlesTableOrderingComposer
    extends Composer<_$OfflineContentDatabase, $DownloadedBundlesTable> {
  $$DownloadedBundlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadedBundlesTableAnnotationComposer
    extends Composer<_$OfflineContentDatabase, $DownloadedBundlesTable> {
  $$DownloadedBundlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$DownloadedBundlesTableTableManager
    extends
        RootTableManager<
          _$OfflineContentDatabase,
          $DownloadedBundlesTable,
          DownloadedBundle,
          $$DownloadedBundlesTableFilterComposer,
          $$DownloadedBundlesTableOrderingComposer,
          $$DownloadedBundlesTableAnnotationComposer,
          $$DownloadedBundlesTableCreateCompanionBuilder,
          $$DownloadedBundlesTableUpdateCompanionBuilder,
          (
            DownloadedBundle,
            BaseReferences<
              _$OfflineContentDatabase,
              $DownloadedBundlesTable,
              DownloadedBundle
            >,
          ),
          DownloadedBundle,
          PrefetchHooks Function()
        > {
  $$DownloadedBundlesTableTableManager(
    _$OfflineContentDatabase db,
    $DownloadedBundlesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedBundlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadedBundlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadedBundlesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> downloadedAt = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadedBundlesCompanion(
                id: id,
                title: title,
                sizeBytes: sizeBytes,
                downloadedAt: downloadedAt,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int sizeBytes,
                required int downloadedAt,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => DownloadedBundlesCompanion.insert(
                id: id,
                title: title,
                sizeBytes: sizeBytes,
                downloadedAt: downloadedAt,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadedBundlesTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineContentDatabase,
      $DownloadedBundlesTable,
      DownloadedBundle,
      $$DownloadedBundlesTableFilterComposer,
      $$DownloadedBundlesTableOrderingComposer,
      $$DownloadedBundlesTableAnnotationComposer,
      $$DownloadedBundlesTableCreateCompanionBuilder,
      $$DownloadedBundlesTableUpdateCompanionBuilder,
      (
        DownloadedBundle,
        BaseReferences<
          _$OfflineContentDatabase,
          $DownloadedBundlesTable,
          DownloadedBundle
        >,
      ),
      DownloadedBundle,
      PrefetchHooks Function()
    >;

class $OfflineContentDatabaseManager {
  final _$OfflineContentDatabase _db;
  $OfflineContentDatabaseManager(this._db);
  $$DownloadedBundlesTableTableManager get downloadedBundles =>
      $$DownloadedBundlesTableTableManager(_db, _db.downloadedBundles);
}
