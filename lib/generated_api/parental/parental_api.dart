// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_parental_status_response.dart';

part 'parental_api.g.dart';

@RestApi()
abstract class ParentalApi {
  factory ParentalApi(Dio dio, {String? baseUrl}) = _ParentalApi;

  /// Enable parental filtering
  @POST('/parental/enable')
  Future<void> parentalEnable();

  /// Disable parental filtering
  @POST('/parental/disable')
  Future<void> parentalDisable();

  /// Get parental filtering status
  @GET('/parental/status')
  Future<GetParentalStatusResponse> parentalStatus();
}
