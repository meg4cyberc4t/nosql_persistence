import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nosql_persistence/nosql_persistence.dart';

base mixin PersistenseJsonResolver on PersistenceInterface {
  /// Will return the structure by [key], steam it through the
  /// [fromJson] method. If you need a default value, pass it as an
  /// argument [defaultValue], however we cannot guarantee it, so use "!".
  ///
  /// Example:
  ///
  /// final taskModel = await getJsonTyped("your key", TaskModel.fromJson);
  @protected
  Future<T?> getJsonTyped<T extends Object>(
    String key,
    T Function(Map<String, Object?> json) fromJson, {
    T? defaultValue,
  }) async {
    final String? json = await get(key);
    if (json == null) return defaultValue;
    return fromJson(jsonDecode(json));
  }

  /// Saves the structure by [key].
  /// Important for use, pass it sterilized to Map<String, Object?>
  ///
  /// Example:
  ///
  /// await putJsonTyped("your key", taskModel.toJson());
  @protected
  Future<void> putJsonTyped(
    String key,
    Map<String, Object?> json,
  ) =>
      put(key: key, value: jsonEncode(json));
}
