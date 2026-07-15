// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_set_url.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FilterSetUrl _$FilterSetUrlFromJson(Map<String, dynamic> json) => FilterSetUrl(
  data: json['data'] == null
      ? null
      : FilterSetUrlData.fromJson(json['data'] as Map<String, dynamic>),
  url: json['url'] as String?,
  whitelist: json['whitelist'] as bool?,
);

Map<String, dynamic> _$FilterSetUrlToJson(FilterSetUrl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'url': instance.url,
      'whitelist': instance.whitelist,
    };
