// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_services_all.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockedServicesAll _$BlockedServicesAllFromJson(Map<String, dynamic> json) =>
    BlockedServicesAll(
      blockedServices: (json['blocked_services'] as List<dynamic>)
          .map((e) => BlockedService.fromJson(e as Map<String, dynamic>))
          .toList(),
      groups: json['groups'],
    );

Map<String, dynamic> _$BlockedServicesAllToJson(BlockedServicesAll instance) =>
    <String, dynamic>{
      'blocked_services': instance.blockedServices,
      'groups': instance.groups,
    };
