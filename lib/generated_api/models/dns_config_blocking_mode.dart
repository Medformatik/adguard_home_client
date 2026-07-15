// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum DnsConfigBlockingMode {
  /// The name has been replaced because it contains a keyword. Original name: `default`.
  @JsonValue('default')
  valueDefault('default'),
  @JsonValue('refused')
  refused('refused'),
  @JsonValue('nxdomain')
  nxdomain('nxdomain'),
  @JsonValue('null_ip')
  nullIp('null_ip'),
  @JsonValue('custom_ip')
  customIp('custom_ip'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const DnsConfigBlockingMode(this.json);

  factory DnsConfigBlockingMode.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<DnsConfigBlockingMode> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
