// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Request filtering status.
@JsonEnum()
enum FilteringReason {
  @JsonValue('NotFilteredNotFound')
  notFilteredNotFound('NotFilteredNotFound'),
  @JsonValue('NotFilteredWhiteList')
  notFilteredWhiteList('NotFilteredWhiteList'),
  @JsonValue('NotFilteredError')
  notFilteredError('NotFilteredError'),
  @JsonValue('FilteredBlackList')
  filteredBlackList('FilteredBlackList'),
  @JsonValue('FilteredSafeBrowsing')
  filteredSafeBrowsing('FilteredSafeBrowsing'),
  @JsonValue('FilteredParental')
  filteredParental('FilteredParental'),
  @JsonValue('FilteredInvalid')
  filteredInvalid('FilteredInvalid'),
  @JsonValue('FilteredSafeSearch')
  filteredSafeSearch('FilteredSafeSearch'),
  @JsonValue('FilteredBlockedService')
  filteredBlockedService('FilteredBlockedService'),
  @JsonValue('Rewrite')
  rewrite('Rewrite'),
  @JsonValue('RewriteEtcHosts')
  rewriteEtcHosts('RewriteEtcHosts'),
  @JsonValue('RewriteRule')
  rewriteRule('RewriteRule'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const FilteringReason(this.json);

  factory FilteringReason.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<FilteringReason> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
