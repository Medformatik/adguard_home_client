// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'whois_info.dart';

part 'client_auto.g.dart';

/// Auto-Client information
@JsonSerializable()
class ClientAuto {
  const ClientAuto({this.ip, this.name, this.source, this.whoisInfo});

  factory ClientAuto.fromJson(Map<String, Object?> json) =>
      _$ClientAutoFromJson(json);

  /// IP address
  final String? ip;

  /// Name
  final String? name;

  /// The source of this information
  final String? source;
  @JsonKey(name: 'whois_info')
  final WhoisInfo? whoisInfo;

  Map<String, Object?> toJson() => _$ClientAutoToJson(this);
}
