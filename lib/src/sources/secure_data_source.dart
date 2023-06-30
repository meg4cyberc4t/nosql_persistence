import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import 'package:nosql_persistence/src/persistence_interface.dart';
import 'package:nosql_persistence/src/resolvers/persistence_migrations_resolver.dart';
import 'package:nosql_persistence/src/resolvers/persistense_json_resolver.dart';

/// Implementation of the [PersistenceInterface] for Hive.
/// Use this to store data without worrying about performance.

/// Be sure to call [initAsync] after the constructor and wait for it to
/// execute.
/// Calling [dispose] is desirable, but not necessary.
abstract base class SecureDataSource extends PersistenceInterface
    with PersistenseJsonResolver, PersistenceMigrationsResolver {
  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> initAsync() async {
    await initMigrations();
    super.initAsync();
  }

  @internal
  final bool separateKey;

  @override
  @protected
  final String databaseName;

  @override
  @protected
  final int databaseVersion;

  const SecureDataSource(
    this._secureStorage, {
    required this.databaseName,
    this.databaseVersion = 1,
    this.separateKey = true,
  });

  String __separateKey(String key) {
    if (!separateKey) return key;
    return '_${databaseName}_$key';
  }

  @override
  @protected
  Future<void> put({
    required String key,
    required String? value,
  }) =>
      _secureStorage.write(key: __separateKey(key), value: value);

  @override
  @protected
  Future<String?> get(String key) =>
      _secureStorage.read(key: __separateKey(key));

  @override
  @protected
  Future<bool> containsKey(String key) =>
      _secureStorage.containsKey(key: __separateKey(key));

  @override
  @protected
  Future<void> delete(String key) =>
      _secureStorage.delete(key: __separateKey(key));
}
