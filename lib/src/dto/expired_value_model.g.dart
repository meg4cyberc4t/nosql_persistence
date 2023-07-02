// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expired_value_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpiredValueModel _$ExpiredValueModelFromJson(Map<String, dynamic> json) =>
    ExpiredValueModel(
      value: json['value'] as String,
      expirationDuration:
          Duration(microseconds: json['expirationDuration'] as int),
      startDate: DateTime.parse(json['startDate'] as String),
    );

Map<String, dynamic> _$ExpiredValueModelToJson(ExpiredValueModel instance) =>
    <String, dynamic>{
      'value': instance.value,
      'startDate': instance.startDate.toIso8601String(),
      'expirationDuration': instance.expirationDuration.inMicroseconds,
    };
