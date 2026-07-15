// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'result_rule.g.dart';

/// Applied rule.
@JsonSerializable()
class ResultRule {
  const ResultRule({this.filterListId, this.text});

  factory ResultRule.fromJson(Map<String, Object?> json) =>
      _$ResultRuleFromJson(json);

  /// In case if there's a rule applied to this DNS request, this is ID of the filter list that the rule belongs to.
  ///
  @JsonKey(name: 'filter_list_id')
  final int? filterListId;

  /// The text of the filtering rule applied to the request (if any).
  ///
  final String? text;

  Map<String, Object?> toJson() => _$ResultRuleToJson(this);
}
