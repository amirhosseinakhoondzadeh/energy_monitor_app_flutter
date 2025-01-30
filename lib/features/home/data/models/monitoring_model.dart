import 'package:json_annotation/json_annotation.dart';

part 'monitoring_model.g.dart';

@JsonSerializable()
class MonitoringModel {
  // Use a custom fromJson/toJson for DateTime fields
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime timestamp;

  final int value;

  MonitoringModel({
    required this.timestamp,
    required this.value,
  });

  factory MonitoringModel.fromJson(Map<String, dynamic> json) =>
      _$MonitoringModelFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoringModelToJson(this);

  /// Custom fromJson function parses an ISO-8601 string into a DateTime.
  static DateTime _fromJson(String date) => DateTime.parse(date);

  /// Custom toJson function converts a DateTime back to an ISO-8601 string.
  static String _toJson(DateTime date) => date.toIso8601String();
}
