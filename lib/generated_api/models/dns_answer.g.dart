// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dns_answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DnsAnswer _$DnsAnswerFromJson(Map<String, dynamic> json) => DnsAnswer(
  ttl: (json['ttl'] as num?)?.toInt(),
  type: json['type'] as String?,
  value: json['value'] as String?,
);

Map<String, dynamic> _$DnsAnswerToJson(DnsAnswer instance) => <String, dynamic>{
  'ttl': instance.ttl,
  'type': instance.type,
  'value': instance.value,
};
