// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_set_url_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FilterSetUrlData _$FilterSetUrlDataFromJson(Map<String, dynamic> json) =>
    FilterSetUrlData(
      enabled: json['enabled'] as bool,
      name: json['name'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$FilterSetUrlDataToJson(FilterSetUrlData instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'name': instance.name,
      'url': instance.url,
    };
