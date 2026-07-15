// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_protection_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetProtectionRequest _$SetProtectionRequestFromJson(
  Map<String, dynamic> json,
) => SetProtectionRequest(
  enabled: json['enabled'] as bool,
  duration: (json['duration'] as num?)?.toInt(),
);

Map<String, dynamic> _$SetProtectionRequestToJson(
  SetProtectionRequest instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'duration': instance.duration,
};
