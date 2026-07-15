// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'query_log_item_client_whois.g.dart';

/// Client WHOIS information, if any.
///
@JsonSerializable()
class QueryLogItemClientWhois {
  const QueryLogItemClientWhois({this.city, this.country, this.orgname});

  factory QueryLogItemClientWhois.fromJson(Map<String, Object?> json) =>
      _$QueryLogItemClientWhoisFromJson(json);

  /// City, if any.
  ///
  final String? city;

  /// Country, if any.
  ///
  final String? country;

  /// Organization name, if any.
  ///
  final String? orgname;

  Map<String, Object?> toJson() => _$QueryLogItemClientWhoisToJson(this);
}
