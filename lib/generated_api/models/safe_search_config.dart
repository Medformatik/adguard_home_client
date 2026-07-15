// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'safe_search_config.g.dart';

/// Safe search settings.
@JsonSerializable()
class SafeSearchConfig {
  const SafeSearchConfig({
    this.enabled,
    this.bing,
    this.duckduckgo,
    this.ecosia,
    this.google,
    this.pixabay,
    this.yandex,
    this.youtube,
  });

  factory SafeSearchConfig.fromJson(Map<String, Object?> json) =>
      _$SafeSearchConfigFromJson(json);

  final bool? enabled;
  final bool? bing;
  final bool? duckduckgo;
  final bool? ecosia;
  final bool? google;
  final bool? pixabay;
  final bool? yandex;
  final bool? youtube;

  Map<String, Object?> toJson() => _$SafeSearchConfigToJson(this);
}
