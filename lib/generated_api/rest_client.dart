// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'global/global_api.dart';
import 'log/log_api.dart';
import 'stats/stats_api.dart';
import 'filtering/filtering_api.dart';
import 'safebrowsing/safebrowsing_api.dart';
import 'parental/parental_api.dart';
import 'safesearch/safesearch_api.dart';
import 'clients/clients_api.dart';
import 'blocked_services/blocked_services_api.dart';
import 'rewrite/rewrite_api.dart';

/// AdGuard Home `v0.107`.
///
/// AdGuard Home REST-ish API.  Our admin web interface is built on top of this REST-ish API.
///
class RestClient {
  RestClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '0.107';

  GlobalApi? _global;
  LogApi? _log;
  StatsApi? _stats;
  FilteringApi? _filtering;
  SafebrowsingApi? _safebrowsing;
  ParentalApi? _parental;
  SafesearchApi? _safesearch;
  ClientsApi? _clients;
  BlockedServicesApi? _blockedServices;
  RewriteApi? _rewrite;

  GlobalApi get global => _global ??= GlobalApi(_dio, baseUrl: _baseUrl);

  LogApi get log => _log ??= LogApi(_dio, baseUrl: _baseUrl);

  StatsApi get stats => _stats ??= StatsApi(_dio, baseUrl: _baseUrl);

  FilteringApi get filtering =>
      _filtering ??= FilteringApi(_dio, baseUrl: _baseUrl);

  SafebrowsingApi get safebrowsing =>
      _safebrowsing ??= SafebrowsingApi(_dio, baseUrl: _baseUrl);

  ParentalApi get parental =>
      _parental ??= ParentalApi(_dio, baseUrl: _baseUrl);

  SafesearchApi get safesearch =>
      _safesearch ??= SafesearchApi(_dio, baseUrl: _baseUrl);

  ClientsApi get clients => _clients ??= ClientsApi(_dio, baseUrl: _baseUrl);

  BlockedServicesApi get blockedServices =>
      _blockedServices ??= BlockedServicesApi(_dio, baseUrl: _baseUrl);

  RewriteApi get rewrite => _rewrite ??= RewriteApi(_dio, baseUrl: _baseUrl);
}
