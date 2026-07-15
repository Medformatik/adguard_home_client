// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upstreams_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpstreamsConfig _$UpstreamsConfigFromJson(Map<String, dynamic> json) =>
    UpstreamsConfig(
      bootstrapDns: (json['bootstrap_dns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      upstreamDns: (json['upstream_dns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      fallbackDns: (json['fallback_dns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      privateUpstream: (json['private_upstream'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UpstreamsConfigToJson(UpstreamsConfig instance) =>
    <String, dynamic>{
      'bootstrap_dns': instance.bootstrapDns,
      'upstream_dns': instance.upstreamDns,
      'fallback_dns': instance.fallbackDns,
      'private_upstream': instance.privateUpstream,
    };
