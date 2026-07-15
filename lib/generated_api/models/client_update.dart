// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'client.dart';

part 'client_update.g.dart';

/// Client update request
@JsonSerializable()
class ClientUpdate {
  const ClientUpdate({this.name, this.data});

  factory ClientUpdate.fromJson(Map<String, Object?> json) =>
      _$ClientUpdateFromJson(json);

  final String? name;
  final Client? data;

  Map<String, Object?> toJson() => _$ClientUpdateToJson(this);
}
