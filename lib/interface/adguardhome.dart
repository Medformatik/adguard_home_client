import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:adguard_home_client/interface/filtering.dart';
import 'package:adguard_home_client/interface/parental.dart';
import 'package:adguard_home_client/interface/querylog.dart';
import 'package:adguard_home_client/interface/safebrowsing.dart';
import 'package:adguard_home_client/interface/safesearch.dart';
import 'package:adguard_home_client/interface/stats.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class AdGuardHome {
  final String host;
  final String basePath;
  final String? password;
  final int port;
  final int requestTimeout;
  final bool tls;
  final String? userAgent;
  final String? username;
  final bool verifySsl;

  late AdGuardHomeFiltering filtering;
  late AdGuardHomeParental parental;
  late AdGuardHomeQueryLog queryLog;
  late AdGuardHomeSafeBrowsing safeBrowsing;
  late AdGuardHomeSafeSearch safeSearch;
  late AdGuardHomeStats stats;

  Dio? _session;
  bool _closeSession = false;

  bool get isDemo => host == 'demo.demo.demo' && port == 3000 && username == 'demo' && password == 'demo';
  bool _demoProtectionEnabled = true;
  bool _demoSafeBrowsing = true;
  bool _demoParental = false;
  bool _demoSafeSearch = true;

  AdGuardHome({
    required this.host,
    this.basePath = '/control',
    this.password,
    this.port = 3000,
    this.requestTimeout = 10000,
    this.tls = false,
    this.userAgent,
    this.username,
    this.verifySsl = true,
  }) {
    // Initialize connection with AdGuard Home.

    // Class constructor for setting up an AdGuard Home object to
    // communicate with an AdGuard Home instance.

    /* 
    Args:
      host: Hostname or IP address of the AdGuard Home instance.
      basePath: Base path of the API, usually `/control`, which is the default.
      password: Password for HTTP auth, if enabled.
      port: Port on which the API runs, usually 3000.
      requestTimeout: Max timeout to wait for a response from the API.
      session: Optional, shared, aiohttp client session.
      tls: True, when TLS/SSL should be used.
      userAgent: Defaults to PythonAdGuardHome/<version>.
      username: Username for HTTP auth, if enabled.
      verifySsl: Can be set to false, when TLS with self-signed cert is used.
    */

    filtering = AdGuardHomeFiltering(this);
    parental = AdGuardHomeParental(this);
    queryLog = AdGuardHomeQueryLog(this);
    safeBrowsing = AdGuardHomeSafeBrowsing(this);
    safeSearch = AdGuardHomeSafeSearch(this);
    stats = AdGuardHomeStats(this);
  }

  Future<Map<String, dynamic>> request(
    String uri, {
    String method = 'GET',
    dynamic data,
    Map? jsonData,
    Map<String, String>? params,
  }) async {
    /* 
    Handle a request to the AdGuard Home instance.

    Make a request against the AdGuard Home API and handles the response.

    Args:
      uri: The request URI on the AdGuard Home API to call.
      method: HTTP method to use for the request; e.g., GET, POST.
      data: RAW HTTP request data to send with the request.
      json_data: Dictionary of data to send as JSON with the request.
      params: Mapping of request parameters to send with the request.

    Returns:
      The response from the API. In case the response is a JSON response,
      the method will return a decoded JSON response as a Python
      dictionary. In other cases, it will return the RAW text response.

    Raises:
      AdGuardHomeConnectionError: An error occurred while communicating
        with the AdGuard Home instance (connection issues).
      AdGuardHomeError: An error occurred while processing the
        response from the AdGuard Home instance (invalid data).
    */

    if (isDemo) return _demoResponse(uri, data, params);

    String scheme = tls ? 'https' : 'http';
    String url = '$scheme://$host:$port$basePath/$uri';

    String? auth;

    Map<String, String> headers = {
      'Accept': 'application/json, text/plain, */*',
    };

    if (userAgent != null) {
      headers['User-Agent'] = userAgent!;
    }

    if (username != null && password != null) {
      auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      headers['authorization'] = auth;
    }

    if (_session == null) {
      _session = Dio(
        BaseOptions(
          connectTimeout: Duration(milliseconds: requestTimeout),
        ),
      );
      if (tls && !verifySsl) {
        (_session!.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        };
      }
      _closeSession = true;
    }

    Response? response;

    try {
      response = await _session!.fetch(
        RequestOptions(
          method: method,
          path: url,
          headers: headers,
          data: data,
          connectTimeout: Duration(milliseconds: requestTimeout),
          queryParameters: params,
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('AdGuardHome request failed: ${e.response!.statusCode}');
      } else {
        debugPrint('AdGuardHome request error: ${e.message}');
      }
    }

    if (response == null) {
      return {'error': 'No response'};
    }

    String? contentType = response.headers.value('Content-Type');

    if ([4, 5].contains(response.statusCode! ~/ 100)) {
      if (contentType == 'application/json') {
        debugPrint('AdGuardHomeError: ${response.statusCode}');
      }
    }

    if (contentType != null && contentType.contains('application/json')) {
      return response.data;
    }

    String text = response.data;
    return {'message': text};
  }

  // Return if AdGuard Home protection is enabled or not.
  Future<bool> protectionEnabled() async {
    if (isDemo) return _demoProtectionEnabled;
    Map<String, dynamic> response = await request('status');
    return response['protection_enabled'] ?? false;
  }

  Future<void> enableProtection() async {
    /*
    Enable AdGuard Home protection.
    Raises:
      AdGuardHomeError: Failed enabling AdGuard Home protection.
    */
    if (isDemo) {
      _demoProtectionEnabled = true;
      return;
    }
    try {
      await request(
        'dns_config',
        method: 'POST',
        data: {'protection_enabled': true},
      );
    } catch (e) {
      debugPrint('AdGuardHomeError: Failed enabling AdGuard Home protection.');
      rethrow;
    }
  }

  Future<void> disableProtection() async {
    /*
    Disable AdGuard Home protection.
    Raises:
      AdGuardHomeError: Failed disabling AdGuard Home protection.
    */
    if (isDemo) {
      _demoProtectionEnabled = false;
      return;
    }
    try {
      await request(
        'dns_config',
        method: 'POST',
        data: {'protection_enabled': false},
      );
    } catch (e) {
      debugPrint('AdGuardHomeError: Failed disabling AdGuard Home protection.');
      rethrow;
    }
  }

  // Return the current version of the AdGuard Home instance.
  Future<String> version() async {
    if (isDemo) return 'Version: Demo';
    Map<String, dynamic> response = await request('status');
    return response['version'] ?? 'Version unknown';
  }

  // Returns if the AdGuard Home instance is connected or not
  Future<bool> successfullyConnected() async {
    if (isDemo) return true;
    Map<String, dynamic>? response = await request('status');
    return !(response.containsKey('error') && response['error'] == 'No response');
  }

  Future<void> close() async {
    if (_session != null && _closeSession) {
      _session!.close();
    }
  }

  Map<String, dynamic> _demoResponse(String uri, dynamic data, Map<String, String>? params) {
    switch (uri) {
      case 'status':
        return {'protection_enabled': _demoProtectionEnabled, 'version': 'Demo'};
      case 'stats':
        return _demoStatsPayload;
      case 'stats_info':
        return {'interval': 90};
      case 'safebrowsing/status':
        return {'enabled': _demoSafeBrowsing};
      case 'safebrowsing/enable':
        _demoSafeBrowsing = true;
        return {};
      case 'safebrowsing/disable':
        _demoSafeBrowsing = false;
        return {};
      case 'parental/status':
        return {'enabled': _demoParental};
      case 'parental/enable':
        _demoParental = true;
        return {};
      case 'parental/disable':
        _demoParental = false;
        return {};
      case 'safesearch/status':
        return {'enabled': _demoSafeSearch, 'bing': true, 'duckduckgo': true, 'google': true, 'yandex': true, 'youtube': true};
      case 'safesearch/settings':
        if (data is Map && data['enabled'] is bool) {
          _demoSafeSearch = data['enabled'] as bool;
        }
        return {};
      case 'querylog':
        final search = params?['search']?.toLowerCase();
        if (search == null || search.isEmpty) return {'data': _demoQueryLog};
        return {
          'data': [
            for (final entry in _demoQueryLog)
              if ((entry['question']?['name'] ?? '').toString().toLowerCase().contains(search) ||
                  (entry['client'] ?? '').toString().toLowerCase().contains(search))
                entry,
          ],
        };
    }
    return {};
  }

  static final Map<String, dynamic> _demoStatsPayload = (() {
    final rng = Random(42);
    List<int> series(int base, int variance) =>
        List<int>.generate(90, (i) => (base + rng.nextInt(variance) - variance ~/ 2).clamp(0, 1 << 31));
    final dnsQueries = series(1500, 800);
    final blockedFiltering = series(380, 200);
    final replacedSafebrowsing = series(8, 16);
    final replacedParental = series(2, 6);
    final totalQueries = dnsQueries.fold<int>(0, (a, b) => a + b);
    final totalBlocked = blockedFiltering.fold<int>(0, (a, b) => a + b);
    final totalSafebrowsing = replacedSafebrowsing.fold<int>(0, (a, b) => a + b);
    final totalParental = replacedParental.fold<int>(0, (a, b) => a + b);
    return {
      'num_dns_queries': totalQueries,
      'num_blocked_filtering': totalBlocked,
      'num_replaced_safebrowsing': totalSafebrowsing,
      'num_replaced_parental': totalParental,
      'num_replaced_safesearch': 124,
      'avg_processing_time': 0.0124,
      'top_queried_domains': const [
        {'play.googleapis.com': 12345},
        {'apple.com': 8124},
        {'github.com': 6532},
        {'cloudflare.com': 5421},
        {'wikipedia.org': 4127},
      ],
      'top_blocked_domains': const [
        {'doubleclick.net': 4321},
        {'googlesyndication.com': 3210},
        {'facebook.com': 2890},
        {'analytics.google.com': 1842},
        {'ads.youtube.com': 1457},
      ],
      'top_clients': const [
        {'192.168.1.10': 18432},
        {'192.168.1.42': 12891},
        {'192.168.1.5': 7321},
        {'192.168.1.78': 4128},
      ],
      'dns_queries': dnsQueries,
      'blocked_filtering': blockedFiltering,
      'replaced_safebrowsing': replacedSafebrowsing,
      'replaced_parental': replacedParental,
    };
  })();

  static final List<Map<String, dynamic>> _demoQueryLog = (() {
    final now = DateTime.now().toUtc();
    final samples = <Map<String, dynamic>>[
      {'name': 'play.googleapis.com', 'reason': 'NotFilteredNotFound', 'client': '192.168.1.10'},
      {'name': 'doubleclick.net', 'reason': 'FilteredBlackList', 'rule': '||doubleclick.net^', 'client': '192.168.1.42'},
      {'name': 'github.com', 'reason': 'NotFilteredNotFound', 'client': '192.168.1.10'},
      {'name': 'malware.example.org', 'reason': 'FilteredSafeBrowsing', 'client': '192.168.1.5'},
      {'name': 'ads.facebook.com', 'reason': 'FilteredBlackList', 'rule': '||facebook.com^', 'client': '192.168.1.78'},
      {'name': 'youtube.com', 'reason': 'NotFilteredNotFound', 'client': '192.168.1.10'},
      {'name': 'adult.example.com', 'reason': 'FilteredParental', 'client': '192.168.1.78'},
      {'name': 'cloudflare.com', 'reason': 'NotFilteredNotFound', 'client': '192.168.1.42'},
      {'name': 'analytics.google.com', 'reason': 'FilteredBlackList', 'rule': '||google-analytics.com^', 'client': '192.168.1.10'},
      {'name': 'wikipedia.org', 'reason': 'NotFilteredNotFound', 'client': '192.168.1.5'},
      {'name': 'tracker.example.net', 'reason': 'FilteredBlackList', 'rule': '||tracker.example.net^', 'client': '192.168.1.42'},
      {'name': 'apple.com', 'reason': 'NotFilteredNotFound', 'client': '192.168.1.10'},
    ];
    return [
      for (int i = 0; i < samples.length; i++)
        {
          'time': now.subtract(Duration(minutes: i * 4 + 1)).toIso8601String(),
          'question': {'name': samples[i]['name'], 'type': 'A', 'class': 'IN'},
          'answer': [
            {'value': samples[i]['reason'].toString().startsWith('Filtered') ? '0.0.0.0' : '93.184.216.34'},
          ],
          'reason': samples[i]['reason'],
          'elapsedMs': (0.4 + i * 0.13).toStringAsFixed(4),
          if (samples[i]['rule'] != null) 'rule': samples[i]['rule'],
          'client': samples[i]['client'],
        },
    ];
  })();
}
