// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'set_rules_request.g.dart';

/// Custom filtering rules setting request.
@JsonSerializable()
class SetRulesRequest {
  const SetRulesRequest({this.rules});

  factory SetRulesRequest.fromJson(Map<String, Object?> json) =>
      _$SetRulesRequestFromJson(json);

  final List<String>? rules;

  Map<String, Object?> toJson() => _$SetRulesRequestToJson(this);
}
