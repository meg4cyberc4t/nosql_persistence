import 'dart:convert';

import 'package:nosql_persistence/nosql_persistence.dart';
import 'package:nosql_persistence/src/dto/expired_internal_settings_model.dart';
import 'package:nosql_persistence/src/dto/expired_value_model.dart';

const String kExpiredSettingsKey = '__expired_settings';
const Duration kExpiredDefaultDuration = Duration(days: 7);

base mixin PersistenceExpiredSystemResolver on PersistenceInterface {
  Duration? get databaseExpiredDuration => null;

  Future<String?> getExpired(String key) async {
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
      await delete(key);
      return null;
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

  Future<T?> getExpiredTyped<T extends Object>(
    String key,
    T Function(Map<String, Object?> json) fromJson,
  ) async {
    final String? value = await getExpired(key);
    if (value == null) return null;
    return fromJson(jsonDecode(value));
  }

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

  Future<void> initExpiredSystem() async {
    __settings = await __getSettings();
    await Future.wait(__settings.keys.map(getExpired));
  }

  ExpiredInternalSettingsModel __settings =
      ExpiredInternalSettingsModel.defaultValue;

  Future<ExpiredInternalSettingsModel> __getSettings() async {
    final String? json = await get(kExpiredSettingsKey);
    if (json == null) return ExpiredInternalSettingsModel.defaultValue;
    return ExpiredInternalSettingsModel.fromJson(jsonDecode(json));
  }

  Future<void> __saveSettings(ExpiredInternalSettingsModel settings) =>
      put(key: kExpiredSettingsKey, value: jsonEncode(settings));

  Future<void> _markKeyAsExpired(String key) async {
    final List<String> keys = __settings.keys.toList();
    if (!keys.contains(key)) {
      keys.add(key);
    }
    await __saveSettings(__settings.copyWith(keys: keys));
  }
}
