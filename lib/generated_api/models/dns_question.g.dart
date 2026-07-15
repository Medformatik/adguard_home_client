// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dns_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DnsQuestion _$DnsQuestionFromJson(Map<String, dynamic> json) => DnsQuestion(
  classValue: json['class'] as String?,
  name: json['name'] as String?,
  unicodeName: json['unicode_name'] as String?,
  type: json['type'] as String?,
);

Map<String, dynamic> _$DnsQuestionToJson(DnsQuestion instance) =>
    <String, dynamic>{
      'class': instance.classValue,
      'name': instance.name,
      'unicode_name': instance.unicodeName,
      'type': instance.type,
    };
