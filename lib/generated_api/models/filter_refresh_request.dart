// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'filter_refresh_request.g.dart';

/// Refresh Filters request data
@JsonSerializable()
class FilterRefreshRequest {
  const FilterRefreshRequest({this.whitelist});

  factory FilterRefreshRequest.fromJson(Map<String, Object?> json) =>
      _$FilterRefreshRequestFromJson(json);

  final bool? whitelist;

  Map<String, Object?> toJson() => _$FilterRefreshRequestToJson(this);
}
