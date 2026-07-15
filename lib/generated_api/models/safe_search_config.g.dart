// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safe_search_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SafeSearchConfig _$SafeSearchConfigFromJson(Map<String, dynamic> json) =>
    SafeSearchConfig(
      enabled: json['enabled'] as bool?,
      bing: json['bing'] as bool?,
      duckduckgo: json['duckduckgo'] as bool?,
      ecosia: json['ecosia'] as bool?,
      google: json['google'] as bool?,
      pixabay: json['pixabay'] as bool?,
      yandex: json['yandex'] as bool?,
      youtube: json['youtube'] as bool?,
    );

Map<String, dynamic> _$SafeSearchConfigToJson(SafeSearchConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'bing': instance.bing,
      'duckduckgo': instance.duckduckgo,
      'ecosia': instance.ecosia,
      'google': instance.google,
      'pixabay': instance.pixabay,
      'yandex': instance.yandex,
      'youtube': instance.youtube,
    };
