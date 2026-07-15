// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewrite_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewriteEntry _$RewriteEntryFromJson(Map<String, dynamic> json) => RewriteEntry(
  enabled: json['enabled'] as bool? ?? true,
  domain: json['domain'] as String?,
  answer: json['answer'] as String?,
);

Map<String, dynamic> _$RewriteEntryToJson(RewriteEntry instance) =>
    <String, dynamic>{
      'domain': instance.domain,
      'answer': instance.answer,
      'enabled': instance.enabled,
    };
