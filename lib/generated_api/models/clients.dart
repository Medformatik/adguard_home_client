// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'clients_array.dart';
import 'clients_auto_array.dart';

part 'clients.g.dart';

@JsonSerializable()
class Clients {
  const Clients({this.clients, this.autoClients, this.supportedTags});

  factory Clients.fromJson(Map<String, Object?> json) =>
      _$ClientsFromJson(json);

  final ClientsArray? clients;
  @JsonKey(name: 'auto_clients')
  final ClientsAutoArray? autoClients;
  @JsonKey(name: 'supported_tags')
  final List<String>? supportedTags;

  Map<String, Object?> toJson() => _$ClientsToJson(this);
}
