// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatsConfig _$StatsConfigFromJson(Map<String, dynamic> json) => StatsConfig(
  interval: json['interval'] == null
      ? null
      : StatsConfigInterval.fromJson((json['interval'] as num).toInt()),
);

Map<String, dynamic> _$StatsConfigToJson(StatsConfig instance) =>
    <String, dynamic>{
      'interval': _$StatsConfigIntervalEnumMap[instance.interval],
    };

const _$StatsConfigIntervalEnumMap = {
  StatsConfigInterval.value0: 0,
  StatsConfigInterval.value1: 1,
  StatsConfigInterval.value7: 7,
  StatsConfigInterval.value30: 30,
  StatsConfigInterval.value90: 90,
  StatsConfigInterval.$unknown: r'$unknown',
};
