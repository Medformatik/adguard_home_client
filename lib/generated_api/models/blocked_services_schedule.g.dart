// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_services_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockedServicesSchedule _$BlockedServicesScheduleFromJson(
  Map<String, dynamic> json,
) => BlockedServicesSchedule(
  schedule: json['schedule'] == null
      ? null
      : Schedule.fromJson(json['schedule'] as Map<String, dynamic>),
  ids: (json['ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$BlockedServicesScheduleToJson(
  BlockedServicesSchedule instance,
) => <String, dynamic>{'schedule': instance.schedule, 'ids': instance.ids};
