// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_log_item_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueryLogItemClient _$QueryLogItemClientFromJson(Map<String, dynamic> json) =>
    QueryLogItemClient(
      disallowed: json['disallowed'] as bool,
      disallowedRule: json['disallowed_rule'] as String,
      name: json['name'] as String,
      whois: QueryLogItemClientWhois.fromJson(
        json['whois'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$QueryLogItemClientToJson(QueryLogItemClient instance) =>
    <String, dynamic>{
      'disallowed': instance.disallowed,
      'disallowed_rule': instance.disallowedRule,
      'name': instance.name,
      'whois': instance.whois,
    };
