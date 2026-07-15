// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'filter.dart';

part 'filter_status.g.dart';

/// Filtering settings
@JsonSerializable()
class FilterStatus {
  const FilterStatus({
    this.enabled,
    this.interval,
    this.filters,
    this.whitelistFilters,
    this.userRules,
  });

  factory FilterStatus.fromJson(Map<String, Object?> json) =>
      _$FilterStatusFromJson(json);

  final bool? enabled;
  final int? interval;
  final List<Filter>? filters;
  @JsonKey(name: 'whitelist_filters')
  final List<Filter>? whitelistFilters;
  @JsonKey(name: 'user_rules')
  final List<String>? userRules;

  Map<String, Object?> toJson() => _$FilterStatusToJson(this);
}
