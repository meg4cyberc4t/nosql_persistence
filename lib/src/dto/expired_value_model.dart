import 'package:json_annotation/json_annotation.dart';

part 'expired_value_model.g.dart';

@JsonSerializable()
class ExpiredValueModel {
  final String value;
  final DateTime startDate;
  final Duration expirationDuration;

  ExpiredValueModel({
    required this.value,
    required this.expirationDuration,
    required this.startDate,
  });

  factory ExpiredValueModel.fromJson(Map<String, dynamic> json) =>
      _$ExpiredValueModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpiredValueModelToJson(this);
}
