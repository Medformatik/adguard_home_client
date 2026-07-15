// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dns_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DnsConfig _$DnsConfigFromJson(Map<String, dynamic> json) => DnsConfig(
  ratelimitSubnetSubnetLenIpv4:
      (json['ratelimit_subnet_subnet_len_ipv4'] as num?)?.toInt() ?? 24,
  ratelimitSubnetSubnetLenIpv6:
      (json['ratelimit_subnet_subnet_len_ipv6'] as num?)?.toInt() ?? 56,
  bootstrapDns: (json['bootstrap_dns'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  upstreamDns: (json['upstream_dns'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  fallbackDns: (json['fallback_dns'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  upstreamDnsFile: json['upstream_dns_file'] as String?,
  protectionEnabled: json['protection_enabled'] as bool?,
  ratelimit: (json['ratelimit'] as num?)?.toInt(),
  ratelimitWhitelist: (json['ratelimit_whitelist'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  blockingMode: json['blocking_mode'] == null
      ? null
      : DnsConfigBlockingMode.fromJson(json['blocking_mode'] as String),
  blockingIpv4: json['blocking_ipv4'] as String?,
  blockingIpv6: json['blocking_ipv6'] as String?,
  blockedResponseTtl: (json['blocked_response_ttl'] as num?)?.toInt(),
  protectionDisabledUntil: json['protection_disabled_until'] as String?,
  ednsCsEnabled: json['edns_cs_enabled'] as bool?,
  ednsCsUseCustom: json['edns_cs_use_custom'] as bool?,
  ednsCsCustomIp: json['edns_cs_custom_ip'] as String?,
  disableIpv6: json['disable_ipv6'] as bool?,
  dnssecEnabled: json['dnssec_enabled'] as bool?,
  cacheSize: (json['cache_size'] as num?)?.toInt(),
  cacheTtlMin: (json['cache_ttl_min'] as num?)?.toInt(),
  cacheTtlMax: (json['cache_ttl_max'] as num?)?.toInt(),
  cacheEnabled: json['cache_enabled'] as bool?,
  cacheOptimistic: json['cache_optimistic'] as bool?,
  upstreamMode: json['upstream_mode'] == null
      ? null
      : DnsConfigUpstreamMode.fromJson(json['upstream_mode'] as String),
  usePrivatePtrResolvers: json['use_private_ptr_resolvers'] as bool?,
  resolveClients: json['resolve_clients'] as bool?,
  localPtrUpstreams: (json['local_ptr_upstreams'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  upstreamTimeout: (json['upstream_timeout'] as num?)?.toInt(),
);

Map<String, dynamic> _$DnsConfigToJson(DnsConfig instance) => <String, dynamic>{
  'bootstrap_dns': instance.bootstrapDns,
  'upstream_dns': instance.upstreamDns,
  'fallback_dns': instance.fallbackDns,
  'upstream_dns_file': instance.upstreamDnsFile,
  'protection_enabled': instance.protectionEnabled,
  'ratelimit': instance.ratelimit,
  'ratelimit_subnet_subnet_len_ipv4': instance.ratelimitSubnetSubnetLenIpv4,
  'ratelimit_subnet_subnet_len_ipv6': instance.ratelimitSubnetSubnetLenIpv6,
  'ratelimit_whitelist': instance.ratelimitWhitelist,
  'blocking_mode': _$DnsConfigBlockingModeEnumMap[instance.blockingMode],
  'blocking_ipv4': instance.blockingIpv4,
  'blocking_ipv6': instance.blockingIpv6,
  'blocked_response_ttl': instance.blockedResponseTtl,
  'protection_disabled_until': instance.protectionDisabledUntil,
  'edns_cs_enabled': instance.ednsCsEnabled,
  'edns_cs_use_custom': instance.ednsCsUseCustom,
  'edns_cs_custom_ip': instance.ednsCsCustomIp,
  'disable_ipv6': instance.disableIpv6,
  'dnssec_enabled': instance.dnssecEnabled,
  'cache_size': instance.cacheSize,
  'cache_ttl_min': instance.cacheTtlMin,
  'cache_ttl_max': instance.cacheTtlMax,
  'cache_enabled': instance.cacheEnabled,
  'cache_optimistic': instance.cacheOptimistic,
  'upstream_mode': _$DnsConfigUpstreamModeEnumMap[instance.upstreamMode],
  'use_private_ptr_resolvers': instance.usePrivatePtrResolvers,
  'resolve_clients': instance.resolveClients,
  'local_ptr_upstreams': instance.localPtrUpstreams,
  'upstream_timeout': instance.upstreamTimeout,
};

const _$DnsConfigBlockingModeEnumMap = {
  DnsConfigBlockingMode.valueDefault: 'default',
  DnsConfigBlockingMode.refused: 'refused',
  DnsConfigBlockingMode.nxdomain: 'nxdomain',
  DnsConfigBlockingMode.nullIp: 'null_ip',
  DnsConfigBlockingMode.customIp: 'custom_ip',
  DnsConfigBlockingMode.$unknown: r'$unknown',
};

const _$DnsConfigUpstreamModeEnumMap = {
  DnsConfigUpstreamMode.empty: '',
  DnsConfigUpstreamMode.fastestAddr: 'fastest_addr',
  DnsConfigUpstreamMode.loadBalance: 'load_balance',
  DnsConfigUpstreamMode.parallel: 'parallel',
  DnsConfigUpstreamMode.$unknown: r'$unknown',
};
