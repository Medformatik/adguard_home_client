// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_safebrowsing_status_response.dart';

part 'safebrowsing_api.g.dart';

@RestApi()
abstract class SafebrowsingApi {
  factory SafebrowsingApi(Dio dio, {String? baseUrl}) = _SafebrowsingApi;

  /// Enable safebrowsing
  @POST('/safebrowsing/enable')
  Future<void> safebrowsingEnable();

  /// Disable safebrowsing
  @POST('/safebrowsing/disable')
  Future<void> safebrowsingDisable();

  /// Get safebrowsing status
  @GET('/safebrowsing/status')
  Future<GetSafebrowsingStatusResponse> safebrowsingStatus();
}
