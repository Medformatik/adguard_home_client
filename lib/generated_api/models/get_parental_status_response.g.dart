// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_parental_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetParentalStatusResponse _$GetParentalStatusResponseFromJson(
  Map<String, dynamic> json,
) => GetParentalStatusResponse(
  enable: json['enable'] as bool?,
  sensitivity: (json['sensitivity'] as num?)?.toInt(),
);

Map<String, dynamic> _$GetParentalStatusResponseToJson(
  GetParentalStatusResponse instance,
) => <String, dynamic>{
  'enable': instance.enable,
  'sensitivity': instance.sensitivity,
};
