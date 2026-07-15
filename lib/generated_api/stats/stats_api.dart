// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_stats_config_response.dart';
import '../models/put_stats_config_update_request.dart';
import '../models/stats.dart';
import '../models/stats_config.dart';

part 'stats_api.g.dart';

@RestApi()
abstract class StatsApi {
  factory StatsApi(Dio dio, {String? baseUrl}) = _StatsApi;

  /// Get DNS server statistics.
  ///
  /// [recent] - The lookback period for statistics in milliseconds.  The interval must.
  /// be a multiple of one hour and must not be greater than the value of.
  /// `statistics.interval`.
  @GET('/stats')
  Future<Stats> stats({@Query('recent') int? recent});

  /// Reset all statistics to zeroes
  @POST('/stats_reset')
  Future<void> statsReset();

  /// Get statistics parameters.
  ///
  /// Deprecated: Use `GET /stats/config` instead.
  ///
  /// NOTE: If `interval` was configured by editing configuration file or new.
  /// HTTP API call `PUT /stats/config/update` and it's not equal to.
  /// previous allowed enum values then it will be equal to `90` days for.
  /// compatibility reasons.
  @Deprecated('This method is marked as deprecated')
  @GET('/stats_info')
  Future<StatsConfig> statsInfo();

  /// Get statistics parameters
  @GET('/stats/config')
  Future<GetStatsConfigResponse> getStatsConfig();

  /// Set statistics parameters
  @PUT('/stats/config/update')
  Future<void> putStatsConfig({
    @Body() required PutStatsConfigUpdateRequest body,
  });
}
