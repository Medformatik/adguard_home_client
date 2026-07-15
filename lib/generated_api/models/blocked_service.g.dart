// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockedService _$BlockedServiceFromJson(Map<String, dynamic> json) =>
    BlockedService(
      iconSvg: json['icon_svg'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      rules: (json['rules'] as List<dynamic>).map((e) => e as String).toList(),
      groupId: json['group_id'] as String?,
    );

Map<String, dynamic> _$BlockedServiceToJson(BlockedService instance) =>
    <String, dynamic>{
      'icon_svg': instance.iconSvg,
      'id': instance.id,
      'name': instance.name,
      'rules': instance.rules,
      'group_id': instance.groupId,
    };
