// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'dns_question.g.dart';

/// DNS question section
@JsonSerializable()
class DnsQuestion {
  const DnsQuestion({this.classValue, this.name, this.unicodeName, this.type});

  factory DnsQuestion.fromJson(Map<String, Object?> json) =>
      _$DnsQuestionFromJson(json);

  /// The name has been replaced because it contains a keyword. Original name: `class`.
  @JsonKey(name: 'class')
  final String? classValue;
  final String? name;
  @JsonKey(name: 'unicode_name')
  final String? unicodeName;
  final String? type;

  Map<String, Object?> toJson() => _$DnsQuestionToJson(this);
}
