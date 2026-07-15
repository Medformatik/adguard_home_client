// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_query_log_config_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetQueryLogConfigResponse _$GetQueryLogConfigResponseFromJson(
  Map<String, dynamic> json,
) => GetQueryLogConfigResponse(
  enabled: json['enabled'] as bool,
  interval: json['interval'] as num,
  anonymizeClientIp: json['anonymize_client_ip'] as bool,
  ignored: (json['ignored'] as List<dynamic>).map((e) => e as String).toList(),
  ignoredEnabled: json['ignored_enabled'] as bool?,
);

Map<String, dynamic> _$GetQueryLogConfigResponseToJson(
  GetQueryLogConfigResponse instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'interval': instance.interval,
  'anonymize_client_ip': instance.anonymizeClientIp,
  'ignored': instance.ignored,
  'ignored_enabled': instance.ignoredEnabled,
};
