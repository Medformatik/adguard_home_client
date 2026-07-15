// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Filter _$FilterFromJson(Map<String, dynamic> json) => Filter(
  enabled: json['enabled'] as bool,
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  rulesCount: (json['rules_count'] as num).toInt(),
  url: json['url'] as String,
  lastUpdated: json['last_updated'] == null
      ? null
      : DateTime.parse(json['last_updated'] as String),
);

Map<String, dynamic> _$FilterToJson(Filter instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'id': instance.id,
  'last_updated': instance.lastUpdated?.toIso8601String(),
  'name': instance.name,
  'rules_count': instance.rulesCount,
  'url': instance.url,
};
