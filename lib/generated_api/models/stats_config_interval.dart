// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Time period to keep the data.  `0` means that the statistics is disabled.
///
@JsonEnum()
enum StatsConfigInterval {
  @JsonValue(0)
  value0(0),
  @JsonValue(1)
  value1(1),
  @JsonValue(7)
  value7(7),
  @JsonValue(30)
  value30(30),
  @JsonValue(90)
  value90(90),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const StatsConfigInterval(this.json);

  factory StatsConfigInterval.fromJson(int json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final int? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<StatsConfigInterval> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
