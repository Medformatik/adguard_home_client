// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'top_array_entry.g.dart';

/// Represent the number of hits or time duration per key (url, domain, or client IP).
///
@JsonSerializable()
class TopArrayEntry {
  const TopArrayEntry({this.domainOrIp});

  factory TopArrayEntry.fromJson(Map<String, Object?> json) =>
      _$TopArrayEntryFromJson(json);

  @JsonKey(name: 'domain_or_ip')
  final num? domainOrIp;

  Map<String, Object?> toJson() => _$TopArrayEntryToJson(this);
}
