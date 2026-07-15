// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Clients _$ClientsFromJson(Map<String, dynamic> json) => Clients(
  clients: (json['clients'] as List<dynamic>?)
      ?.map((e) => Client.fromJson(e as Map<String, dynamic>))
      .toList(),
  autoClients: (json['auto_clients'] as List<dynamic>?)
      ?.map((e) => ClientAuto.fromJson(e as Map<String, dynamic>))
      .toList(),
  supportedTags: (json['supported_tags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ClientsToJson(Clients instance) => <String, dynamic>{
  'clients': instance.clients,
  'auto_clients': instance.autoClients,
  'supported_tags': instance.supportedTags,
};
