// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'stats_config_interval.dart';

part 'stats_config.g.dart';

/// Statistics configuration
@JsonSerializable()
class StatsConfig {
  const StatsConfig({this.interval});

  factory StatsConfig.fromJson(Map<String, Object?> json) =>
      _$StatsConfigFromJson(json);

  /// Time period to keep the data.  `0` means that the statistics is disabled.
  ///
  final StatsConfigInterval? interval;

  Map<String, Object?> toJson() => _$StatsConfigToJson(this);
}
