import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nosql_persistence/nosql_persistence.dart';

base mixin PersistenseJsonResolver on PersistenceInterface {
  @protected
  Future<T?> getJsonTyped<T extends Object>(
    String key,
    Function(Map<String, Object?> json) fromJson, {
    T? defaultValue,
  }) async {
    final String? json = await get(key);
    if (json == null) return defaultValue;
    return fromJson(jsonDecode(json));
  }

  @protected
  Future<void> putJsonTyped(
    String key,
    Map<String, Object?> json,
  ) =>
      put(key: key, value: jsonEncode(json));
}
