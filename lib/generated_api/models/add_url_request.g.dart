// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_url_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddUrlRequest _$AddUrlRequestFromJson(Map<String, dynamic> json) =>
    AddUrlRequest(
      name: json['name'] as String?,
      url: json['url'] as String?,
      whitelist: json['whitelist'] as bool?,
    );

Map<String, dynamic> _$AddUrlRequestToJson(AddUrlRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'whitelist': instance.whitelist,
    };
