// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remove_url_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoveUrlRequest _$RemoveUrlRequestFromJson(Map<String, dynamic> json) =>
    RemoveUrlRequest(
      url: json['url'] as String?,
      whitelist: json['whitelist'] as bool?,
    );

Map<String, dynamic> _$RemoveUrlRequestToJson(RemoveUrlRequest instance) =>
    <String, dynamic>{'url': instance.url, 'whitelist': instance.whitelist};
