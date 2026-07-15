// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'get_stats_config_response.g.dart';

/// Statistics configuration
@JsonSerializable()
class GetStatsConfigResponse {
  const GetStatsConfigResponse({
    required this.enabled,
    required this.interval,
    required this.ignored,
    this.ignoredEnabled,
  });

  factory GetStatsConfigResponse.fromJson(Map<String, Object?> json) =>
      _$GetStatsConfigResponseFromJson(json);

  /// Are statistics enabled
  final bool enabled;

  /// Statistics rotation interval in milliseconds
  final num interval;

  /// List of host names, which should not be counted
  final List<String> ignored;

  /// If true, the host names in the `ignored` array are excluded from the statistics.
  ///
  @JsonKey(name: 'ignored_enabled')
  final bool? ignoredEnabled;

  Map<String, Object?> toJson() => _$GetStatsConfigResponseToJson(this);
}
