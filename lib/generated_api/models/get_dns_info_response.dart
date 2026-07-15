// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dns_config.dart';
import 'dns_config_blocking_mode.dart';
import 'dns_config_upstream_mode.dart';

part 'get_dns_info_response.g.dart';

@JsonSerializable()
class GetDnsInfoResponse {
  const GetDnsInfoResponse({
    this.ratelimitSubnetSubnetLenIpv4 = 24,
    this.ratelimitSubnetSubnetLenIpv6 = 56,
    this.bootstrapDns,
    this.upstreamDns,
    this.fallbackDns,
    this.upstreamDnsFile,
    this.protectionEnabled,
    this.ratelimit,
    this.ratelimitWhitelist,
    this.blockingMode,
    this.blockingIpv4,
    this.blockingIpv6,
    this.blockedResponseTtl,
    this.protectionDisabledUntil,
    this.ednsCsEnabled,
    this.ednsCsUseCustom,
    this.ednsCsCustomIp,
    this.disableIpv6,
    this.dnssecEnabled,
    this.cacheSize,
    this.cacheTtlMin,
    this.cacheTtlMax,
    this.cacheEnabled,
    this.cacheOptimistic,
    this.upstreamMode,
    this.usePrivatePtrResolvers,
    this.resolveClients,
    this.localPtrUpstreams,
    this.upstreamTimeout,
    this.defaultLocalPtrUpstreams,
  });

  factory GetDnsInfoResponse.fromJson(Map<String, Object?> json) =>
      _$GetDnsInfoResponseFromJson(json);

  /// Bootstrap servers, port is optional after colon.  Empty value will reset it to default values.
  ///
  @JsonKey(name: 'bootstrap_dns')
  final List<String>? bootstrapDns;

  /// Upstream servers, port is optional after colon.  Empty value will reset it to default values.
  ///
  @JsonKey(name: 'upstream_dns')
  final List<String>? upstreamDns;

  /// List of fallback DNS servers used when upstream DNS servers are not responding.  Empty value will clear the list.
  ///
  @JsonKey(name: 'fallback_dns')
  final List<String>? fallbackDns;
  @JsonKey(name: 'upstream_dns_file')
  final String? upstreamDnsFile;
  @JsonKey(name: 'protection_enabled')
  final bool? protectionEnabled;
  final int? ratelimit;

  /// Length of the subnet mask for IPv4 addresses.
  @JsonKey(name: 'ratelimit_subnet_subnet_len_ipv4')
  final int ratelimitSubnetSubnetLenIpv4;

  /// Length of the subnet mask for IPv6 addresses.
  @JsonKey(name: 'ratelimit_subnet_subnet_len_ipv6')
  final int ratelimitSubnetSubnetLenIpv6;

  /// List of IP addresses excluded from rate limiting.
  @JsonKey(name: 'ratelimit_whitelist')
  final List<String>? ratelimitWhitelist;
  @JsonKey(name: 'blocking_mode')
  final DnsConfigBlockingMode? blockingMode;
  @JsonKey(name: 'blocking_ipv4')
  final String? blockingIpv4;
  @JsonKey(name: 'blocking_ipv6')
  final String? blockingIpv6;

  /// TTL for blocked responses.
  @JsonKey(name: 'blocked_response_ttl')
  final int? blockedResponseTtl;

  /// Protection is pause until this time.  Nullable.
  @JsonKey(name: 'protection_disabled_until')
  final String? protectionDisabledUntil;
  @JsonKey(name: 'edns_cs_enabled')
  final bool? ednsCsEnabled;
  @JsonKey(name: 'edns_cs_use_custom')
  final bool? ednsCsUseCustom;
  @JsonKey(name: 'edns_cs_custom_ip')
  final String? ednsCsCustomIp;
  @JsonKey(name: 'disable_ipv6')
  final bool? disableIpv6;
  @JsonKey(name: 'dnssec_enabled')
  final bool? dnssecEnabled;
  @JsonKey(name: 'cache_size')
  final int? cacheSize;
  @JsonKey(name: 'cache_ttl_min')
  final int? cacheTtlMin;
  @JsonKey(name: 'cache_ttl_max')
  final int? cacheTtlMax;

  /// Enables or disables the DNS response cache.
  ///
  /// If `cache_enabled` is `true`, the companion field `cache_size` must.
  /// be present and greater than 0, or the `dns.cache_size` setting in.
  /// the configuration file must already be greater than 0.
  ///
  @JsonKey(name: 'cache_enabled')
  final bool? cacheEnabled;
  @JsonKey(name: 'cache_optimistic')
  final bool? cacheOptimistic;

  /// Upstream modes enumeration.
  @JsonKey(name: 'upstream_mode')
  final DnsConfigUpstreamMode? upstreamMode;
  @JsonKey(name: 'use_private_ptr_resolvers')
  final bool? usePrivatePtrResolvers;
  @JsonKey(name: 'resolve_clients')
  final bool? resolveClients;

  /// Upstream servers, port is optional after colon.  Empty value will reset it to default values.
  ///
  @JsonKey(name: 'local_ptr_upstreams')
  final List<String>? localPtrUpstreams;

  /// The number of seconds to wait for a response from the upstream server
  @JsonKey(name: 'upstream_timeout')
  final int? upstreamTimeout;
  @JsonKey(name: 'default_local_ptr_upstreams')
  final List<String>? defaultLocalPtrUpstreams;

  Map<String, Object?> toJson() => _$GetDnsInfoResponseToJson(this);
}
