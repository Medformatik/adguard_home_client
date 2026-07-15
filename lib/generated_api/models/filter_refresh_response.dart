// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'filter_refresh_response.g.dart';

/// /filtering/refresh response data
@JsonSerializable()
class FilterRefreshResponse {
  const FilterRefreshResponse({this.updated});

  factory FilterRefreshResponse.fromJson(Map<String, Object?> json) =>
      _$FilterRefreshResponseFromJson(json);

  final int? updated;

  Map<String, Object?> toJson() => _$FilterRefreshResponseToJson(this);
}
