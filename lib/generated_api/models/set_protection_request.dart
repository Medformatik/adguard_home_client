// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'set_protection_request.g.dart';

/// Protection state configuration
@JsonSerializable()
class SetProtectionRequest {
  const SetProtectionRequest({required this.enabled, this.duration});

  factory SetProtectionRequest.fromJson(Map<String, Object?> json) =>
      _$SetProtectionRequestFromJson(json);

  final bool enabled;

  /// Duration of a pause, in milliseconds.  Enabled should be false.
  final int? duration;

  Map<String, Object?> toJson() => _$SetProtectionRequestToJson(this);
}
