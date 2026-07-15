// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'rewrite_entry.g.dart';

/// Rewrite rule
@JsonSerializable()
class RewriteEntry {
  const RewriteEntry({this.enabled = true, this.domain, this.answer});

  factory RewriteEntry.fromJson(Map<String, Object?> json) =>
      _$RewriteEntryFromJson(json);

  /// Domain name
  final String? domain;

  /// value of A, AAAA or CNAME DNS record
  final String? answer;

  /// Optional. If omitted on add, defaults to `true`. On update, omitted preserves previous value.
  ///
  final bool enabled;

  Map<String, Object?> toJson() => _$RewriteEntryToJson(this);
}
