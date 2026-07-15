// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'day_range.dart';

part 'schedule.g.dart';

/// Sets periods of inactivity for filtering blocked services.  The schedule contains 7 days (Sunday to Saturday) and a time zone.
///
@JsonSerializable()
class Schedule {
  const Schedule({
    this.timeZone,
    this.sun,
    this.mon,
    this.tue,
    this.wed,
    this.thu,
    this.fri,
    this.sat,
  });

  factory Schedule.fromJson(Map<String, Object?> json) =>
      _$ScheduleFromJson(json);

  /// Time zone name according to IANA time zone database.  For example `Europe/Brussels`.  `Local` represents the system's local time zone.
  ///
  @JsonKey(name: 'time_zone')
  final String? timeZone;
  final DayRange? sun;
  final DayRange? mon;
  final DayRange? tue;
  final DayRange? wed;
  final DayRange? thu;
  final DayRange? fri;
  final DayRange? sat;

  Map<String, Object?> toJson() => _$ScheduleToJson(this);
}
