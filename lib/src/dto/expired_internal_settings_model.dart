import 'package:json_annotation/json_annotation.dart';

part 'expired_internal_settings_model.g.dart';

@JsonSerializable()
class ExpiredInternalSettingsModel {
  final List<String> keys;

  const ExpiredInternalSettingsModel({
    required this.keys,
  });

  static const ExpiredInternalSettingsModel defaultValue =
      ExpiredInternalSettingsModel(
    keys: <String>[],
  );

  factory ExpiredInternalSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$ExpiredInternalSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpiredInternalSettingsModelToJson(this);

  ExpiredInternalSettingsModel copyWith({
    List<String>? keys,
  }) =>
      ExpiredInternalSettingsModel(keys: keys ?? this.keys);
}
