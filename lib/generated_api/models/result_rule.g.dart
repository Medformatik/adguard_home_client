// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultRule _$ResultRuleFromJson(Map<String, dynamic> json) => ResultRule(
  filterListId: (json['filter_list_id'] as num?)?.toInt(),
  text: json['text'] as String?,
);

Map<String, dynamic> _$ResultRuleToJson(ResultRule instance) =>
    <String, dynamic>{
      'filter_list_id': instance.filterListId,
      'text': instance.text,
    };
