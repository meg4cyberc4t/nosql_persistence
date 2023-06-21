import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import 'package:nosql_persistence/src/persistence_interface.dart';

abstract base class SecureDataSource extends PersistenceInterface {
  final FlutterSecureStorage _secureStorage;
  @internal
  final bool separateKey;

  const SecureDataSource(
    this._secureStorage, {
    required super.databaseName,
    super.databaseVersion = 1,
    this.separateKey = true,
  });

  String __separateKey(String key) {
    if (!separateKey) return key;
    return "_${databaseName}_$key";
  }

  @override
  @protected
  Future<void> write({
    required String key,
    required String? value,
  }) =>
      _secureStorage.write(key: __separateKey(key), value: value);

  @override
  @protected
  Future<String?> read(String key) =>
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
