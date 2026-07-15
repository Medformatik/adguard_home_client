// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'filter_set_url_data.dart';

part 'filter_set_url.g.dart';

/// Filtering URL settings
@JsonSerializable()
class FilterSetUrl {
  const FilterSetUrl({this.data, this.url, this.whitelist});

  factory FilterSetUrl.fromJson(Map<String, Object?> json) =>
      _$FilterSetUrlFromJson(json);

  final FilterSetUrlData? data;
  final String? url;
  final bool? whitelist;

  Map<String, Object?> toJson() => _$FilterSetUrlToJson(this);
}
