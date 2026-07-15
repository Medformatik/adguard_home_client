// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/filtering_reason.dart';
import '../models/get_query_log_config_response.dart';
import '../models/put_query_log_config_update_request.dart';
import '../models/query_log.dart';
import '../models/response_status.dart';

part 'log_api.g.dart';

@RestApi()
abstract class LogApi {
  factory LogApi(Dio dio, {String? baseUrl}) = _LogApi;

  /// Get DNS server query log.
  ///
  /// [olderThan] - Filter by older than.
  ///
  /// [offset] - Specify the ranking number of the first item on the page.  Even though it is possible to use "offset" and "older_than", we recommend choosing one of them and sticking to it.
  ///
  ///
  /// [limit] - Limit the number of records to be returned.
  ///
  /// [search] - Filter by domain name or client IP.
  ///
  /// [responseStatus] - Deprecated: Use 'reason' parameter instead Filter by response status.
  /// NOTE: This parameter cannot be used with 'reason' parameter.
  ///
  ///
  /// [reason] - Filter by response filtering reason.  Multiple reasons can be provided.
  /// NOTE: This parameter cannot be used with 'response_status' parameter.
  @GET('/querylog')
  Future<QueryLog> queryLog({
    @Query('older_than') String? olderThan,
    @Query('offset') int? offset,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Deprecated('This is marked as deprecated')
    @Query('response_status')
    ResponseStatus? responseStatus,
    @Query('reason') List<FilteringReason>? reason,
  });

  /// Clear query log
  @POST('/querylog_clear')
  Future<void> querylogClear();

  /// Get query log parameters
  @GET('/querylog/config')
  Future<GetQueryLogConfigResponse> getQueryLogConfig();

  /// Set query log parameters
  @PUT('/querylog/config/update')
  Future<void> putQueryLogConfig({
    @Body() required PutQueryLogConfigUpdateRequest body,
  });
}
