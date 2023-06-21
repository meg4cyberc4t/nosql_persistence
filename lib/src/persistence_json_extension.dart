import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:nosql_persistence/src/persistence_interface.dart';

extension PersistenceJsonExtension on PersistenceInterface {
  @internal
  Future<T?> getJsonTyped<T extends Object>(
    String key,
    Function(Map<String, Object?> json) fromJson, {
    T? defaultValue,
  }) async {
    final String? json = await read(key);
    if (json == null) return defaultValue;
    return fromJson(jsonDecode(json));
  }

  @internal
  Future<void> putJsonTyped<T extends Object>(
    String key,
    Map<String, Object?> json,
  ) =>
      write(key: key, value: jsonEncode(json));
}
