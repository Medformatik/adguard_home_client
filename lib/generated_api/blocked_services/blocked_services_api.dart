// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/blocked_services_all.dart';
import '../models/blocked_services_array.dart';
import '../models/blocked_services_schedule.dart';

part 'blocked_services_api.g.dart';

@RestApi()
abstract class BlockedServicesApi {
  factory BlockedServicesApi(Dio dio, {String? baseUrl}) = _BlockedServicesApi;

  /// Get available services to use for blocking.
  ///
  /// Deprecated: Use `GET /blocked_services/all` instead.
  @Deprecated('This method is marked as deprecated')
  @GET('/blocked_services/services')
  Future<BlockedServicesArray> blockedServicesAvailableServices();

  /// Get available services to use for blocking
  @GET('/blocked_services/all')
  Future<BlockedServicesAll> blockedServicesAll();

  /// Set blocked services list.
  ///
  /// Deprecated: Use `PUT /blocked_services/update` instead.
  @Deprecated('This method is marked as deprecated')
  @POST('/blocked_services/set')
  Future<void> blockedServicesSet({@Body() BlockedServicesArray? body});

  /// Get blocked services
  @GET('/blocked_services/get')
  Future<BlockedServicesSchedule> blockedServicesSchedule();

  /// Update blocked services
  @PUT('/blocked_services/update')
  Future<void> blockedServicesScheduleUpdate({
    @Body() required BlockedServicesSchedule body,
  });
}
