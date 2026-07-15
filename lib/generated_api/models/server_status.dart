// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'server_status.g.dart';

/// AdGuard Home server status and configuration
@JsonSerializable()
class ServerStatus {
  const ServerStatus({
    required this.dnsAddresses,
    required this.dnsPort,
    required this.httpPort,
    required this.protectionEnabled,
    required this.running,
    required this.version,
    required this.language,
    this.protectionDisabledDuration,
    this.dhcpAvailable,
    this.startTime,
  });

  factory ServerStatus.fromJson(Map<String, Object?> json) =>
      _$ServerStatusFromJson(json);

  @JsonKey(name: 'dns_addresses')
  final List<String> dnsAddresses;
  @JsonKey(name: 'dns_port')
  final int dnsPort;
  @JsonKey(name: 'http_port')
  final int httpPort;
  @JsonKey(name: 'protection_enabled')
  final bool protectionEnabled;
  @JsonKey(name: 'protection_disabled_duration')
  final int? protectionDisabledDuration;
  @JsonKey(name: 'dhcp_available')
  final bool? dhcpAvailable;
  final bool running;
  final String version;
  final String language;

  /// Start time of the web API server (Unix time in milliseconds).
  @JsonKey(name: 'start_time')
  final double? startTime;

  Map<String, Object?> toJson() => _$ServerStatusToJson(this);
}
