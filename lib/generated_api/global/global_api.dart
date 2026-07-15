// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/dns_config.dart';
import '../models/get_dns_info_response.dart';
import '../models/server_status.dart';
import '../models/set_protection_request.dart';
import '../models/upstreams_config.dart';
import '../models/upstreams_config_response.dart';

part 'global_api.g.dart';

@RestApi()
abstract class GlobalApi {
  factory GlobalApi(Dio dio, {String? baseUrl}) = _GlobalApi;

  /// Get DNS server current status and general settings
  @GET('/status')
  Future<ServerStatus> status();

  /// Get general DNS parameters
  @GET('/dns_info')
  Future<GetDnsInfoResponse> dnsInfo();

  /// Set general DNS parameters
  @POST('/dns_config')
  Future<void> dnsConfig({@Body() DnsConfig? body});

  /// Set protection state and duration
  @POST('/protection')
  Future<void> setProtection({@Body() SetProtectionRequest? body});

  /// Clear DNS cache
  @POST('/cache_clear')
  Future<void> cacheClear();

  /// Test upstream configuration
  @POST('/test_upstream_dns')
  Future<UpstreamsConfigResponse> testUpstreamDns({
    @Body() UpstreamsConfig? body,
  });
}
