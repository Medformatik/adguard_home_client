// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'rewrite_entry.dart';

part 'rewrite_update.g.dart';

/// Rewrite rule update object
@JsonSerializable()
class RewriteUpdate {
  const RewriteUpdate({this.target, this.update});

  factory RewriteUpdate.fromJson(Map<String, Object?> json) =>
      _$RewriteUpdateFromJson(json);

  final RewriteEntry? target;
  final RewriteEntry? update;

  Map<String, Object?> toJson() => _$RewriteUpdateToJson(this);
}
