// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'get_safebrowsing_status_response.g.dart';

@JsonSerializable()
class GetSafebrowsingStatusResponse {
  const GetSafebrowsingStatusResponse({this.enabled});

  factory GetSafebrowsingStatusResponse.fromJson(Map<String, Object?> json) =>
      _$GetSafebrowsingStatusResponseFromJson(json);

  final bool? enabled;

  Map<String, Object?> toJson() => _$GetSafebrowsingStatusResponseToJson(this);
}
