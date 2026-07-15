// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'filter.g.dart';

/// Filter subscription info
@JsonSerializable()
class Filter {
  const Filter({
    required this.enabled,
    required this.id,
    required this.name,
    required this.rulesCount,
    required this.url,
    this.lastUpdated,
  });

  factory Filter.fromJson(Map<String, Object?> json) => _$FilterFromJson(json);

  final bool enabled;
  final int id;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  final String name;
  @JsonKey(name: 'rules_count')
  final int rulesCount;
  final String url;

  Map<String, Object?> toJson() => _$FilterToJson(this);
}
