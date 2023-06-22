import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';
import 'package:nosql_persistence/src/persistence_interface.dart';
import 'package:nosql_persistence/src/storage/default_comparation_strategy.dart';
import 'package:nosql_persistence/src/storage/default_key_comparator.dart';

abstract base class StorageDataSource extends PersistenceInterface {
  final HiveInterface _hive;

  late final LazyBox<String> _box;

  StorageDataSource(
    this._hive, {
    required super.databaseName,
    super.databaseVersion = 1,
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
    await super.initAsync();
  }

  @override
  @protected
  Future<void> put({required String key, required String? value}) async {
    if (value == null) {
      await _box.delete(key);
    } else {
      await _box.put(key, value);
    }
  }

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
