import 'package:meta/meta.dart';
import 'package:nosql_persistence/nosql_persistence.dart';

base mixin PersistenceMigrationsResolver on PersistenceInterface {
  /// Name of the database
  @protected
  String get databaseName => runtimeType.toString();

  /// The current version of the database. When changing the data structure,
  /// iterate the current version and confirm the corresponding changes
  /// in [migrate]
  @protected
  int get databaseVersion => 1;

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

  Future<int> get _storageVersion => get(__boxVersionKey)
      .then((String? value) => int.tryParse(value ?? '') ?? 0);

  @protected
  Future<void> __updateStorageVersion() => put(
        key: __boxVersionKey,
        value: databaseVersion.toString(),
      );

  /// You need to call this function and wait after the constructor.
  /// It causes migrations.
  /// If you need an action in the database when opening, write it in [migrate]
  @internal
  Future<void> initMigrations() async {
    await migrate(await _storageVersion, databaseVersion)
        .onError((Object? error, StackTrace stackTrace) => null);
    await __updateStorageVersion();
  }
}
