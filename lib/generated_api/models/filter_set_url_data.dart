// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'filter_set_url_data.g.dart';

/// Filter update data
@JsonSerializable()
class FilterSetUrlData {
  const FilterSetUrlData({
    required this.enabled,
    required this.name,
    required this.url,
  });

  factory FilterSetUrlData.fromJson(Map<String, Object?> json) =>
      _$FilterSetUrlDataFromJson(json);

  final bool enabled;
  final String name;
  final String url;

  Map<String, Object?> toJson() => _$FilterSetUrlDataToJson(this);
}
