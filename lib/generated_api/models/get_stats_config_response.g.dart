// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_stats_config_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetStatsConfigResponse _$GetStatsConfigResponseFromJson(
  Map<String, dynamic> json,
) => GetStatsConfigResponse(
  enabled: json['enabled'] as bool,
  interval: json['interval'] as num,
  ignored: (json['ignored'] as List<dynamic>).map((e) => e as String).toList(),
  ignoredEnabled: json['ignored_enabled'] as bool?,
);

Map<String, dynamic> _$GetStatsConfigResponseToJson(
  GetStatsConfigResponse instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'interval': instance.interval,
  'ignored': instance.ignored,
  'ignored_enabled': instance.ignoredEnabled,
};
