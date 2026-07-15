// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewrite_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewriteUpdate _$RewriteUpdateFromJson(Map<String, dynamic> json) =>
    RewriteUpdate(
      target: json['target'] == null
          ? null
          : RewriteEntry.fromJson(json['target'] as Map<String, dynamic>),
      update: json['update'] == null
          ? null
          : RewriteEntry.fromJson(json['update'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RewriteUpdateToJson(RewriteUpdate instance) =>
    <String, dynamic>{'target': instance.target, 'update': instance.update};
