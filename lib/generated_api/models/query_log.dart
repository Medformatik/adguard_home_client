// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'query_log_item.dart';

part 'query_log.g.dart';

/// Query log
@JsonSerializable()
class QueryLog {
  const QueryLog({this.oldest, this.data});

  factory QueryLog.fromJson(Map<String, Object?> json) =>
      _$QueryLogFromJson(json);

  final String? oldest;
  final List<QueryLogItem>? data;

  Map<String, Object?> toJson() => _$QueryLogToJson(this);
}
