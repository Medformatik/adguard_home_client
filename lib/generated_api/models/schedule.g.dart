// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
  timeZone: json['time_zone'] as String?,
  sun: json['sun'] == null
      ? null
      : DayRange.fromJson(json['sun'] as Map<String, dynamic>),
  mon: json['mon'] == null
      ? null
      : DayRange.fromJson(json['mon'] as Map<String, dynamic>),
  tue: json['tue'] == null
      ? null
      : DayRange.fromJson(json['tue'] as Map<String, dynamic>),
  wed: json['wed'] == null
      ? null
      : DayRange.fromJson(json['wed'] as Map<String, dynamic>),
  thu: json['thu'] == null
      ? null
      : DayRange.fromJson(json['thu'] as Map<String, dynamic>),
  fri: json['fri'] == null
      ? null
      : DayRange.fromJson(json['fri'] as Map<String, dynamic>),
  sat: json['sat'] == null
      ? null
      : DayRange.fromJson(json['sat'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
  'time_zone': instance.timeZone,
  'sun': instance.sun,
  'mon': instance.mon,
  'tue': instance.tue,
  'wed': instance.wed,
  'thu': instance.thu,
  'fri': instance.fri,
  'sat': instance.sat,
};
