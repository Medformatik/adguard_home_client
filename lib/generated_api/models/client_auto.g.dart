// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_auto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientAuto _$ClientAutoFromJson(Map<String, dynamic> json) => ClientAuto(
  ip: json['ip'] as String?,
  name: json['name'] as String?,
  source: json['source'] as String?,
  whoisInfo: (json['whois_info'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$ClientAutoToJson(ClientAuto instance) =>
    <String, dynamic>{
      'ip': instance.ip,
      'name': instance.name,
      'source': instance.source,
      'whois_info': instance.whoisInfo,
    };
