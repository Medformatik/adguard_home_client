// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'get_parental_status_response.g.dart';

@JsonSerializable()
class GetParentalStatusResponse {
  const GetParentalStatusResponse({this.enable, this.sensitivity});

  factory GetParentalStatusResponse.fromJson(Map<String, Object?> json) =>
      _$GetParentalStatusResponseFromJson(json);

  final bool? enable;
  final int? sensitivity;

  Map<String, Object?> toJson() => _$GetParentalStatusResponseToJson(this);
}
