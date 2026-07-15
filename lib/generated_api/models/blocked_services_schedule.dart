// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'schedule.dart';

part 'blocked_services_schedule.g.dart';

@JsonSerializable()
class BlockedServicesSchedule {
  const BlockedServicesSchedule({this.schedule, this.ids});

  factory BlockedServicesSchedule.fromJson(Map<String, Object?> json) =>
      _$BlockedServicesScheduleFromJson(json);

  final Schedule? schedule;

  /// The names of the blocked services.
  ///
  final List<String>? ids;

  Map<String, Object?> toJson() => _$BlockedServicesScheduleToJson(this);
}
