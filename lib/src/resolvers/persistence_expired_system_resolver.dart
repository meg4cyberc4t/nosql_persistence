import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:nosql_persistence/nosql_persistence.dart';
import 'package:nosql_persistence/src/dto/expired_internal_settings_model.dart';
import 'package:nosql_persistence/src/dto/expired_value_model.dart';

const String kExpiredSettingsKey = '__expired_settings';
const Duration kExpiredDefaultDuration = Duration(days: 7);
const bool kNeedRefreshDefault = false;

/// The mixin is used to manage "expiring" data.
/// With it, you can make data that will be irrelevant over time.
/// When the validity period expires, the data will be deleted.
///
/// For use, it is important to declare [initExpiredSystem] in [initAsync].
/// You can create a value via [putExpired], specify [expirationDuration],
/// and when this expiration period expires, the value will be deleted.
///
/// You can get the value via [getExpired], and restart the timer by
/// passing [needRefresh] to true.
///
/// It is convenient for creating cached data, memory-clearing systems, etc.
base mixin PersistenceExpiredSystemResolver on PersistenceInterface {
  /// Common default field for [putExpired], [putExpiredTyped].
  /// Sets the expiration date for the database,
  /// will be automatically substituted into the query if a named argument
  /// is not specified.
  /// To use it, you need to override.
  @protected
  Duration? get databaseExpiredDuration => null;

  /// Getting the "expired" value.
  /// If you specify the [needRefresh] - start of the expiration counter,
  /// the value will change to the current date and time.
  Future<String?> getExpired(
    String key, {
    bool needRefresh = kNeedRefreshDefault,
  }) async {
    final String? json = await get(key);
    if (json == null) {
      await _markKeyAsUnexpiredAndDelete(key);
      return null;
    }
    final ExpiredValueModel expValue =
        ExpiredValueModel.fromJson(jsonDecode(json));
    final DateTime now = DateTime.now();
    final DateTime maxReachValue =
        expValue.startDate.add(expValue.expirationDuration);
    if (maxReachValue.isBefore(now)) {
      await _markKeyAsUnexpiredAndDelete(key);
      return null;
    }
    if (needRefresh) {
      await putExpired(
        key: key,
        value: expValue.value,
        expirationDuration: expValue.expirationDuration,
      );
    }
    return expValue.value;
  }

  Future<void> putExpired({
    required String key,
    required String value,
    Duration? expirationDuration,
  }) async {
    final DateTime now = DateTime.now();
    final Duration currentExpiredDuration = expirationDuration ??
        databaseExpiredDuration ??
        kExpiredDefaultDuration;
    await _markKeyAsExpired(key);
    return put(
      key: key,
      value: jsonEncode(
        ExpiredValueModel(
          value: value,
          expirationDuration: currentExpiredDuration,
          startDate: now,
        ).toJson(),
      ),
    );
  }

  /// The same as [getExpired], but using structures and deserialization
  Future<T?> getExpiredTyped<T extends Object>(
    String key,
    T Function(Map<String, Object?> json) fromJson, {
    bool needRefresh = kNeedRefreshDefault,
  }) async {
    final String? value = await getExpired(key, needRefresh: needRefresh);
    if (value == null) return null;
    return fromJson(jsonDecode(value));
  }

  /// The same as [putExpired], but using structures and serialization
  Future<void> putExpiredTyped(
    String key,
    Map<String, Object?> valueJson, {
    Duration? expirationDuration,
  }) =>
      putExpired(
        key: key,
        value: jsonEncode(valueJson),
        expirationDuration: expirationDuration,
      );

  /// Must be called in [initAsync]
  /// Loads settings (including keys),
  /// checks the relevance of all values using [__checkExpired]
  Future<void> initExpiredSystem() async {
    __settings = await __getSettings();
    await Future.wait(__settings.keys.map(__checkExpired));
  }

  /// Not for general use. Checks the relevance of the data and deletes it if:
  /// - there is no data
  /// - data cannot be desearalized (may have been overwritten)
  /// - expired
  Future<void> __checkExpired(String key) async {
    try {
      final String? json = await get(key);
      if (json == null) {
        await delete(key);
        return null;
      }
      final ExpiredValueModel expValue =
          ExpiredValueModel.fromJson(jsonDecode(json));
      final DateTime now = DateTime.now();
      final DateTime maxReachValue =
          expValue.startDate.add(expValue.expirationDuration);
      if (maxReachValue.isBefore(now)) {
        await _markKeyAsUnexpiredAndDelete(key);
        return null;
      }
    } on Exception {
      await _markKeyAsUnexpiredAndDelete(key);
    }
  }

  /// General settings of the expired database
  /// It is obtained via [__getSettings] in [initExpiredSystem]
  ExpiredInternalSettingsModel __settings =
      ExpiredInternalSettingsModel.defaultValue;

  /// Getting database settings
  Future<ExpiredInternalSettingsModel> __getSettings() async {
    final String? json = await get(kExpiredSettingsKey);
    if (json == null) return ExpiredInternalSettingsModel.defaultValue;
    return ExpiredInternalSettingsModel.fromJson(jsonDecode(json));
  }

  /// Saving Database settings
  Future<void> __saveSettings(ExpiredInternalSettingsModel settings) =>
      put(key: kExpiredSettingsKey, value: jsonEncode(settings));

  /// Not for general use.
  /// Marks the key as part of the "expired" system.
  /// Now, when loading the database, the key will be checked for relevance.
  Future<void> _markKeyAsExpired(String key) async {
    final List<String> keys = __settings.keys.toList();
    if (!keys.contains(key)) {
      keys.add(key);
    }
    await __saveSettings(__settings.copyWith(keys: keys));
  }

  /// Not for general use.
  /// Cancels the placement of the key and deletes it.
  /// Safely removing the key from the "expired" system
  Future<void> _markKeyAsUnexpiredAndDelete(String key) async {
    final List<String> keys = __settings.keys.toList();
    if (keys.contains(key)) {
      keys.remove(key);
    }
    await delete(key);
    await __saveSettings(__settings.copyWith(keys: keys));
  }
}
