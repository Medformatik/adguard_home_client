// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ResponseStatus {
  @JsonValue('all')
  all('all'),
  @JsonValue('filtered')
  filtered('filtered'),
  @JsonValue('blocked')
  blocked('blocked'),
  @JsonValue('blocked_safebrowsing')
  blockedSafebrowsing('blocked_safebrowsing'),
  @JsonValue('blocked_parental')
  blockedParental('blocked_parental'),
  @JsonValue('whitelisted')
  whitelisted('whitelisted'),
  @JsonValue('rewritten')
  rewritten('rewritten'),
  @JsonValue('safe_search')
  safeSearch('safe_search'),
  @JsonValue('processed')
  processed('processed'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const ResponseStatus(this.json);

  factory ResponseStatus.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<ResponseStatus> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
