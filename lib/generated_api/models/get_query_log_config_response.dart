// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'get_query_log_config_response.g.dart';

/// Query log configuration
@JsonSerializable()
class GetQueryLogConfigResponse {
  const GetQueryLogConfigResponse({
    required this.enabled,
    required this.interval,
    required this.anonymizeClientIp,
    required this.ignored,
    this.ignoredEnabled,
  });

  factory GetQueryLogConfigResponse.fromJson(Map<String, Object?> json) =>
      _$GetQueryLogConfigResponseFromJson(json);

  /// Is query log enabled
  final bool enabled;

  /// Time period for query log rotation in milliseconds.
  ///
  final num interval;

  /// Anonymize clients' IP addresses
  @JsonKey(name: 'anonymize_client_ip')
  final bool anonymizeClientIp;

  /// List of host names, which should not be written to log
  final List<String> ignored;

  /// If true, the host names in the `ignored` array are excluded from the query log.
  ///
  @JsonKey(name: 'ignored_enabled')
  final bool? ignoredEnabled;

  Map<String, Object?> toJson() => _$GetQueryLogConfigResponseToJson(this);
}
