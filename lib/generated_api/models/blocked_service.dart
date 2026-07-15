// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'blocked_service.g.dart';

@JsonSerializable()
class BlockedService {
  const BlockedService({
    required this.iconSvg,
    required this.id,
    required this.name,
    required this.rules,
    this.groupId,
  });

  factory BlockedService.fromJson(Map<String, Object?> json) =>
      _$BlockedServiceFromJson(json);

  /// The SVG icon as a Base64-encoded string to make it easier to embed it into a data URL.
  ///
  @JsonKey(name: 'icon_svg')
  final String iconSvg;

  /// The ID of this service.
  ///
  final String id;

  /// The human-readable name of this service.
  ///
  final String name;

  /// The array of the filtering rules.
  ///
  final List<String> rules;

  /// The ID of the group, that the service belongs to.
  ///
  @JsonKey(name: 'group_id')
  final String? groupId;

  Map<String, Object?> toJson() => _$BlockedServiceToJson(this);
}
