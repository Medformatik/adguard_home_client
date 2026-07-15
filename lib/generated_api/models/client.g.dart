// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Client _$ClientFromJson(Map<String, dynamic> json) => Client(
  name: json['name'] as String?,
  ids: (json['ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
  useGlobalSettings: json['use_global_settings'] as bool?,
  filteringEnabled: json['filtering_enabled'] as bool?,
  parentalEnabled: json['parental_enabled'] as bool?,
  safebrowsingEnabled: json['safebrowsing_enabled'] as bool?,
  safesearchEnabled: json['safesearch_enabled'] as bool?,
  safeSearch: json['safe_search'] == null
      ? null
      : SafeSearchConfig.fromJson(json['safe_search'] as Map<String, dynamic>),
  useGlobalBlockedServices: json['use_global_blocked_services'] as bool?,
  blockedServicesSchedule: json['blocked_services_schedule'] == null
      ? null
      : Schedule.fromJson(
          json['blocked_services_schedule'] as Map<String, dynamic>,
        ),
  blockedServices: (json['blocked_services'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  upstreams: (json['upstreams'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  ignoreQuerylog: json['ignore_querylog'] as bool?,
  ignoreStatistics: json['ignore_statistics'] as bool?,
  upstreamsCacheEnabled: json['upstreams_cache_enabled'] as bool?,
  upstreamsCacheSize: (json['upstreams_cache_size'] as num?)?.toInt(),
);

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
  'name': instance.name,
  'ids': instance.ids,
  'use_global_settings': instance.useGlobalSettings,
  'filtering_enabled': instance.filteringEnabled,
  'parental_enabled': instance.parentalEnabled,
  'safebrowsing_enabled': instance.safebrowsingEnabled,
  'safesearch_enabled': instance.safesearchEnabled,
  'safe_search': instance.safeSearch,
  'use_global_blocked_services': instance.useGlobalBlockedServices,
  'blocked_services_schedule': instance.blockedServicesSchedule,
  'blocked_services': instance.blockedServices,
  'upstreams': instance.upstreams,
  'tags': instance.tags,
  'ignore_querylog': instance.ignoreQuerylog,
  'ignore_statistics': instance.ignoreStatistics,
  'upstreams_cache_enabled': instance.upstreamsCacheEnabled,
  'upstreams_cache_size': instance.upstreamsCacheSize,
};
