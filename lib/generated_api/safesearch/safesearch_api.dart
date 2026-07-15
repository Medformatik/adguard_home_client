// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/safe_search_config.dart';

part 'safesearch_api.g.dart';

@RestApi()
abstract class SafesearchApi {
  factory SafesearchApi(Dio dio, {String? baseUrl}) = _SafesearchApi;

  /// Update safesearch settings
  @PUT('/safesearch/settings')
  Future<void> safesearchSettings({@Body() SafeSearchConfig? body});

  /// Get safesearch status
  @GET('/safesearch/status')
  Future<SafeSearchConfig> safesearchStatus();
}
