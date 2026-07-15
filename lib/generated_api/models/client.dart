// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'safe_search_config.dart';
import 'schedule.dart';

part 'client.g.dart';

/// Client information.
@JsonSerializable()
class Client {
  const Client({
    this.name,
    this.ids,
    this.useGlobalSettings,
    this.filteringEnabled,
    this.parentalEnabled,
    this.safebrowsingEnabled,
    this.safesearchEnabled,
    this.safeSearch,
    this.useGlobalBlockedServices,
    this.blockedServicesSchedule,
    this.blockedServices,
    this.upstreams,
    this.tags,
    this.ignoreQuerylog,
    this.ignoreStatistics,
    this.upstreamsCacheEnabled,
    this.upstreamsCacheSize,
  });

  factory Client.fromJson(Map<String, Object?> json) => _$ClientFromJson(json);

  /// Name
  final String? name;

  /// IP, CIDR, MAC, or ClientID.
  final List<String>? ids;
  @JsonKey(name: 'use_global_settings')
  final bool? useGlobalSettings;
  @JsonKey(name: 'filtering_enabled')
  final bool? filteringEnabled;
  @JsonKey(name: 'parental_enabled')
  final bool? parentalEnabled;
  @JsonKey(name: 'safebrowsing_enabled')
  final bool? safebrowsingEnabled;
  @JsonKey(name: 'safesearch_enabled')
  final bool? safesearchEnabled;
  @JsonKey(name: 'safe_search')
  final SafeSearchConfig? safeSearch;
  @JsonKey(name: 'use_global_blocked_services')
  final bool? useGlobalBlockedServices;
  @JsonKey(name: 'blocked_services_schedule')
  final Schedule? blockedServicesSchedule;
  @JsonKey(name: 'blocked_services')
  final List<String>? blockedServices;
  final List<String>? upstreams;
  final List<String>? tags;

  /// NOTE: If `ignore_querylog` is not set in HTTP API `GET /clients/add`.
  /// request then default value (false) will be used.
  ///
  /// If `ignore_querylog` is not set in HTTP API `GET /clients/update`.
  /// request then the existing value will not be changed.
  ///
  /// This behaviour can be changed in the future versions.
  ///
  @JsonKey(name: 'ignore_querylog')
  final bool? ignoreQuerylog;

  /// NOTE: If `ignore_statistics` is not set in HTTP API `GET.
  /// /clients/add` request then default value (false) will be used.
  ///
  /// If `ignore_statistics` is not set in HTTP API `GET /clients/update`.
  /// request then the existing value will not be changed.
  ///
  /// This behaviour can be changed in the future versions.
  ///
  @JsonKey(name: 'ignore_statistics')
  final bool? ignoreStatistics;

  /// NOTE: If `upstreams_cache_enabled` is not set in HTTP API.
  /// `GET /clients/add` request then default value (false) will be used.
  ///
  /// If `upstreams_cache_enabled` is not set in HTTP API.
  /// `GET /clients/update` request then the existing value will not be.
  /// changed.
  ///
  /// This behaviour can be changed in the future versions.
  ///
  @JsonKey(name: 'upstreams_cache_enabled')
  final bool? upstreamsCacheEnabled;

  /// NOTE: If `upstreams_cache_enabled` is not set in HTTP API.
  /// `GET /clients/update` request then the existing value will not be.
  /// changed.
  ///
  /// This behaviour can be changed in the future versions.
  ///
  @JsonKey(name: 'upstreams_cache_size')
  final int? upstreamsCacheSize;

  Map<String, Object?> toJson() => _$ClientToJson(this);
}
