// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FilterStatus _$FilterStatusFromJson(Map<String, dynamic> json) => FilterStatus(
  enabled: json['enabled'] as bool?,
  interval: (json['interval'] as num?)?.toInt(),
  filters: (json['filters'] as List<dynamic>?)
      ?.map((e) => Filter.fromJson(e as Map<String, dynamic>))
      .toList(),
  whitelistFilters: (json['whitelist_filters'] as List<dynamic>?)
      ?.map((e) => Filter.fromJson(e as Map<String, dynamic>))
      .toList(),
  userRules: (json['user_rules'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$FilterStatusToJson(FilterStatus instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'interval': instance.interval,
      'filters': instance.filters,
      'whitelist_filters': instance.whitelistFilters,
      'user_rules': instance.userRules,
    };
