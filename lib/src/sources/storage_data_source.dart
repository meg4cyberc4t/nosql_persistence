import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';
import 'package:nosql_persistence/src/ext/default_comparation_strategy.dart';
import 'package:nosql_persistence/src/ext/default_key_comparator.dart';
import 'package:nosql_persistence/src/persistence_interface.dart';
import 'package:nosql_persistence/src/resolvers/persistence_migrations_resolver.dart';
import 'package:nosql_persistence/src/resolvers/persistense_json_resolver.dart';

abstract base class StorageDataSource extends PersistenceInterface
    with PersistenseJsonResolver, PersistenceMigrationsResolver {
  final HiveInterface _hive;

  late final LazyBox<String> _box;

  @override
  @protected
  final String databaseName;

  @override
  @protected
  final int databaseVersion;

  StorageDataSource(
    this._hive, {
    required this.databaseName,
    this.databaseVersion = 1,
  });

  @override
  @mustCallSuper
  Future<void> initAsync({
    HiveCipher? encryptionCipher,
    String? path,
    String? collection,
  }) async {
    _box = await _hive.openLazyBox<String>(
      databaseName,
      collection: collection,
      compactionStrategy: defaultCompactionStrategy,
      encryptionCipher: encryptionCipher,
      keyComparator: defaultKeyComparator,
      path: path,
    );
    await initMigrations();
    await super.initAsync();
  }

  @override
  @protected
  Future<void> put({required String key, required String? value}) async =>
      value == null ? _box.delete(key) : _box.put(key, value);

  @override
  @protected
  Future<String?> get(String key) => _box.get(key);

  @override
  @protected
  Future<bool> containsKey(String key) async => _box.containsKey(key);

  @override
  @protected
  Future<void> delete(String key) => _box.delete(key);
}
