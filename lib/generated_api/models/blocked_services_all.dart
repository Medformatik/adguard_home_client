// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'blocked_service.dart';

part 'blocked_services_all.g.dart';

@JsonSerializable()
class BlockedServicesAll {
  const BlockedServicesAll({
    required this.blockedServices,
    required this.groups,
  });

  factory BlockedServicesAll.fromJson(Map<String, Object?> json) =>
      _$BlockedServicesAllFromJson(json);

  @JsonKey(name: 'blocked_services')
  final List<BlockedService> blockedServices;
  final dynamic groups;

  Map<String, Object?> toJson() => _$BlockedServicesAllToJson(this);
}
