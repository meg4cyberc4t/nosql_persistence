import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract base class PersistenceInterface {
  const PersistenceInterface();

  /// The function that is called after opening the box. Must definitely wait
  @mustCallSuper
  Future<void> initAsync() async {}

  /// Write a record from the database
  Future<void> put({required String key, required String? value});

  /// Read a record from the database
  Future<String?> get(String key);

  /// Returns true if there is an entry for such a key
  Future<bool> containsKey(String key);

  /// Delete a record from the database
  Future<void> delete(String key) => put(key: key, value: null);

  /// The function should release the elements when the class is closed
  @mustCallSuper
  Future<void> dispose() async {}
}
