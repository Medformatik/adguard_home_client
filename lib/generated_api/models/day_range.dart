// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'day_range.g.dart';

/// The single interval within a day.  It begins at the `start` and ends before the `end`.
///
@JsonSerializable()
class DayRange {
  const DayRange({this.start, this.end});

  factory DayRange.fromJson(Map<String, Object?> json) =>
      _$DayRangeFromJson(json);

  /// The number of milliseconds elapsed from the start of a day.  It must be less than `end` and is expected to be rounded to minutes. So the maximum value is `86340000` (23 hours and 59 minutes).
  ///
  final num? start;

  /// The number of milliseconds elapsed from the start of a day.  It is expected to be rounded to minutes.  The maximum value is `86400000` (24 hours).
  ///
  final num? end;

  Map<String, Object?> toJson() => _$DayRangeToJson(this);
}
