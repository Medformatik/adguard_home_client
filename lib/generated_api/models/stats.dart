// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'stats_time_units.dart';
import 'top_array_entry.dart';

part 'stats.g.dart';

/// Server statistics data
@JsonSerializable()
class Stats {
  const Stats({
    this.timeUnits,
    this.numDnsQueries,
    this.numBlockedFiltering,
    this.numReplacedSafebrowsing,
    this.numReplacedSafesearch,
    this.numReplacedParental,
    this.avgProcessingTime,
    this.topQueriedDomains,
    this.topClients,
    this.topBlockedDomains,
    this.topUpstreamsResponses,
    this.topUpstreamsAvgTime,
    this.dnsQueries,
    this.blockedFiltering,
    this.replacedSafebrowsing,
    this.replacedParental,
  });

  factory Stats.fromJson(Map<String, Object?> json) => _$StatsFromJson(json);

  /// Time units
  @JsonKey(name: 'time_units')
  final StatsTimeUnits? timeUnits;

  /// Total number of DNS queries
  @JsonKey(name: 'num_dns_queries')
  final int? numDnsQueries;

  /// Number of requests blocked by filtering rules
  @JsonKey(name: 'num_blocked_filtering')
  final int? numBlockedFiltering;

  /// Number of requests blocked by safebrowsing module
  @JsonKey(name: 'num_replaced_safebrowsing')
  final int? numReplacedSafebrowsing;

  /// Number of requests blocked by safesearch module
  @JsonKey(name: 'num_replaced_safesearch')
  final int? numReplacedSafesearch;

  /// Number of blocked adult websites
  @JsonKey(name: 'num_replaced_parental')
  final int? numReplacedParental;

  /// Average time in seconds on processing a DNS request
  @JsonKey(name: 'avg_processing_time')
  final double? avgProcessingTime;
  @JsonKey(name: 'top_queried_domains')
  final List<TopArrayEntry>? topQueriedDomains;
  @JsonKey(name: 'top_clients')
  final List<TopArrayEntry>? topClients;
  @JsonKey(name: 'top_blocked_domains')
  final List<TopArrayEntry>? topBlockedDomains;

  /// Total number of responses from each upstream.
  @JsonKey(name: 'top_upstreams_responses')
  final List<TopArrayEntry>? topUpstreamsResponses;

  /// Average processing time in seconds of requests from each upstream.
  ///
  @JsonKey(name: 'top_upstreams_avg_time')
  final List<TopArrayEntry>? topUpstreamsAvgTime;
  @JsonKey(name: 'dns_queries')
  final List<int>? dnsQueries;
  @JsonKey(name: 'blocked_filtering')
  final List<int>? blockedFiltering;
  @JsonKey(name: 'replaced_safebrowsing')
  final List<int>? replacedSafebrowsing;
  @JsonKey(name: 'replaced_parental')
  final List<int>? replacedParental;

  Map<String, Object?> toJson() => _$StatsToJson(this);
}
