// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'service_group.g.dart';

@JsonSerializable()
class ServiceGroup {
  const ServiceGroup({required this.id});

  factory ServiceGroup.fromJson(Map<String, Object?> json) =>
      _$ServiceGroupFromJson(json);

  /// The ID of this group.
  ///
  final String id;

  Map<String, Object?> toJson() => _$ServiceGroupToJson(this);
}
