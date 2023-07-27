import 'package:flutter/foundation.dart';
import 'package:nosql_persistence/nosql_persistence.dart';

/// Adds advanced methods for convenient interaction with simple types
/// (bool, int) without unnecessary conversion.
///
/// Example:
///
/// final bool? isTruth = await getBool("truth");
/// await putBool("truth");
base mixin PersistenceBaseTypesResolver on PersistenceInterface {
  /// Gets true if the key has the value "true", otherwise false.
  @protected
  Future<bool?> getBool(String key) async {
    final String? result = await get(key);
    if (result == null) {
      return null;
    }
    return bool.tryParse(result);
  }

  /// Puts a boolean variable in nosql, doing the conversion
  @protected
  Future<void> putBool(String key, {required bool value}) async => put(
        key: key,
        value: value.toString(),
      );

  /// Gets the corresponding numeric value by key
  @protected
  Future<int?> getInt(String key) async {
    final String? result = await get(key);
    if (result == null) {
      return null;
    }
    return int.tryParse(result);
  }

  /// Puts the corresponding numeric value on the key
  @protected
  Future<void> putInt(String key, {required int value}) async => put(
        key: key,
        value: value.toString(),
      );
}
