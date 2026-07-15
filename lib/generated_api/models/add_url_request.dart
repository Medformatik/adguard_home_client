// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'add_url_request.g.dart';

/// /add_url request data
@JsonSerializable()
class AddUrlRequest {
  const AddUrlRequest({this.name, this.url, this.whitelist});

  factory AddUrlRequest.fromJson(Map<String, Object?> json) =>
      _$AddUrlRequestFromJson(json);

  final String? name;

  /// URL or an absolute path to the file containing filtering rules.
  ///
  final String? url;
  final bool? whitelist;

  Map<String, Object?> toJson() => _$AddUrlRequestToJson(this);
}
