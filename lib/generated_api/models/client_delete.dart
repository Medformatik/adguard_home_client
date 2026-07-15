// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'client_delete.g.dart';

/// Client delete request
@JsonSerializable()
class ClientDelete {
  const ClientDelete({this.name});

  factory ClientDelete.fromJson(Map<String, Object?> json) =>
      _$ClientDeleteFromJson(json);

  final String? name;

  Map<String, Object?> toJson() => _$ClientDeleteToJson(this);
}
