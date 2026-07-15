// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerStatus _$ServerStatusFromJson(Map<String, dynamic> json) => ServerStatus(
  dnsAddresses: (json['dns_addresses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dnsPort: (json['dns_port'] as num).toInt(),
  httpPort: (json['http_port'] as num).toInt(),
  protectionEnabled: json['protection_enabled'] as bool,
  running: json['running'] as bool,
  version: json['version'] as String,
  language: json['language'] as String,
  protectionDisabledDuration: (json['protection_disabled_duration'] as num?)
      ?.toInt(),
  dhcpAvailable: json['dhcp_available'] as bool?,
  startTime: (json['start_time'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ServerStatusToJson(ServerStatus instance) =>
    <String, dynamic>{
      'dns_addresses': instance.dnsAddresses,
      'dns_port': instance.dnsPort,
      'http_port': instance.httpPort,
      'protection_enabled': instance.protectionEnabled,
      'protection_disabled_duration': instance.protectionDisabledDuration,
      'dhcp_available': instance.dhcpAvailable,
      'running': instance.running,
      'version': instance.version,
      'language': instance.language,
      'start_time': instance.startTime,
    };
