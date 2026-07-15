// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'remove_url_request.g.dart';

/// /remove_url request data
@JsonSerializable()
class RemoveUrlRequest {
  const RemoveUrlRequest({this.url, this.whitelist});

  factory RemoveUrlRequest.fromJson(Map<String, Object?> json) =>
      _$RemoveUrlRequestFromJson(json);

  /// Previously added URL containing filtering rules
  final String? url;
  final bool? whitelist;

  Map<String, Object?> toJson() => _$RemoveUrlRequestToJson(this);
}
