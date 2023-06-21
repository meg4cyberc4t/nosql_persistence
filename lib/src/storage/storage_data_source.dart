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
    int Function(dynamic, dynamic) keyComparator = defaultKeyComparator,
    bool Function(int, int) compactionStrategy = defaultCompactionStrategy,
    bool crashRecovery = true,
    String? path,
    String? collection,
  }) async {
    _box = await _hive.openLazyBox<String>(
      databaseName,
      collection: collection,
      compactionStrategy: compactionStrategy,
      crashRecovery: crashRecovery,
      encryptionCipher: encryptionCipher,
      keyComparator: keyComparator,
      path: path,
    );
    await super.initAsync();
  }

  @override
  @protected
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      await _box.delete(key);
    } else {
      await _box.put(key, value);
    }
  }

  @override
  @protected
  Future<String?> read(String key) => _box.get(key);

  @override
  @protected
  Future<bool> containsKey(key) async => _box.containsKey(key);

  @override
  @protected
  Future<void> delete(key) => _box.delete(key);
}
