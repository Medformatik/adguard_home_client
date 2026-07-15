// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/add_url_request.dart';
import '../models/filter_refresh_request.dart';
import '../models/filter_refresh_response.dart';
import '../models/filter_set_url.dart';
import '../models/filter_status.dart';
import '../models/remove_url_request.dart';
import '../models/set_rules_request.dart';

part 'filtering_api.g.dart';

@RestApi()
abstract class FilteringApi {
  factory FilteringApi(Dio dio, {String? baseUrl}) = _FilteringApi;

  /// Get filtering parameters
  @GET('/filtering/status')
  Future<FilterStatus> filteringStatus();

  /// Add filter URL or an absolute file path
  @POST('/filtering/add_url')
  Future<void> filteringAddUrl({@Body() required AddUrlRequest body});

  /// Remove filter URL
  @POST('/filtering/remove_url')
  Future<void> filteringRemoveUrl({@Body() required RemoveUrlRequest body});

  /// Set URL parameters
  @POST('/filtering/set_url')
  Future<void> filteringSetUrl({@Body() FilterSetUrl? body});

  /// Reload filtering rules from URLs.  This might be needed if new URL was just added and you don't want to wait for automatic refresh to kick in. This API request is ratelimited, so you can call it freely as often as you like, it wont create unnecessary burden on servers that host the URL.  This should work as intended, a `force` parameter is offered as last-resort attempt to make filter lists fresh.  If you ever find yourself using `force` to make something work that otherwise wont, this is a bug and report it accordingly.
  @POST('/filtering/refresh')
  Future<FilterRefreshResponse> filteringRefresh({
    @Body() FilterRefreshRequest? body,
  });

  /// Set user-defined filter rules
  @POST('/filtering/set_rules')
  Future<void> filteringSetRules({@Body() SetRulesRequest? body});
}
