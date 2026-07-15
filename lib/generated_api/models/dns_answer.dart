// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'dns_answer.g.dart';

/// DNS answer section
@JsonSerializable()
class DnsAnswer {
  const DnsAnswer({this.ttl, this.type, this.value});

  factory DnsAnswer.fromJson(Map<String, Object?> json) =>
      _$DnsAnswerFromJson(json);

  final int? ttl;
  final String? type;
  final String? value;

  Map<String, Object?> toJson() => _$DnsAnswerToJson(this);
}
