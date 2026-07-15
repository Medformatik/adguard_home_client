// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientUpdate _$ClientUpdateFromJson(Map<String, dynamic> json) => ClientUpdate(
  name: json['name'] as String?,
  data: json['data'] == null
      ? null
      : Client.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ClientUpdateToJson(ClientUpdate instance) =>
    <String, dynamic>{'name': instance.name, 'data': instance.data};
