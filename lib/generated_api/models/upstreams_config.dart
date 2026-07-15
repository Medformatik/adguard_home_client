// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'upstreams_config.g.dart';

/// Upstream configuration to be tested
@JsonSerializable()
class UpstreamsConfig {
  const UpstreamsConfig({
    required this.bootstrapDns,
    required this.upstreamDns,
    this.fallbackDns,
    this.privateUpstream,
  });

  factory UpstreamsConfig.fromJson(Map<String, Object?> json) =>
      _$UpstreamsConfigFromJson(json);

  /// Bootstrap DNS servers, port is optional after colon.
  ///
  @JsonKey(name: 'bootstrap_dns')
  final List<String> bootstrapDns;

  /// Upstream DNS servers, port is optional after colon.
  ///
  @JsonKey(name: 'upstream_dns')
  final List<String> upstreamDns;

  /// Fallback DNS servers, port is optional after colon.
  ///
  @JsonKey(name: 'fallback_dns')
  final List<String>? fallbackDns;

  /// Local PTR resolvers, port is optional after colon.
  ///
  @JsonKey(name: 'private_upstream')
  final List<String>? privateUpstream;

  Map<String, Object?> toJson() => _$UpstreamsConfigToJson(this);
}
