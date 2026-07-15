// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueryLog _$QueryLogFromJson(Map<String, dynamic> json) => QueryLog(
  oldest: json['oldest'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => QueryLogItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QueryLogToJson(QueryLog instance) => <String, dynamic>{
  'oldest': instance.oldest,
  'data': instance.data,
};
