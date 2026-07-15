// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_rules_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetRulesRequest _$SetRulesRequestFromJson(Map<String, dynamic> json) =>
    SetRulesRequest(
      rules: (json['rules'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SetRulesRequestToJson(SetRulesRequest instance) =>
    <String, dynamic>{'rules': instance.rules};
