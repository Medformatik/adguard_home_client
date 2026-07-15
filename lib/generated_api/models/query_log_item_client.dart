// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'query_log_item_client_whois.dart';

part 'query_log_item_client.g.dart';

/// Client information for a query log item.
///
@JsonSerializable()
class QueryLogItemClient {
  const QueryLogItemClient({
    required this.disallowed,
    required this.disallowedRule,
    required this.name,
    required this.whois,
  });

  factory QueryLogItemClient.fromJson(Map<String, Object?> json) =>
      _$QueryLogItemClientFromJson(json);

  /// Whether the client's IP is blocked or not.
  ///
  final bool disallowed;

  /// The rule due to which the client is allowed or blocked.
  ///
  @JsonKey(name: 'disallowed_rule')
  final String disallowedRule;

  /// Persistent client's name or runtime client's hostname.  May be empty.
  ///
  final String name;
  final QueryLogItemClientWhois whois;

  Map<String, Object?> toJson() => _$QueryLogItemClientToJson(this);
}
