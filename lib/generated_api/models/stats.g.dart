// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stats _$StatsFromJson(Map<String, dynamic> json) => Stats(
  timeUnits: json['time_units'] == null
      ? null
      : StatsTimeUnits.fromJson(json['time_units'] as String),
  numDnsQueries: (json['num_dns_queries'] as num?)?.toInt(),
  numBlockedFiltering: (json['num_blocked_filtering'] as num?)?.toInt(),
  numReplacedSafebrowsing: (json['num_replaced_safebrowsing'] as num?)?.toInt(),
  numReplacedSafesearch: (json['num_replaced_safesearch'] as num?)?.toInt(),
  numReplacedParental: (json['num_replaced_parental'] as num?)?.toInt(),
  avgProcessingTime: (json['avg_processing_time'] as num?)?.toDouble(),
  topQueriedDomains: (json['top_queried_domains'] as List<dynamic>?)
      ?.map((e) => TopArrayEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  topClients: (json['top_clients'] as List<dynamic>?)
      ?.map((e) => TopArrayEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  topBlockedDomains: (json['top_blocked_domains'] as List<dynamic>?)
      ?.map((e) => TopArrayEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  topUpstreamsResponses: (json['top_upstreams_responses'] as List<dynamic>?)
      ?.map((e) => TopArrayEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  topUpstreamsAvgTime: (json['top_upstreams_avg_time'] as List<dynamic>?)
      ?.map((e) => TopArrayEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  dnsQueries: (json['dns_queries'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  blockedFiltering: (json['blocked_filtering'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  replacedSafebrowsing: (json['replaced_safebrowsing'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  replacedParental: (json['replaced_parental'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$StatsToJson(Stats instance) => <String, dynamic>{
  'time_units': _$StatsTimeUnitsEnumMap[instance.timeUnits],
  'num_dns_queries': instance.numDnsQueries,
  'num_blocked_filtering': instance.numBlockedFiltering,
  'num_replaced_safebrowsing': instance.numReplacedSafebrowsing,
  'num_replaced_safesearch': instance.numReplacedSafesearch,
  'num_replaced_parental': instance.numReplacedParental,
  'avg_processing_time': instance.avgProcessingTime,
  'top_queried_domains': instance.topQueriedDomains,
  'top_clients': instance.topClients,
  'top_blocked_domains': instance.topBlockedDomains,
  'top_upstreams_responses': instance.topUpstreamsResponses,
  'top_upstreams_avg_time': instance.topUpstreamsAvgTime,
  'dns_queries': instance.dnsQueries,
  'blocked_filtering': instance.blockedFiltering,
  'replaced_safebrowsing': instance.replacedSafebrowsing,
  'replaced_parental': instance.replacedParental,
};

const _$StatsTimeUnitsEnumMap = {
  StatsTimeUnits.hours: 'hours',
  StatsTimeUnits.days: 'days',
  StatsTimeUnits.$unknown: r'$unknown',
};
