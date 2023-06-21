import 'dart:convert';

import 'package:meta/meta.dart';

abstract base class PersistenceInterface {
  const PersistenceInterface({
    required this.databaseName,
    required this.databaseVersion,
  });

  /// Name of the database
  @protected
  final String databaseName;

  /// The current version of the database. When changing the data structure,
  /// iterate the current version and confirm the corresponding changes
  /// in [migrate]
  @protected
  final int databaseVersion;

  /// Write a record from the database
  Future<void> write({required String key, required String? value});

  /// Read a record from the database
  Future<String?> read(String key);

  /// Returns true if there is an entry for such a key
  Future<bool> containsKey(String key);

  /// Delete a record from the database
  Future<void> delete(String key) => write(key: key, value: null);

  /// It will be called automatically once, during the [initAsync] call.
  /// Updates data structures between versions
  @mustCallSuper
  @protected
  Future<void> migrate(int oldVersion, int currentVersion) async {}

  /// Database key for storing the version.
  /// Don't change it from the outside!
  /// All work with migrations should be done automatically!
  @protected
  String get __boxVersionKey => '__${databaseName}_storage_version';

  Future<int> get _storageVersion => read(__boxVersionKey)
      .then((String? value) => int.tryParse(value ?? '') ?? 0);

  @protected
  Future<void> __updateStorageVersion() => write(
        key: __boxVersionKey,
        value: databaseVersion.toString(),
      );

  /// You need to call this function and wait after the constructor.
  /// It causes migrations.
  /// If you need an action in the database when opening, write it in [migrate]
  @mustCallSuper
  Future<void> initAsync() async {
    await migrate(await _storageVersion, databaseVersion)
        .onError((Object? error, StackTrace stackTrace) => null);
    await __updateStorageVersion();
  }

  @protected
  Future<T?> getJsonTyped<T extends Object>(
    String key,
    Function(Map<String, Object?> json) fromJson, {
    T? defaultValue,
  }) async {
    final String? json = await read(key);
    if (json == null) return defaultValue;
    return fromJson(jsonDecode(json));
  }

  @protected
  Future<void> putJsonTyped(
    String key,
    Map<String, Object?> json,
  ) =>
      write(key: key, value: jsonEncode(json));
}
